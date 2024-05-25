---
title: Pandoc + Markdown 调教记录
date: 2022-03-17 18:56:31
tags:
  - pandoc
  - markdown
comment_id: Pandoc Markdown
---

> 嘿嘿嘿，Markdown，嘿嘿嘿……

## 问题引入

个人非常喜欢VSCode的[GitHub Markdown Preview](https://marketplace.visualstudio.com/items?itemName=bierner.github-markdown-preview)插件，尤其是其中的预览与生成HTML功能。  
但是，如果看下生成后的文件……

<!-- more -->

原文件：

``` markdown
# F-QILIN

## 233

累了，毁灭罢。
```

生成的文件：

``` html
<!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>F-QILIN</title>
<!-- 第6行 -->
<!-- 巴拉巴拉一大堆 -->
<!-- 第1218行 -->
    </head>
    <body class="vscode-body vscode-light">
        <h1 id="f_qilin">F_Qilin</h1>
<h2 id="233">233</h2>
<p>累了，毁灭罢。</p>

    </body>
    </html>
```

有点不太直观，放点截图哈：

![开头](fxxk-vsc-01.png)

![中间](fxxk-vsc-02.png)

![结尾](fxxk-vsc-03.png)

有点不忍直视啊。  
合着这么大个文件，大部分都是直接套呗？

因此，我萌生了一个想法：有没有什么方案能让我自行生成网页呢？

## 生成原理

一般来讲也就两个部分：

* Markdown语法转HTML语法
* 将生成的body填入到模板中

关于语法转换，感觉很多工具都可以做到；  
至于模板，准备一个就行了。

因为以前安装过Pandoc，所以这次用Pandoc来~~一波带走~~自动化生成。

## Pandoc使用

> [Pandoc官方网站](https://pandoc.org/)  
> 关于css和模板，可参考[这里](https://vimalkvn.com/pandoc-markdown-to-html/)。

首先，安装Pandoc。自己装。

写个Markdown文件：

`document.md`

``` markdown
# 斯哈斯哈

## 测试A

以下为参数要求：

|        发射机参数         |          指标           |
| :-----------------------: | :---------------------: |
|       载波频率$f_0$       | $8.4\pm0.2\mathrm{MHz}$ |
|        频率稳定度         |      $\leq10^{-3}$      |
|       调幅指数$m_a$       |     $30\%\sim80\%$      |
| 输出功率 (负载$50\Omega$) |   $\geq50\mathrm{mW}$   |

|        接收机参数        |         指标         |
| :----------------------: | :------------------: |
|          灵敏度          | $\leq30\mathrm{dBM}$ |
|          通频带          | $\leq1\mathrm{MHz}$  |
| 输出功率 (负载$8\Omega$) | $\geq0.25\mathrm{W}$ |

> cue一下某课设

## 测试B

<!-- 嵌套围栏代码块不可用…… -->

<pre><code class="python">#!/usr/bin/python3

if __name__ == '__main__':
    print('Ohhhh')</code></pre>
```

然后直接开终端输入：

``` bash
pandoc document.md -o document.html
```

生成不带样式的`document.html`文件，打开：

![无样式输出](pandoc-01.png)

还不错哈，但是感觉好像是几十年前的界面……

使用`-s`参数，使用默认模板生成独立网页：

``` bash
pandoc -s document.md -o document.html
```

![默认模板输出](pandoc-02.png)

这回好多了，就这样放着也不错。  
不过，如果我想实现GitHub主题之类的效果呢？

比如，应用[github-markdown-css](https://github.com/sindresorhus/github-markdown-css)：

``` bash
pandoc -s document.md -c https://cdn.jsdelivr.net/npm/github-markdown-css@5.1.0/github-markdown-light.css -o document.html
```

效果……诶怎么没用了？  
开一下`F12`，发现除了引用的css以外，还有Pandoc默认样式。  
看来得改一下模板了。

## 模板修改

首先输出模板：

``` bash
pandoc -D html > template.html
```

看见一堆乱七八糟的东西，但是只需要改改就能来个大变样。

除了HTML以外，不难发现这些东西：

`template.html`

``` html
<!-- ... -->
$for(author-meta)$
  <meta name="author" content="$author-meta$" />
$endfor$
$if(date-meta)$
  <meta name="dcterms.date" content="$date-meta$" />
$endif$
<!-- ... -->
```

这个`for`啊`if`啊大家懂得都懂，照葫芦画瓢就行。  
那这些东西是如何起作用的？

在`document.md`头部加入以下内容：

``` text
---
title: 我是标题
author: 
    - 作者A
    - 作者B
    - 作者C
date: 2022-03-17
---
```

然后：

``` bash
pandoc -s document.md -o document.html
```

![带封面的默认模板输出](pandoc-03.png)

头部支持YAML格式。

接下来就可以按照自己的想法来啦！  
以下是我改的模板，支持以下内容：

* [github-markdown-css](https://github.com/sindresorhus/github-markdown-css)
* [Highlight.js](https://github.com/highlightjs/highlight.js)
* [MathJax](https://github.com/mathjax/MathJax)
* 夜间模式
* 是否显示头部（在头部定义`show-header: true`）

`template-md.html`（注：声明了中文`lang="zh-CN"`）

``` html
<!DOCTYPE html>
<html lang="zh-CN">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
$for(author-meta)$
  <meta name="author" content="$author-meta$">
$endfor$
$if(date-meta)$
  <meta name="dcterms.date" content="$date-meta$">
$endif$
$if(keywords)$
  <meta name="keywords" content="$for(keywords)$$keywords$$sep$, $endfor$">
$endif$
$if(description-meta)$
  <meta name="description" content="$description-meta$">
$endif$
  <title>$if(title-prefix)$$title-prefix$ – $endif$$pagetitle$</title>
  <meta name="color-scheme" content="light dark">
  <link rel="stylesheet" href="https://lib.baomitu.com/github-markdown-css/5.5.1/github-markdown.css">
  <style>
    body {
      box-sizing: border-box;
      min-width: 200px;
      max-width: 980px;
      margin: 0 auto;
      padding: 45px;
    }
    @media (max-width: 767px) {
      .markdown-body {
        padding: 15px;
      }
    }
    @media (prefers-color-scheme: dark) {
      body {
        background-color: #0d1117;
      }
    }
  </style>
$for(css)$
  <link rel="stylesheet" href="$css$">
$endfor$
$for(header-includes)$
  $header-includes$
$endfor$
  <link rel="stylesheet" href="https://lib.baomitu.com/highlight.js/11.7.0/styles/github.min.css">
  <link rel="stylesheet" media="(prefers-color-scheme: dark)" href="https://lib.baomitu.com/highlight.js/11.7.0/styles/github-dark.min.css">
  <script src="https://lib.baomitu.com/highlight.js/11.7.0/highlight.min.js"></script>
  <script>
    hljs.configure({languages: ['plaintext']});
    hljs.highlightAll();
  </script>
$if(math)$
  <script type="text/javascript" id="MathJax-script" async
    src="https://lib.baomitu.com/mathjax/3.2.2/es5/tex-mml-chtml.js">
  </script>
$endif$
</head>

<body>

<article class="markdown-body">

$for(include-before)$
$include-before$
$endfor$
$if(show-header)$
<pre><code>$if(author)$Author: $for(author)$$author$$sep$, $endfor$$endif$
$if(date)$Date: $date$$endif$
</code></pre>
$endif$
$body$
$for(include-after)$
$include-after$
$endfor$

</article>

</body>

</html>
```

使用时，需开启MathJax并关闭默认代码高亮：

``` bash
pandoc -s document.md --template template-md.html --no-highlight --mathjax -o document.html
```

如果不需要什么功能，把相关语句删了即可。

最终效果（添加参数`-M show-header`）：

![自定义模板浅色模式输出](pandoc-04.png)

![自定义模板深色模式输出](pandoc-05.png)

## 自动化构建

总是输命令太麻烦了，直接上自动化：

`build.sh`

``` bash
#!/bin/bash

TEMPLATE="template-md.html"
SOURCE_DIR="source"
BUILD_DIR="build"
# EXTRA_ARGS="-M show-header"

function traverse() {
    for file in $(ls $1); do
        if [ -d "$1/$file" ]; then
            traverse "$1/$file"
        else
            build "$1/$file"
        fi
    done
}

function build() {
    output_file="$BUILD_DIR/${1##*$SOURCE_DIR/}"
    echo "Generating $output_file..."
    if [ "${1##*.}" == "md" ]; then
        pandoc -s "$1" --template "$TEMPLATE" --no-highlight --mathjax $EXTRA_ARGS -o "${output_file%.*}.html"
    else
        cp "$1" "$output_file"
    fi
}

rm -r "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
traverse "$SOURCE_DIR"
echo "Done!"
```

累了，自己读吧。

就像是hexo的生成网页一样，你也可以做到，快去试试吧！

## 总结

也没啥好总结的，就是多了一种方法罢了。

> [示例中最后生成的`document.html`](document.html)
