# Antigravity Remote SSH Server for macOS (Darwin/arm64)

[English](#english) | [中文](#中文)

---

<a name="english"></a>
# English Version

Installer script and best practices for running Antigravity Remote SSH server on macOS systems.

## The Ideal Approach: OrbStack Linux VM (Highly Recommended)

After extensive testing, the most stable and feature-complete experience is achieved by running a lightweight Linux VM on your Mac using **OrbStack**. This bypasses macOS security restrictions that block the AI Agent's authentication.

### Benefits of the Linux VM Approach
*   **Full AI Functionality**: The AI Agent responds instantly. Authentication works perfectly via SSH Socket forwarding.
*   **No Manual Token Sync**: Authentication is dynamic; there is no need to copy database files (`state.vscdb`) or configurations. Our research confirms these files are empty in a healthy environment.
*   **Official Support**: Antigravity officially supports Linux-ARM/x64 server builds.
*   **Zero Conflict**: Avoids process and port conflicts with the Antigravity Desktop App on your host Mac.
*   **High Performance Path**: Access your Mac host files via `/mnt/mac/Users/...` with native-like speed.

### Setup Instructions for OrbStack
1.  **Install OrbStack**: Download from [orbstack.dev](https://orbstack.dev/).
2.  **Create a Machine**: Create a new Linux machine (Ubuntu/Debian recommended).
3.  **Expose SSH to LAN**:
    *   Open OrbStack **Settings** -> **Machines** tab.
    *   Check **Expose SSH server to LAN**.
    *   The default port is usually `32222`.
4.  **Connect**: Use `ssh -p 32222 user@your-mac-ip`.
5.  **Access Projects**: Your Mac files are automatically mounted at `/mnt/mac/Users/yourname/`. Open these folders in Antigravity for the best experience.

---

## Alternative: Running Directly on macOS Host

This repository provides an `install.sh` script that attempts to run the server directly on macOS by adapting the Linux-ARM server tarball.

### Current Limitations (The "Silent Agent" Problem)
Direct installation on macOS currently suffers from a critical issue: **The AI Agent may not reply.**
*   **Technical Reason**: Antigravity uses an **SSH Auth Socket** (mapped to `SSH_AUTH_SOCK`) to dynamically request credentials from your local Mac. On macOS hosts, this socket file is often blocked or never created due to System Integrity Protection (SIP) and Sandbox policies.
*   **No DB Needed**: Investigation confirms that manually syncing database files or tokens to the server **does not resolve** the authentication issue, as the AI Engine relies on the live socket, not disk-based tokens.
*   **Result**: The AI Engine hangs indefinitely waiting for a token, leading to an unresponsive chat panel.

### How to use the script (If you still want to try)
```bash
./install.sh user@remote-mac-host
```
The script will surgically replace Node.js binaries and native modules (`spdlog`, `watcher`, `pty`) with macOS-compatible versions.

---

<a name="中文"></a>
# 中文版

在 macOS 系统上运行 Antigravity Remote SSH 服务端的安装脚本与最佳实践指南。

## 理想方案：OrbStack Linux 虚拟机 (强烈推荐)

经过深度测试，获取最稳定、功能最全体验的方式是在 Mac 上通过 **OrbStack** 运行一个轻量级 Linux 虚拟机。这能完美绕过 macOS 宿主机限制 AI Agent 认证的安全策略。

### Linux 虚拟机方案的优势
*   **完整 AI 能力**：AI Agent 秒回复。认证通过 SSH Socket 转发完美工作。
*   **无需手动同步 Token**：认证是动态完成的，不需要拷贝任何数据库（`state.vscdb`）或配置文件。实测证明，在健康环境下这些文件本身就是空的。
*   **官方原生支持**：Antigravity 官方对 Linux-ARM/x64 服务端有完善支持。
*   **零冲突**：避免与宿主机上的 Antigravity 桌面版产生进程或端口冲突。
*   **高性能路径**：通过 `/mnt/mac/Users/...` 以近乎原生的速度直接访问宿主机文件。

### OrbStack 配置步骤
1.  **安装 OrbStack**：从 [orbstack.dev](https://orbstack.dev/) 下载。
2.  **创建 Machine**：新建一个 Linux 虚拟机（推荐 Ubuntu 或 Debian）。
3.  **向局域网暴露 SSH**：
    *   打开 OrbStack **Settings** -> **Machines** 标签页。
    *   勾选 **Expose SSH server to LAN**。
    *   默认端口通常为 `32222`。
4.  **连接**：使用 `ssh -p 32222 用户名@你的Mac-IP`。
5.  **访问项目**：你的 Mac 文件会自动挂载在 `/mnt/mac/Users/用户名/`。在 Antigravity 中直接打开这些目录即可。

---

## 备选方案：直接在 macOS 宿主机运行

本仓库提供了一个 `install.sh` 脚本，尝试通过改造成官方 Linux-ARM 服务端包来使其在 macOS 上运行。

### 当前局限性 (AI Agent “已读不回”问题)
直接在 macOS 宿主机安装目前存在一个核心痛点：**AI Agent 可能无法回复消息。**
*   **技术原因**：Antigravity 依赖 **SSH Auth Socket** 动态向本地 Mac 请求 Token，而不是读取本地数据库。在 macOS 宿主机环境下，受系统沙盒（Sandbox）限制，该 Socket 往往无法正常工作。
*   **无需同步 DB**：实测证明，手动同步数据库文件并不能解决认证问题，因为 AI 引擎寻找的是实时的 Socket 通信而非磁盘上的 Token。
*   **结果**：远程 AI 引擎在等待 Token 时无限期挂起，导致 Agent 面板没有任何回复。

### 脚本使用方法 (如果你仍想尝试)
```bash
./install.sh 用户名@远程Mac地址
```
该脚本会“外科手术式”地将 Node.js 二进制文件和原生模块（`spdlog`, `watcher`, `pty`）替换为兼容 macOS 的版本。

---

## Acknowledgments / 致谢
Inspired by the work of [onekung](https://gist.github.com/onekung).

## License / 许可证
MIT
