[English](README.md) | 简体中文

# Launchy 2.6 Beta 2（Qt 4.8.7 + MinGW 重新编译版）

[Launchy](https://www.launchy.net) 是一个 Windows 快捷启动器：按 Alt+Space，
输入程序、文件或书签名称的一部分，再按回车即可打开。

本仓库是官方 Launchy 2.6 Beta 2 源码（SourceForge SVN r671，2010-11-10），
在此基础上加了一些功能，用 Qt 4.8.7 和 MinGW 4.8.2 编译。只支持 Windows。

未修改的官方源码见 tag
[`official-2.6-beta2-r671`](https://github.com/halfmoonvic/launchy/tree/official-2.6-beta2-r671)。
原作者的文档在 [docs/original](docs/original)。

## 相对官方 2.6 Beta 2 的改动

Runner 命令新增两个可选设置，也可以在 Runner 插件选项里编辑：

```ini
cmds\N\icon=C:\\path\\to\\app.ico     ; .ico 或 .png 文件
cmds\N\icon=C:\\path\\to\\app.dll,3   ; exe 或 dll 里的第 3 个图标
cmds\N\show=hidden                     ; normal（默认）、hidden 或 minimized
```

`show=hidden` 运行 `.cmd` 或 `.bat` 时不会闪出控制台窗口。
如果命令指定的图标文件不存在，会先用程序自身的图标，再用 Runner 图标，
而不是显示成文件夹图标。

其他改动：

- 在 Qt 4.8 下图标能正常显示，大小跟随系统显示缩放（125% 时为 40 像素）
- 候选列表每一行都能完整显示名称和路径
- 新增 Black Glass Large 皮肤：Black Glass 的 1.5 倍大小
- 删除已失效的 Google Calculator（gcalc）插件
- 删除 Linux、Mac 和 Visual Studio 2005 的构建文件

## 安装

从 [Releases](https://github.com/halfmoonvic/launchy/releases) 下载
`Launchy-<版本>-win32.zip`，解压到任意位置，例如
`%LOCALAPPDATA%\Programs\Launchy`，运行 `Launchy.exe` 即可，不需要安装。
按 Alt+Space 呼出。

设置保存在 `%APPDATA%\Launchy\launchy.ini`。只要 `Launchy.exe` 同一目录下有
`launchy.ini`，Launchy 就以便携模式运行，设置保存在程序目录里。

## 编译

详见 [BUILD.txt](BUILD.txt)。简单来说，装好 Qt 4.8.7、MinGW 4.8.2 和 Boost
头文件后：

```powershell
powershell -File build-mingw.ps1            # 编译到 dist\
powershell -File build-mingw.ps1 -Package   # 同时生成 package\Launchy-<版本>-win32.zip
```

## 许可证

Launchy 是自由软件，使用 GNU 通用公共许可证第 2 版（GPL 2），见
[LICENSE.txt](LICENSE.txt)。Launchy 的作者是 Josh Karlin 和 Simon Capewell。
发布的 zip 包含 Qt 4.8.7 库（LGPL 2.1）和 MinGW-w64 GCC 运行库，它们的许可证
在 zip 里的 `licenses` 文件夹中。
