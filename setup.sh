#!/usr/bin/env bash
# zquota setup — installs the CLI and the watch service (idempotent)
set -euo pipefail

BIN="$HOME/.local/bin/zquota"
SVC_DIR="$HOME/.config/systemd/user"
SVC="$SVC_DIR/zquota-watch.service"
STATE="$HOME/.local/state"
SRC="$(cd "$(dirname "$0")" && pwd)/zquota"

mkdir -p "$HOME/.local/bin" "$SVC_DIR" "$STATE"

# dependency
python3 -c 'import cryptography' 2>/dev/null || pip3 install --user cryptography

install -m 700 "$SRC" "$BIN"
echo "✓ zquota → $BIN"

cat > "$SVC" <<EOF
[Unit]
Description=zquota watch — auto-spend expiring z.ai gift reset quotas (all accounts)
After=network-online.target

[Service]
ExecStart=/usr/bin/python3 -u $BIN watch
Restart=on-failure
RestartSec=30
StandardOutput=append:$STATE/zquota-watch.log
StandardError=append:$STATE/zquota-watch.log

[Install]
WantedBy=default.target
EOF
echo "✓ service → $SVC"

systemctl --user daemon-reload
systemctl --user enable --now zquota-watch.service
loginctl show-user "$(id -u)" | grep -qi 'Linger=yes' || \
  echo "ℹ to keep the service running without a desktop session: sudo loginctl enable-linger $USER"

systemctl --user status zquota-watch.service --no-pager | head -4
echo "✓ done. logs: tail -f $STATE/zquota-watch.log"
echo "  first steps: zquota status   |   zquota help"
