# Antigravity Remote SSH Server for macOS (Darwin/arm64)

Installer script for Antigravity Remote SSH server on macOS when the official darwin-arm build is not available.

## Problem

Antigravity does not provide official `darwin-arm` server binaries. When attempting to connect via Remote-SSH to a macOS server, you get 404 errors:

```
Download failed from .../darwin-arm/Antigravity-reh.tar.gz
Error downloading server from all URLs
```

## Solution

This script uses the **linux-arm server tarball** (which IS available) and adapts it for macOS by replacing the Node.js binary.

## Quick Start

### 1. Get COMMIT_ID

From Antigravity client's Output tab (when trying to connect via Remote-SSH):

```bash
DISTRO_IDE_VERSION="1.20.5"
DISTRO_COMMIT="4603c2a412f8c7cca552ff00db91c3ee787016ff"
```

Combine them: `1.20.5-4603c2a412f8c7cca552ff00db91c3ee787016ff`

### 2. Run Installer

```bash
./install.sh "1.20.5-4603c2a412f8c7cca552ff00db91c3ee787016ff"
```

### 3. Connect

Try connecting from your Antigravity client via Remote-SSH.

## Requirements

- macOS (darwin-arm64)
- `wget` - Install via `brew install wget`
- `curl` - Usually pre-installed
- `npm` - Usually pre-installed with Node.js

## Key Features

- ✅ Uses **same version** linux-arm tarball (not old version skeleton)
- ✅ Replaces only Node.js binary with darwin-arm64 version
- ✅ Rebuilds native modules for macOS
- ✅ Automatic code signing for Gatekeeper compliance
- ✅ Works with Antigravity 1.107.0+

## What This Script Does

1. Downloads linux-arm server tarball (same version)
2. Extracts to `~/.antigravity-server/bin/`
3. Replaces Node.js binary with darwin-arm64 version
4. Updates commit ID in product.json
5. Rebuilds native modules for macOS
6. Signs all binaries for Gatekeeper
7. Clears quarantine flags

## Server Location

```
~/.antigravity-server/bin/{COMMIT_ID}/
```

## Troubleshooting

### "posix_spawnp failed" Error

```bash
cd ~/.antigravity-server/bin/{COMMIT_ID}
codesign --force --deep --sign - node
find node_modules/@vscode/spdlog -name "*.node" -exec codesign --force --sign - {} \;
xattr -dr com.apple.quarantine .
```

### spdlog Warnings (Can be Ignored)

You may see `spdlog.node` warnings in logs. These are harmless - the server will work correctly.

### Verify Installation

```bash
cd ~/.antigravity-server/bin/{COMMIT_ID}
./node out/server-main.js --version
```

Expected output:
```
1.107.0
4603c2a412f8c7cca552ff00db91c3ee787016ff
arm64
```

## For Upgrades

Each Antigravity upgrade requires a new COMMIT_ID:

1. Get new COMMIT_ID from Antigravity Output tab
2. Run `./install.sh "NEW-COMMIT-ID"`
3. Done!

## Technical Details

See [GUIDE.md](GUIDE.md) for detailed technical information.

## License

MIT License - See [LICENSE](LICENSE) file

## Contributing

Contributions welcome! Please feel free to submit issues or pull requests.

## Disclaimer

This is an unofficial workaround. The Antigravity darwin-arm server build may become officially available in the future, which would be the preferred solution.
