---
title: 使用Rsync与Syncthing实现文件同步
date: 2024-05-10 20:55:19
tags:
  - file-sync
  - rsync
  - syncthing
comment_id: Rsync and Syncthing
---

## 前言

在本科毕业以后，手里的设备变多了，同时也需要在多台设备操作同一文件。这便引出新的问题：我需要以一种合适的方式在多台设备间同步文件。

<!-- more -->

举个例子，本科期间我的主力机是台笔记本，Windows系统；毕业以后配了台式机，Arch Linux系统；现在实验室那边也给整了台电脑，Windows系统；同时手机（Android系统）存储经常在满的边缘徘徊，需要不定期清理。

我的文件同步方案的需求如下：

* 足够简单；
* 自动同步，也可以手动同步；
* 可作为备份工具；
* 拒绝网盘类软件；
* 可以像以前的公文包那样不经过网络同步。

转了一圈，我看向了两款工具：一种是Linux标配的Rsync，另一种是跨平台的Syncthing。

## Rsync 实现文件同步

### Rsync 概述

Rsync是一个常用的Linux应用程序，可以在本地计算机与远程计算机之间，或者两个本地目录之间同步文件（但不支持两台远程计算机之间的同步），也可以当作文件复制工具，替代`cp`和`mv`命令。Rsync的最大特点是会检查发送方和接收方已有的文件，仅传输有变动的部分（默认规则是文件大小或修改时间有变动）[^1]。

[^1]: <https://www.ruanyifeng.com/blog/2020/08/rsync.html>

### Rsync 安装

一般Linux发行版都会标配这个工具，如果没安装也可以通过包管理器或者自行编译安装。  
但在Windows系统，就得考虑些歪门邪道了（bushi）。

目前我认为合适的方案[^2]：

* Cygwin等兼容层，但我更推荐[Msys2](https://www.msys2.org)，或者也可以试试在Git Bash里装；
* WSL；
* ~~干脆不用。~~

[^2]: <https://kaifeiji.cc/post/using-rsync-on-windows>

### Rsync 使用

Rsync有众多参数，我这边最常用的参数：

* `--verbose` `-v`：将结果输出到终端。
* `--archive` `-a`：递归同步&同步元信息（修改时间、权限等）。
* `--update` `-u`：若目标文件更新，则跳过该文件。
* `--dry-run` `-n`：模拟执行。

比如我想进行本地文件夹的双向同步（类似于先`git pull`再`git push`），可以输入以下命令，注意斜杠：

``` bash
rsync -auv remote/ local  # like git pull
rsync -auv local/ remote  # like git push
```

这玩意儿优点就是简单，也可以远程同步，缺点是得手动，需要自己想办法实现自动同步。

## Syncthing 实现文件同步

### Syncthing 概述

Syncthing是一个轻量级的点对点文件同步系统，速度很快，最重要的是支持NAT穿透[^3]。

[^3]: <https://zhuanlan.zhihu.com/p/103323536>

### Syncthing 安装

在[这里](https://syncthing.net/downloads)。

{% note warning %}
注意：安装后需要自行配置服务，过程见下面的链接。  
Windows可以在安装程序决定是否启动服务，反正我是选择手动。
{% endnote %}

### Syncthing 使用

[这篇文章](https://wiki.archlinux.org/title/Syncthing)详细地讲述了Syncthing配置过程，可惜纯英文。

简单来说就是：

* 启动后打开Web-GUI：[http://localhost:8384](http://localhost:8384)；
* 分别设置并添加设备ID、文件夹ID、文件夹路径、相关参数等；
* 根据网页说明进行配置。

![Syncthing Web-GUI截图](syncthing-screenshot-01.png)

第一次用会费点时间，配置好了就能自动同步了。  
我太懒了，你可以搜搜别的教程。

## 总结

目前我用Rsync进行本地文件夹的同步，用Syncthing通过网络对不同设备的文件夹进行同步和备份，真的太爽了。
