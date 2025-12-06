# Doc for Developers

## clone 代码仓库

```
git clone https://github.com/xianyukang/MyKeymap
```

## 技术框架

### bin

主要是[AutoHotkey](https://www.autohotkey.com/) v2 代码，快捷键钩子、系统功能调用都在这里

### config-ui

vite + vue3 + TypeScript + Vuetify + Pinia 独立前端，用来维护修改配置

### config-server

Go 1.21+ 语言实现的后端，使用 Gin 框架，主要是两大功能：

+ 对于 bin：根据配置，调用 bin 代码完成核心功能
+ 对于 config-ui：实现 API 供其调用

## 环境要求

- **make** 构建工具
- **Go** 1.21+ 环境
- **Node.js** + npm/pnpm/yarn
- **Python3** (用于上传功能，可选)
- **AutoHotkey v2** (用于构建时复制 AutoHotkey64.exe，可选)

## 安装依赖

### config-ui

进入 `config-ui` 目录，使用以下任一命令安装依赖：

```bash
# 使用 npm
npm install

# 或使用 pnpm (推荐，Makefile 中使用的是 pnpm)
pnpm install

# 或使用 yarn
yarn install
```

### config-server

Go 依赖会在构建时自动下载，也可以手动执行：

```bash
cd config-server
go mod download
```

## 开发调试

使用 make 执行对应操作，对哪一部分进行修改，开启对应的调试，或者直接修改对应的代码即可

### ui调试

首先确保已安装 config-ui 的依赖，然后执行：

```bash
make client
```

这会启动 Vite 开发服务器，支持热重载。默认会在 `http://localhost:5173` 运行。

**注意**：在 WSL2 环境中，由于 Chokidar 无法监测 Windows 上的文件修改，会自动启用 Polling 模式以确保热重载正常工作。

### server调试

```bash
make server
```

这会先构建 server，然后以 debug 模式启动，默认监听 `localhost:12333` 端口。

### ahk调试

生成 AutoHotkey 脚本文件：

```bash
make ahk
```

这会根据 `data/config.json` 配置文件和模板生成 `bin/MyKeymap.ahk` 文件。

### bin

bin 部分的代码和一些工具，可以直接修改或者替换，修改后需要重新生成 AHK 文件或重启程序才能生效。

## 构建打包

需要 make 构建工具 + go + node 环境

### 完整构建

```bash
make build
```

这会执行以下步骤：
1. 构建 server (`buildServer`)
2. 构建 client (`buildClient`)
3. 复制文件到发布目录 (`copyFiles`)
4. 更新版本号
5. 打包为 7z 文件

### 单独构建

```bash
# 只构建 server
make buildServer

# 只构建 client
make buildClient
```

### 上传

```bash
make upload
```

需要 Python3 环境，会上传到蓝奏云并更新分享链接。

### 其他命令

在 `Makefile` 中可以找到更多构建相关的命令和说明。

