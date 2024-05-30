---
title: 在Linux下进行Live3D直播
date: 2024-05-15 19:04:07
tags:
  - linux
  - live
index_img: /linux-live3d/im-linux-user.png
banner_img: /linux-live3d/im-linux-user-2.png
---

## 前言

我在自己的新电脑上装了个Arch Linux发行版，接下来就该各种折腾啦。  
最近在亲友练手的3D模型的基础上做了个能用于直播的VRM模型，所以想看看在Linux下有没有可用的直播方案。  
然而，很遗憾。  
好，那就折腾plusplus！

<!-- more -->

我的需求：

* **完全免费**；
* 至少能展示VRM模型；
* 至少能捕捉面部，动捕更好；
* 能通过OBS直播。

{% note warning %}
本文仅适用于Linux发行版，并假设读者已经在**实体机**安装了Linux。  
如果您只是想体验Linux，强烈建议使用虚拟机或WSL。  
不建议套娃运行软件，如在Linux虚拟机运行Wine等。
{% endnote %}

{% note info %}
截至文章发布前，我仍未找到较好的一站式解决方案。  
如果你发现了更好的解决方案，欢迎评论。  
~~所以Warudo什么时候支持Linux啊~~
{% endnote %}

## VRigUnity 实现动捕

[VRigUnity](https://github.com/Kariaro/VRigUnity)是一款基于MediaPipe的软件，可以展示VRM模型、通过摄像头捕捉动作、发送和接收VMC（VirtualMotionCapture）协议数据等等。

![VRigUnity截图](vrigunity-01.png)

软件是全英文的，你可能需要一些英文功底。

一些有用的东西：

* 鼠标可以移动画面。
* `Settings - Model - Select Model`自定义VRM模型。
* `Settings - Camera`修改摄像头参数，设置背景，~~也可以开启虚拟摄像头~~。
* `Settings - Advanced - UI Settings - Anti Aliasing`设置抗锯齿。
* `Settings - Bones`选择想要接受捕捉的骨骼。
* `Start / Stop Camera`控制摄像头。

如果没什么别的需求，只用这款软件直播就足够了，~~直接用虚拟摄像机就好~~可以用绿幕+抠图。

{% note warning %}
~~使用虚拟摄像机相关功能前，需要先安装`v4l2loopback`包。不同发行版安装方式略有差异。~~  
截至文章发布前，软件的虚拟摄像机功能仅支持Windows。  
Linux功能不完整，只能做到配置（安装）虚拟摄像机，无法传输画面。
{% endnote %}

{% note info %}
手动配置虚拟摄像机[^1]：

``` bash
sudo modprobe v4l2loopback card_label="VRigUnity Video Capture" exclusive_caps=1
v4l2-ctl --list-devices  # 查看结果
# sudo modprobe -r v4l2loopback  # 移除所有虚拟摄像机
```

{% endnote %}

[^1]: <https://wiki.archlinux.org/title/V4l2loopback#Loading_the_kernel_module>

软件也有一些缺点，比如没法使用BlendShape。  
但是没有关系，我们可以和其他软件联动！

## 使用 Windows 软件 (以 Warudo 为例)

Windows下方案有很多，比如[VSeeFace](https://www.vseeface.icu/)、[Live3D](https://live3d.io/)、[VRChat](https://hello.vrchat.com/)等等。在这里推荐另一款软件[Warudo](https://warudo.app/)，用着很爽。

问题来了，上述软件都是Windows软件，Linux没法直接运行，怎么办？

我觉得可以请出大名鼎鼎的[Wine](https://www.winehq.org/)兼容层了。

### Proton (Wine) 兼容层设置

Warudo是在Steam发行的，因此我建议用Valve开发的基于Wine的[Proton](https://github.com/ValveSoftware/Proton)兼容层或者用[Proton GE](https://github.com/GloriousEggroll/proton-ge-custom)。

Proton可以自行安装，也可以通过Steam的兼容性设置安装。这个可以参考Steam Deck相关教程[^2]。

[^2]: <https://cn.linux-console.net/?p=12468>

使用Proton 7-8可以直接运行Warudo；但在Proton 9，由于默认开启了NVAPI支持，直接运行可能会报错。因此，如果使用新版Proton，需要在Steam中设置启动参数：

``` text
PROTON_DISABLE_NVAPI=1 %command%
```

> 我建议各位如果用Linux发行版作为主力系统，CPU一定要选带核显的，不然后期容易哭死。

### VMC 设置

如果直接在软件里调用摄像头，会出现一些令人难蚌的问题。看图说话。

{% gi 2 2 %}
  ![MediaPipe方案摄像头画面](warudo-wine-mediapipe.png)
  ![OpenSeeFace方案终端输出](warudo-wine-openseeface.png)
{% endgi %}

使用MediaPipe捕捉并打开摄像头显示，发现摄像头画面异常；使用OpenSeeFace发现无法读取（提示No Frame）。  
摄像头本身是正常的，而且如果使用虚拟摄像头等方法，问题依然存在。个人推测是兼容层的问题。  
以及，主机与Wine程序有一层可悲的厚障壁（大概），除网络通信外，常规通信手段不可用。

我的方案是：在VRigUnity进行动捕的基础上，通过VMC将数据传到Warudo。

首先，在Warudo中重新配置追踪模板，选择VMC模板，一路配置即可，注意记一下端口号，默认为`39539`。

{% note warning %}
如果模型的嘴只用了BlendShape，需要将“唇形同步”选项设置为“永远开启”。
{% endnote %}

然后在VRigUnity中设置相关参数：

* 将`Settings - Advanced - VMC Settings - VMC Sender`端口号设置为`39539`或自行设置的端口号；
* 建议关闭`Settings - Advanced - UI Settings - Show Model`，并调低窗口大小，以节约资源。

![VRigUnity VMC设置](vrigunity-02.png)

配置完成，Enjoy！

![Warudo截图（角色Shipilka）](warudo-01.png)

<!-- 呜呜，害羞羞啦 -->

## NDI 传输

现在还有最后一座大山摆在面前：如何将画面传给OBS。

除了最简单的绿幕+抠图以外，Warudo内置了三种画面输出方式[^3]：

* Spout
* NDI
* 虚拟摄像头

[^3]: <https://docs.warudo.app/docs/assets/camera#output>

这三种方式均支持透明背景输出。其中，[Spout](https://spout.zeal.co/)是适用于Windows的快速实时路由；[NDI](https://ndi.video/)（Network Device Interface）是一种通过网络传输视频的接口协议。

由于那层可悲的厚障壁，通过NDI传输透明背景画面也许是最好的办法了。

直接安装[obs-ndi](https://github.com/obs-ndi/obs-ndi)插件，然后开启相关设置即可。

{% note warning %}
经测试，使用NDI传输高分辨率画面会产生明显的卡顿和延迟，即使是本机到本机也是如此！  
建议缩小输出画面大小、在OBS中修改带宽等设置或者使用绿幕+抠图的方式采集画面。
{% endnote %}

{% note warning %}
使用该插件前，需要先安装NDI Runtime，安装方式见GitHub Wiki。  
个人建议手动安装到`/usr/local`目录，Arch用户也可以找AUR包`ndi-sdk`。  
另外，如果手动编译安装，需要**下载正确版本的SDK**，否则会报错。
{% endnote %}

{% note warning %}
该插件需要开启Avahi服务：

``` bash
# sudo systemctl enable avahi-daemon.service  # 永久启用
sudo systemctl start avahi-daemon.service
```

另外，如果在不同设备间传输，可能需要配置防火墙，参考Wiki即可。
{% endnote %}

{% note info %}
我建议大家通过包管理器安装OBS插件；如果手动安装，最好安装在用户目录。

在用户目录安装OBS插件：

1. 在`~/.config/obs-studio`目录下新建`plugins`文件夹。
2. 打开插件压缩包。注意deb包也可以作为压缩包打开，但需要打开内部`data.tar*`压缩包。
3. 检查压缩包内容，根据包结构将文件复制到指定位置。

如果压缩包结构是这样的（第一层通常为插件名）：

``` text
<plugin-name>
├─bin
│  └─64bit
│  │  ├─*.so
│  │  └─...
│  └─...
├─data
│  ├─locale
│  │  └─...
│  └─...
└─...
```

请直接解压到`~/.config/obs-studio/plugins`文件夹。如果压缩包内第一层不是插件名，你可能需要先新建一个文件夹再解压。

如果压缩包结构是下面这样：

``` text
usr
├─lib
│  └─x86_64-linux-gnu
│  │  └─obs-plugins
│  │     ├─*.so
│  │     └─...
│  └─...
├─share
│  └─obs
│     └─obs-plugins
│       └─<plugin-name>
│         ├─locale
│         │  └─...
│         └─...
└─...
```

请参考第一种结构新建对应文件夹，然后把压缩包内`usr/lib/x86_64-linux-gnu/obs-plugins`下所有内容解压到`~/.config/obs-studio/plugins/<plugin-name>/bin/64bit`目录，把`usr/share/obs/obs-plugins/<plugin-name>`下所有内容解压到`~/.config/obs-studio/plugins/<plugin-name>/data`目录。

如果你的系统不是64位x86系统，目录会有所变化，但大差不差，自己解决吧。

这条说明可能会作为新文章发布。
{% endnote %}

## 总结

经过这么一顿折腾，终于实现了一套Live3D直播流程，可喜可贺啊！  
话说回来，这东西还是过于折腾了，而且Arch提供的OBS没有浏览器和Websocket功能，想直播还有很长的路要走啊……

{% note success %}
通过手动编译安装的方法，笔者的OBS具有上述功能。  
但由于Wayland不支持直接监听键盘鼠标输入，曾经在Windows用的很爽的input-overlay插件只能监听手柄输入了，哭哭。  
等罢。
{% endnote %}
