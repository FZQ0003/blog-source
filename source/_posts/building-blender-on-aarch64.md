---
title: 在AArch64/ARM64架构平台编译Blender
date: 2021-10-27 22:54:54
tags:
  - arm
  - blender
  - compile
index_img: /building-blender-on-aarch64/my-jetson-is-hot.png
banner_img: /building-blender-on-aarch64/my-jetson-is-hot.png
---

{% note warning %}
该文章已过时，请等待更新。
{% endnote %}

白嫖了一台Jetson Nano，想试试这玩意儿的运算能力，正好也在玩Blender，所以就想在板子上跑跑。  
然而，官方镜像所用Ubuntu 18.04只有2.79b。  
我都已经用2.93了啊喂！  
于是，故事开始了……

<!-- more -->

> 很可怕吗，是的很可怕[……](https://www.bilibili.com/video/BV1Fr4y1w7Ls?t=4m13s "?")
> [](https://www.bilibili.com/video/BV1cD4y1S7Yx "!")

## 程序下载

如果你不想编译，请下载这个文件然后跌跌撞撞奔向评论区(?)：

* [blender-aarch64-2.93.5.tar.xz](https://cn-zz-bgp-1.natfrp.cloud:63134/files/blender/blender-aarch64-2.93.5.tar.xz)

食用方法：

* 将压缩包内`blender-aarch64-2.93.5`文件夹解压到你想要的位置。
* 内含`config`和`cycles kernel cache`，可解压到`$HOME`目录。

## 当前系统环境

* 开发板：Jetson Nano 2GB。
* CPU架构：ARMv8 (AArch64)。
* 搭载系统：Ubuntu 18.04.6 LTS。
* CUDA：10.2

## 编译前准备工作

来看下Blender对编译器的要求[^1]：

[^1]: <https://wiki.blender.org/wiki/Building_Blender#Compiler_Versions>

| 编译器                | 官方使用版本 | 最低支持版本 |
| --------------------- | ------------ | ------------ |
| Linux GCC             | 9.3.1        | **9.3**      |
| Linux Clang           | -            | 8.0          |
| macOS Xcode           | 11.5         | 10.0         |
| Windows Visual Studio | 2019         | 2017         |

除此以外，Blender的某些依赖需要根据情况修改编译配置，以及更高版本的编译工具。在此直接列个表好了：

| 依赖         | 问题 / 额外要求                                      |
| ------------ | ---------------------------------------------------- |
| OpenSSL      | `-m64`参数不可用                                     |
| TBB          | `-mrtm`参数不可用；未更新代码                        |
| OpenEXR      | `CMake` >= 3.12[^2]                                  |
| Embree       | 能够访问GitHub的强力网络                             |
| SQLite       | 合并最新`config.guess`                               |
| GMP          | `--enable-fat`参数与`--disable-assembly`参数冲突[^3] |
| OpenAL       | 需要`libpulse-dev`                                   |
| Theora       | 合并最新`config.guess`                               |
| Mesa         | `Meson` >= 0.52.0[^4]                                |
| OIDN         | 不支持Linux ARM[^5]                                  |
| ISPC         | OIDN的依赖项                                         |
| 某些其他依赖 | 没有对AArch64的判断                                  |

[^2]: <https://github.com/AcademySoftwareFoundation/openexr/blob/master/INSTALL.md>
[^3]: <https://gmplib.org/manual/Build-Options>
[^4]: <https://docs.mesa3d.org/meson.html>
[^5]: <https://github.com/OpenImageDenoise/oidn/issues/125>

<!--

| ISPC             | 需要`libncurses5-dev`及针对ARM的`libc6-dev-*-cross` |
| OpenImageDenoise | 不支持Linux ARM                                     |

[^openexr]: https://qiita.com/syoyo/items/c8bcbaa095839122d6c8

-->

太难受了，好在我在`developer.blender.org`找到了一个针对aarch64的commit[^6]，就在此基础上修改好啦。

[^6]: <https://developer.blender.org/D10958>

另外，如果需要添加CUDA支持，需要正确配置合适版本的GCC[^7]。

| CUDA 版本        | GCC 最高支持版本 |
| ---------------- | ---------------- |
| 11.1, 11.2, 11.3 | 10               |
| 11               | 9                |
| 10.1, 10.2       | 8                |
| 9.2, 10.0        | 7                |
| 9.0, 9.1         | 6                |
| 8                | 5.3              |
| 7                | 4.9              |
| 5.5, 6           | 4.8              |
| 4.2, 5           | 4.6              |
| 4.1              | 4.5              |
| 4.0              | 4.4              |

[^7]: <https://stackoverflow.com/questions/6622454/cuda-incompatible-with-my-gcc-version>

哦对了，因为众所周知的原因，可能需要**非常手段**来解决下载速度慢的问题。

可能额外需要**32G**左右的空间。

### 检查并安装新版编译工具

不需要安装Clang，在编译依赖的时候会自动编译Clang。  
另外，由于我的开发板支持CUDA，所以我会一并配置CUDA相关选项，**还请不要无脑复制**。

检查编译工具版本：

``` bash
gcc --version
cmake --version
meson -v
```

新建文件夹用于存放源码：

``` bash
mkdir src && cd src
```

安装CMake：

``` bash
wget https://github.com/Kitware/CMake/releases/download/v3.21.3/cmake-3.21.3-linux-aarch64.tar.gz
tar -zxf cmake-3.21.3-linux-aarch64.tar.gz
sudo cp -fr cmake-3.21.3-linux-aarch64/ /usr/local/cmake-3.21.3
```

编译/安装GCC[^8]：

``` bash
sudo apt-get install libgmp-dev libmpfr-dev libmpc-dev libisl-dev
```

``` bash
wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-11.2.0/gcc-11.2.0.tar.xz
tar -Jxf gcc-11.2.0.tar.xz
mkdir gcc-build && cd gcc-build
../gcc-11.2.0/configure --prefix=/usr/local/gcc-11.2.0 --enable-checking=release --enable-languages=c,c++ --disable-multilib
make -j4
sudo make install
```

[^8]: <https://www.cnblogs.com/windtail/p/8317285.html>

安装Meson：

``` bash
wget https://github.com/mesonbuild/meson/releases/download/0.59.2/meson-0.59.2.tar.gz
tar -zxf meson-0.59.2.tar.gz
sudo cp -fr meson-0.59.2/ /usr/local/meson-0.59.2
sudo ln -s /usr/local/meson-0.59.2/meson.py /usr/local/bin/meson
```

配置环境（这里写成了一个shell，便于以后调用）：

``` bash
#!/bin/bash

CUDA_HOME=/usr/local/cuda-10.2
GCC_HOME=/usr/local/gcc-11.2.0
CMAKE_HOME=/usr/local/cmake-3.21.3

CUDA_LIB=$CUDA_HOME/targets/aarch64-linux/lib
GCC_LIB=$GCC_HOME/lib/gcc/aarch64-unknown-linux-gnu/11.2.0:$GCC_HOME/lib64:$GCC_HOME/libexec/gcc/aarch64-unknown-linux-gnu/11.2.0

export CUDA_HOME
export PATH=$CUDA_HOME/bin:$GCC_HOME/bin:$CMAKE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_LIB:$GCC_LIB:$LD_LIBRARY_PATH
```

替换默认GCC：

``` bash
sudo update-alternatives --install /usr/bin/cc cc /usr/local/gcc-11.2.0/bin/gcc 30
sudo update-alternatives --install /usr/bin/c++ c++ /usr/local/gcc-11.2.0/bin/g++ 30
```

最后再检查一次版本：

``` bash
gcc --version
cmake --version
meson -v
```

为CUDA设置GCC（可选）：

``` bash
ln -s /usr/bin/gcc-7 /usr/local/cuda-10.2/gcc
ln -s /usr/bin/g++-7 /usr/local/cuda-10.2/g++
```

### 下载依赖（可选）

可以下载已经编译好的库，也可以下载源码包自己编译。

当然，你也可以通过在Blender源码目录内运行`make deps`来下载并编译依赖，但是下载过程太难受了。

下载编译好的库（强烈推荐）：

> 搭了个小服务器，如果网站挂了，请联系我。

``` bash
wget https://cn-zz-bgp-1.natfrp.cloud:63134/files/blender/blender-prebuilt-lib-aarch64-2.93.tar.xz
tar -Jxf blender-prebuilt-lib-aarch64-2.93.tar.xz
```

从官方下载依赖源码：

``` bash
wget https://download.blender.org/source/blender-with-libraries-2.93.0.tar.xz
mkdir -p build_linux/deps/
tar -Jxf blender-with-libraries-2.93.0.tar.xz -C build_linux/deps/ packages
```

由于接下来会修改依赖，所以要下载额外的依赖源码。

下载额外依赖源码：

``` bash
wget https://cn-zz-bgp-1.natfrp.cloud:63134/files/blender/blender-extra-libraries-aarch64-2.93.tar.xz
tar -Jxf blender-extra-libraries-aarch64-2.93.tar.xz -C build_linux/deps/
```

### 下载Blender源码

这里用的是2.93.5的源码：

``` bash
wget https://download.blender.org/source/blender-2.93.5.tar.xz
tar -Jxf blender-2.93.5.tar.xz
```

### 修改源码

下载补丁文件：

``` bash
wget https://cn-zz-bgp-1.natfrp.cloud:63134/files/blender/patch_2_93_5_01.diff
```

将补丁应用于源码：

``` bash
patch -d blender-2.93.5 -p1 < patch_2_93_5_01.diff
```

## 编译依赖（可选）

如果已经下载了编译好的库，请跳过这一步。

使用apt下载依赖中的依赖：

``` bash
sudo apt-get install libpulse-dev libncurses5-dev
```

> 我忘了是否需要libncurses5-dev了，以后测试完补上。

``` bash
sudo apt-get install libpulse-dev libncurses5-dev rhash libc6-dev-armhf-cross libc6-dev-i386-cross libc6-dev-i386-amd64-cross
```

<!--

> 因系统中安装了部分依赖，故命令中没有体现。  
> 关于ISPC的依赖：
> 
> * https://github.com/ispc/ispc/blob/main/.travis.yml#L62
> * https://github.com/ispc/ispc/blob/main/.travis.yml#L65

针对`OpenImageDenoise`创建空文件夹：

;``` bash
mkdir -p build_linux/deps/Release/openimagedenoise/include/
mkdir -p build_linux/deps/Release/openimagedenoise/lib/
;```

注释 + 代码块 + 高亮 = 灾难

-->

编译：

``` bash
cd blender-2.93.5
make deps
```

需要等很长很长时间（我的开发板用了一天左右），而且容易出现奇奇怪怪的错误。

## 编译Blender

这里使用CMake中的CCMake工具编译：

``` bash
cd ..
mkdir blender-build && cd blender-build
ccmake ../blender-2.93.5
```

按`c`进行第一次配置，然后会多出来一堆选项，根据英文描述和实际需要修改即可。以下选项仅供参考：

| 选项                      | 个人修改值                            |
| ------------------------- | ------------------------------------- |
| CYCLES_TEST_DEVICES       | `CUDA`                                |
| WITH_CYCLES_CUDA_BINARIES | `ON`                                  |
| WITH_OPENIMAGEDENOISE     | `OFF`                                 |
| CUDA_HOST_COMPILER        | `/usr/bin/gcc-7`                      |
| CUDA_SDK_ROOT_DIR         | `/usr/local/cuda-10.2/samples/common` |

如果没看到相关选项，请重新按`c`配置一遍或按`t`切换到高级选项；每次修改选项后需要再次配置，确认无误后可以按`g`生成Makefile。

> 有些选项我忘了，以后补上。

最后编译即可。注意：如果内存不大，**最好不要使用`-j`参数！**

``` bash
make
make install
```

编译完成后，可在`./bin`目录找到文件。

## 后期打包与测试

只需要将`./bin`目录里的所有文件打包分发即可。

实机测试：

![实机测试](blender-aarch64-final-01.png)

> 如果使用SSH X11转发，请使用`-Y`参数。

## 结语

很不容易，断断续续整了差不多半个月，而且其中还要应付考试……  
人麻了，就这样。  
如果之后出现问题再补吧。
