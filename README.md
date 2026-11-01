# zquota

**Read and spend your z.ai / GLM Coding Plan gift quota-reset tokens from the terminal — without logging in and out of ZCode.**

`zquota` is a small unofficial CLI for [ZCode](https://zcode.z.ai) users on the GLM Coding plan. It reads the OAuth tokens ZCode already stores **on your own machine**, shows every account's quota (5-hour / weekly, plus ZCode gift "reset quotas"), and can automatically spend a gift reset in its final minutes before it expires — so it never goes to waste.

```
$ zquota status
▪ Account One <me@example.com>
   5-hour :   7% مانده، reset بعدی تا 1ساعت 52دقیقه
   weekly :  15% مانده، reset بعدی تا 8ساعت 55دقیقه
   Reset آماده: هفتگی ×3  (نزدیک‌ترین انقضا تا 1228ساعت) | ۵ساعته ×1
▪ Account Two <other@example.com>
   5-hour :  99% مانده، ...
   Reset آماده: هفتگی ×1 | ۵ساعته ×0
```

## What it does

| Command | Description |
|---|---|
| `zquota status` | Quota + available reset tokens for **all** accounts |
| `zquota accounts` | List accounts found on this machine |
| `zquota save` | Snapshot the currently-logged-in ZCode account (for multi-account) |
| `zquota reset [n] [week\|five_hour] [-y]` | Manually spend a gift reset (interactive confirmation) |
| `zquota watch [--min 2] [--interval 60] [--dry-run]` | Daemon: spend any reset when ≤ `--min` minutes remain before *its* expiry |

The `watch` daemon (run as a systemd user service by the installer) never touches resets that are not near expiry — you keep full manual control of everything else.

## Install

```bash
git clone <this repo> && cd zquota
bash setup.sh
```

`setup.sh` installs `zquota` to `~/.local/bin`, installs and enables the `zquota-watch` systemd **user** service, and is idempotent. Requirements: Linux, Python 3 with `cryptography` (`pip install cryptography`), an existing ZCode login.

## Multi-account

ZCode keeps only the active login's tokens. To let `zquota` manage several accounts:

1. In ZCode, log in with account **A** → run `zquota save`
2. In ZCode, log in with account **B** → run `zquota save`
3. Go back to whichever account you like. Done — from now on `zquota` / `watch` cover both, no more logout/login dance.

Accounts are stored in `~/.config/zquota/accounts.json` (mode `0600`). Remove an entry from that file to forget an account.

## How it works (and what it does *not* do)

- It reuses the tokens ZCode stores locally (`~/.zcode/v2/credentials.json`, encrypted with a machine-derived key — `zquota` reproduces that decryption locally only).
- It calls the same three endpoints the official client uses (read quota, read reset availability, spend reset) with **your** account. It cannot bypass any quota, create resets, or touch anyone else's account.
- Tokens never leave your machine; requests go directly to `zcode.z.ai` / `api.z.ai`.

## Disclaimer

This is an unofficial personal tool. Endpoints are undocumented and may change with any ZCode update — if it breaks, update `zquota`. Automating the service may sit in a gray area of the terms of use; use it at your own pace (a check once a minute) and at your own risk. Licensed under MIT.
