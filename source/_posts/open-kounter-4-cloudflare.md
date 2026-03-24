---
title: 在Cloudflare上部署Open Kounter
date: 2026-03-25 07:10:13
tags:
  - cloudflare
  - web
---


{% note info %}

没写完，先发个草稿，等有空了再完善一下。

{% endnote %}

## 前言

更新博客时关注到了[Open Kounter](https://github.com/Mintimate/open-kounter)这个项目。这玩意儿可以通过Serverless的方式部署在EdgeOne上，提供一个API接口来统计访问量。

兴致勃勃地点进部署页面，结果发觉是腾讯云换皮？！还要我实名认证，呃呃呃……

我太懒了。不过仔细想想，既然是Serverless的东西，而且我这博客是部署在Cloudflare Pages上面，Cloudflare也有Functions和KV存储这种东西，所以应该也能部署在Cloudflare上吧？于是就有了这篇文章。

## 部署方法

这俩虽然有些过于相似，不过直接干上去`101.0000%`会部署失败，然后你就只能看见个主页，然后一点就报错。

二者的主要差异在于：

* `Pages Functions`: 文件夹位于`/edge-functions`，而不是`/functions`。
* `Workers KV`: Cloudflare把变量放在`env`对象里，而EdgeOne直接放在全局作用域。

这就导致了部署方法的不同。对于Cloudflare，在部署之前我们需要先把`edge-functions`文件夹重命名为`functions`，然后想办法把`OPEN_KOUNTER`重定向到`env.OPEN_KOUNTER`。

直接替换的形式肯定是行不通的，因为文件中这个变量拉得到处都是。可以考虑在函数体的开头用`globalThis`：

```js
globalThis.OPEN_KOUNTER = env.OPEN_KOUNTER;
```

这样就能把`OPEN_KOUNTER`暴露在全局作用域了，简单省事。

考虑到每个文件中函数开头完全一致，我们可以找个特征，用`replace-in-file`这个工具来批量替换：

```sh
npx replace-in-file 'context;' 'context; globalThis.OPEN_KOUNTER = env.OPEN_KOUNTER;' 'functions/**/*.js'
```

最后的部署命令如下：

```sh
mv edge-functions functions && npx replace-in-file 'context;' 'context; globalThis.OPEN_KOUNTER = env.OPEN_KOUNTER;' 'functions/**/*.js' && npm run build
```

其它的步骤和EdgeOne一样。Enjoy！
