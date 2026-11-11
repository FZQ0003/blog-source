---
title: Campofinale系列项目部署心得
date: 2025-12-02 04:04:04
updated: 2026-02-25 00:00:00
tags:
  - campofinale
archive: true
---

{% note warning %}
该项目已无法部署。文章仅作参考。
{% endnote %}

## 前言

[Campofinale](https://git.teamstardust.org/Campofinale/Campofinale) 是一个由Team Stardust开发的实验性本地服务器项目，为某款工厂建造类游戏提供本地服务器实现。项目使用`C#`编写，基于`.NET`框架，目前仍在积极开发中。

这里只着重讲**如何部署**，而且做到**服务端与客户端分离**。如果你只有一台机器，那么直接照着项目的`README.md`做即可。

## 服务端部署

服务端只有`Campofinale`本体。

### 编译Campofinale

{% note info %}

可以直接去那边下[预编译包](https://git.teamstardust.org/Campofinale/Campofinale/releases)，下第一个出现的`7z`后缀文件然后找个地方解压就行。

装完就跳过这一部分吧。

{% endnote %}

安装[.NET SDK](https://dotnet.microsoft.com/en-us/download)，项目推荐使用`8.0`版本。

在Windows系统下，可以使用`WinGet`安装：

```cmd
winget install Microsoft.DotNet.SDK.8
```

对于别的系统，自己找教程吧。

你需要确保在装完之后，`dotnet`命令可用。下面的命令能够确认是否成功安装：

```cmd
dotnet --list-sdks
```

下载并解压源码包，或者使用`git`克隆仓库：

```cmd
git clone https://git.teamstardust.org/Campofinale/Campofinale.git
cd Campofinale
```

编译（参考项目中的`GitHub Workflows`）：

```cmd
dotnet restore
dotnet build --no-restore --configuration Release
```

复制/移动二进制程序：

```cmd
mkdir -p ../_build
mv Campofinale/bin/Release/net8.0 ../_build/Campofinale
```

{% note info %}

这里的二进制程序目录可能有所不同，以实际为准。

{% endnote %}

### 安装依赖和资源

按项目说明来：

* 安装[.NET Runtime](https://dotnet.microsoft.com/en-us/download)，注意这个跟SDK有区别，二者选其一；
* 安装[MongoDB](https://www.mongodb.com/try/download/community)，`MongoDB Server`必装，同时还有个可选的GUI工具`MongoDB Compass`方便查看数据库；
* 下载`Json`、`TableCfg`和`DynamicAssets`。

由于涉及到可能比较敏感的仓库名称，故不提供命令示例。

{% note info %}

`mitmproxy`是给客户端用的，服务端用不到。

{% endnote %}

### 修改配置文件

进入程序目录，先启动一次`Campofinale.exe`，然后找到并打开配置文件`server_config.json`：

```json
{
  "mongoDatabase": {
    "uri": "mongodb://localhost:27017",
    "collection": "Campofinale"
  },
  "dispatchServer": {
    "bindAddress": "127.0.0.1",
    "bindPort": 5000,
    "accessAddress": "127.0.0.1",
    "accessPort": 5000,
    "emailFormat": "@campofinale.ps"
  },
  "gameServer": {
    "bindAddress": "127.0.0.1",
    "bindPort": 30000,
    "accessAddress": "127.0.0.1",
    "accessPort": 30000,
    "useExternalAuthSdk": false,
    "externalAuthSdkUrl": ""
  },
  "serverOptions": {
    "defaultSceneNumId": 87,
    "maxPlayers": 20,
    "missionsEnabled": false,
    "giveAllItems": false,
    "disableLevelscripts": true,
    "useEncryption": false
  },
  "logOptions": {
    "packets": true,
    "packetWarnings": true,
    "packetBodies": false,
    "debugPrint": false
  }
}
```

作为服务端，建议把`127.0.0.1`改为**服务器的真实IP**，保证客户端能够访问到**两个Server**地址；同时开放涉及到的两个端口（`5000`和`30000`）。

{% note warning %}

你需要自行考虑安全性问题。我这边是用的Tailscale，毕竟又不需要提供服务。

{% endnote %}

英语好的话，你可以随便改配置。

{% note info %}

客户端会先访问`dispatchServer`进行登录和下载资源，然后服务端会返回给客户端`gameServer`信息，最后客户端访问`gameServer`成功后进入游戏。

同时，客户端会尝试和奇怪的地址通信，后面遇到了可以先忽略。

{% endnote %}

至此，服务端配置完成。

### 服务端指令

记得创建账号：

```text
account create <username>
```

## 客户端部署

### 安装相应资源

去项目Discord群（*自己找！*）找安装包，这个不单独提供；然后正常下载游戏资源即可，下完不要直接打开。

### 应用Patch

去项目Discord群下相关文件：

* `launcher.exe`
* `patch.dll`
* `我是游戏Beta.exe`

去游戏本体安装目录覆盖；把`launcher.exe`做个桌面快捷方式，好找。

以后就开`launcher.exe`了。

### 劫持并重定向相关流量

项目采用了`mitmproxy`方案，将本来应该和正经`dispatchServer`的通信转移到了咱们自己开的`Campofinale`服务端；然后咱们的服务端检查登录信息并下发了可用的`gameServer`，而这个`gameServer`还是咱们自己的服务端！因此重定向只需要考虑`dispatchServer`的地址和端口就行了。

这里其实想怎么弄都行（软路由什么的）。

{% note warning %}

你需要安装`cert`。一般来说，跑一遍`mitmproxy`之后，你的用户目录下会多出来一个新目录`~/.mitmproxy`，这个目录里面有需要的`cert`。

打开`mitmproxy-ca-cert.cer`，安装到`受信任的根证书颁发机构`存储区。不同系统做法不同。

{% endnote %}

编写相应脚本`script.py`：

```python
from mitmproxy import http

REQ_HOSTS = ["__________.com", "_________"]
DISPATCH_SERVER_HOST = "127.0.0.1"
DISPATCH_SERVER_PORT = 5000


def request(flow: http.HTTPFlow) -> None:
    condition = any(map(
        lambda _: _ in flow.request.pretty_url,
        REQ_HOSTS
    ))
    if condition:
        if flow.request.method == "CONNECT":
            return
        if "/get_latest_resources" in flow.request.pretty_url:
            return
        flow.request.scheme = "http"
        flow.request.cookies.update(
            {"OriginalHost": flow.request.host, "OriginalUrl": flow.request.url}
        )
        flow.request.host = DISPATCH_SERVER_HOST
        flow.request.port = DISPATCH_SERVER_PORT
```

我平时会用`uv`管理`Python`项目，所以这里我直接用`uv`了：

```cmd
uvx mitmproxy -s script.py
```

{% note warning %}

删了些敏感的东西，自己补上。

{% endnote %}

### 运行客户端

运行`launcher.exe`启动游戏。

邮箱：`<username>@randomemailformathere.whatyouwant`；密码随意。

## 总结

整体还算顺利，注意以下几点：

* 服务端：依赖装起来没？资源下载了没？两处IP和端口处理了没？
* 客户端：Patch没？脚本修改了没？
* 注意`dispatchServer`和`gameServer`的区别。

然鹅跑起来发现：我新手教程呢？

算了不管了。

作为一个实验性项目，Campofinale展现了社区的技术实力。虽然功能尚未完善，但基础的游戏体验已经可以实现。期待项目的后续发展！

<!-- 小羊，嘿嘿嘿🤤 -->
