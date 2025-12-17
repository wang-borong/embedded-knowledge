# 如何使用 QEMU 调试 Linux

许多开发者朋友跟我说，Linux 系统很难学，都不知道从哪入手去学。
确实，想要学习 Linux，那么最起码需要有学习环境。

学习环境可以基于开发板，开发板确实是最好的学习环境。
然而调试工具和环境却不好搭建，一是好的调试工具昂贵，二是搭建和调试复杂。
往往搭建环境的繁琐已经耗尽了个人的学习热情。

好在学习环境还可以基于模拟器。
只需要有一台可以运行 Linux 系统的电脑，或者将 Linux 运行在虚拟机上也可以，就能够开始调试学习 Linux 内核。
调试环境搭建也很简单，且不必额外花费购买开发板，也不必费心于开发板的硬件环境。

那么下文就对如何使用 QEMU 调试学习 Linux 内核代码进行讲述，
以最简单的形式帮助开发者尽快入门内核开发。

首先，使用 QEMU 调试 Linux 需要准备以下材料，

1. 主机编译环境
1. QEMU sysmtem emulator
2. 内核镜像
3. rootfs
4. 对应平台的 GDB

其中，QEMU 模拟器、GDB 和 主机编译环境直接在发行版的 Linux 系统上安装即可。
而内核镜像和 rootfs 可以通过 buildroot 编译获取。

## 安装编译环境

1. Ubuntu 系统

   ```bash
   sudo apt-get install build-essential qemu-system
   ```

2. Archlinux

   ```bash
   sudo pacman -Sy base-devel qemu-base
   ```

后续我们需要对应平台的 GDB 进行调试，一般在交叉编译链工具包中包含 GDB 工具。
Ubuntu 系统一般可以正常运行这些 GDB 工具。
但是在 Arch 这种实时更新的 Linux 发行版上可能会出现库不兼容问题，如果出现这种问题，那么解决方案有 2 种：

1. 安装 GDB。
2. 解决库依赖问题或可安装兼容库。

我们推荐第一种解决方法，快速解决。
但是当您有能力解决库依赖问题时，尽可能尝试解决。

## 通过 buildroot 构建内核镜像和 rootfs

通过 buildroot 构建内核镜像和 rootfs 省却了很多繁琐步骤，而我们只需要极少的步骤就可以完成，省却了大量时间。
也给进入内核学习与开发留足了最大的热情。

通过 buildroot 构建的步骤如下，

1. 下载 [buildroot 源码](https://www.buildroot.org/downloads/buildroot-2024.02.2.tar.gz)并解压。
2. 配置，为了尽可能的节省构建时间，已将一些常用平台的 buildroot 配置（用于 QEMU）提取出来。
   支持有 aarch64、riscv64、vexpress-arma9 和 x86-64 平台。
   下载地址为 https://github.com/wang-borong/devenv/tree/main/buildroot。
   将所需平台的配置下载后重命名为 .config 到 buildroot 源码目录（解压的 buildroot 目录）。
   当然，如果你需要进行配置，可以在 buildroot 源码目录下运行 make menuconfig。
3. 编译与等待。
   配置过后即可编译，编译方法非常简单，运行 `make -j$(($(nproc) - 1))` 然后等待编译完成。
   编译过程中可能会遇到一些问题，如果有能力可以自行解决，或可以联系[我](wang_borong@163.com)。
   也可以向 https://github.com/wang-borong/devenv 仓库提 issue。
4. 从 buildroot 抽离 rootfs 和内核源码。
   编译成功后，你将获取到 output/images 目录，该目录下含有 rootfs 和内核镜像，将该目录拷贝到你的开发目录下。
   因为调试期间需要重新编译内核源码，所以我们需要将内核源码和交叉编译链抽离出来。
   内核源码在 dl/linux 目录下，我们并没有使用 buildroot 编译交叉编译链而是直接下载了一些平台所提供的，所以交叉编译链可以在 dl/toolchain-external-\* 目录下获取到。
   将它们提取到你的开发目录下即可。

## QEMU 模拟器

QEMU 模拟器功能非常强大，可以模拟几乎所有的主流架构。
虽然它的命令比较复杂，但是我们给出了一些基本的启动脚本（arm64、arm32、riscv64 和 x86-64），以方便读者使用。
脚本下载地址为 https://github.com/wang-borong/devenv/tree/main/qemu。

如果您想要进阶使用 QEMU 模拟器，比如想要模拟一个外设，但不知该如何添加命令。
那么，最好的办法是参考 [QEMU 的文档](https://www.qemu.org/docs/master/)。
注意文档版本。

## Linux 源码编译

1. 配置交叉编译环境。

   解压提取的交叉编译链到合适的地方，下面以 HOME 目录为例。
   配置环境变量。

   ```bash
   echo 'export PATH=$HOME/<xtool-dir>/bin:$PATH' >> ~/.bashrc # or .zshrc
   source ~/.bashrc
   ```

2. 进入开发目录，并解压内核源码。

3. 从 buildroot 中提取内核的配置文件。

   首先，运行 `grep LINUX_KERNEL_CUSTOM_CONFIG_FILE buildroot-config` 获取内核配置文件路径，buildroot-config 是从 https://github.com/wang-borong/devenv/tree/main/buildroot 所下载的 buildroot 配置。
   然后，到 buildroot 下提取内核配置文件即可。

4. 将提取到的内核配置文件重命名为 .config 到解压的内核源码目录中。
5. 如果需要配置内核运行 `make ARCH=<arch> CROSS_COMPILE=<arch>-linux-gnu- menuconfig`。
6. 配置完成后，运行 `make ARCH=<arch> CROSS_COMPILE=<arch>-linux-gnu- -j$(($(nproc) - 1))` 进行编译。

## 调试

至于调试，我们还是要依赖强大的 QEMU 模拟器。
QEMU 支持使用 GDB 调试，所要添加的命令选项为 `-s -S`。
如果您使用上述的 QEMU 启动脚本，那么就只需要传入这两个选项，即 `./start-qemu-*.sh -s -S`。

运行 QEMU 后，我们使用相关架构的 GDB 运行 vmlinux，即 `./<arch>-linux-gnu-gdb vmlinux`。

至此，我们已经进入 GDB 调试环境。
下面的就可以用 GDB 对内核进行调试了。
这里给出一个 [GDB 调试快速参考](https://users.ece.utexas.edu/~adnan/gdb-refcard.pdf)。
后续可能会出一个 GDB 调试文档。

另外，我们给出一个好用的 GDB 启动脚本 [gdb dashboard](https://github.com/cyrus-and/gdb-dashboard)。
