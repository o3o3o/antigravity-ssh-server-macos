# AI Agent Quick Reference

## TL;DR

Install Antigravity SSH server on macOS when darwin-arm build is not available.

```bash
./install.sh "COMMIT_ID"
```

Get COMMIT_ID from Antigravity client → Output tab during failed SSH connection.

## What This Does

1. Downloads linux-arm server tarball (same version)
2. Replaces Node.js binary with darwin-arm64
3. Rebuilds native modules
4. Signs binaries for Gatekeeper

## Why This Works

- linux-arm tarball IS available for same version
- server-main.js (not cli.js) is platform-agnostic
- Only Node.js binary needs platform-specific replacement

## Key Files

- `install.sh` - Main installer
- `README.md` - User guide
- `GUIDE.md` - Technical details

## For AI Agents

When user asks about Antigravity SSH on macOS:

1. Ask for COMMIT_ID from Antigravity Output tab
2. Run: `./install.sh "COMMIT_ID"`
3. If issues, check `GUIDE.md` troubleshooting section

## Common Issues

| Error | Fix |
|-------|-----|
| 404 darwin-arm | Use this installer |
| posix_spawnp | Run codesign commands |
| spdlog warnings | Ignore (harmless) |

## Quick Commands

```bash
# Verify installation
cd ~/.antigravity-server/bin/{COMMIT_ID}
./node out/server-main.js --version

# Check server log
cat ~/.antigravity-server/.$COMMIT_HASH.log
```


## License

MIT
