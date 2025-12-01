---
title: GRUB主题构建指南
date: 2025-10-09 05:17:17
tags:
  - grub
  - theme
index_img: /grub-theme-guide/preview-1080p.jpg
banner_img: /grub-theme-guide/preview-1080p.jpg
---


## 前言

想必各位Linux用户都用过GRUB（GRand Unified Bootloader）。GRUB不仅功能丰富，而且还可以自定义主题。我们可以在网上挑选心仪的主题，然后下载下来，确认一下`theme.txt`路径，就可以用了。

我发现，一部分GRUB主题同质化明显；而且像边框之类的素材呈现形式非常底层，基本上是一堆像素图片，可能只是颜色不同。

一个好的主题应体现在背景与素材配色的统一。然而，背景容易修改，但其它素材对于用户来说通常难以修改（至少需要理解素材内容）；同时，计算部件的位置大小通常也具有挑战性。

因此，本文着重于素材构建及部件参数计算，尝试不参照现有主题，从零开始构建一个全新的GRUB主题。

有关GRUB主题的信息，可以访问[这篇文档](https://www.gnu.org/software/grub/manual/grub/html_node/Theme-file-format.html)。

{% note primary %}

在找实战环节吗？我还在咕咕咕。

{% endnote %}

## 主题部件分析

一个主题主要包含以下元素：

* 标题
* 背景
* 启动项菜单栏
* GRUB终端
* 额外部件（图片、文字、进度条等）

这些元素主要是通过`theme.txt`定义的。下文在分析元素的同时，也会贴上`theme.txt`示例，作为参考。

{% note warning %}

各字段具体值请参考GRUB文档。

{% endnote %}

### 标题

```yaml
title-text: "GNU GRUB 2"
#title-font: "Unifont Regular 16"
title-color: "#FFFFFF"
```

只是一行文字。实际应用中，我更倾向于禁止显示（设置`title-text: " "`）

#### 字体

`*.pf2`后缀（PFF2 font format）。参考[这篇文章](https://senzyo.net/2020-12/)。

我找到了一个和GRUB相性极好的[像素字体](https://github.com/TakWolf/fusion-pixel-font)，可以从[这里](https://github.com/FZQ0003/grub-theme-cyankylin/blob/master/src/fusion-pixel-12px-monospaced-24.pf2)下载使用（字体在`theme.txt`中的值为`"Fusion Pixel 12px M latin Regular 24"`）。

{% note info %}

如果将自定义字体文件放入主题文件夹，那么在使用`grub-mkconfig`生成配置时，会自动加载这个字体。如果只有一份自定义字体，这份字体将成为默认字体，可以不必设置`font`字段。如果想设置初始的`Unifont Regular 16`字体，反而需要设置。

对于`ventoy`，需要手动注册自定义字体。在`ventoy.json`中修改以下内容：

```json
{
  "theme": {
    "file": "/path/to/theme.txt",
    "fonts": [
      "/path/to/custom-font.pf2"
    ]
  }
}
```

{% endnote %}

#### 颜色

以下值是等价的：

* `"#66CCAA"` (HTML-style)
* `"#6CA"` (HTML-style)
* `"102, 204, 170"` (RGB)
* `"mediumaquamarine"` (SVG 1.0 color names)

### 背景

```yaml
desktop-image: "background.jpg"
desktop-color: "#000000"
#desktop-image-scale-method: "stretch"
#desktop-image-h-align: "center"
#desktop-image-v-align: "center"
```

这个比较简单，根据目标分辨率构建对应分辨率的背景图片即可。

{% note info %}

对于纯色背景，可以使用`1*1`的图片（对！只有一个像素），GRUB会自动拉伸图片；或者直接在`theme.txt`文件设置`desktop-color`字段。

对于重复性较强的背景，如果需要考虑不同分辨率的兼容性，可以在`theme.txt`文件设置`desktop-image-scale-method: "crop"`字段；如果某侧存在必须要显示的内容，可以将上述字段改为`"fitwidth"`或`"fitheight"`，并配合`desktop-image-h-align`或`desktop-image-v-align`字段。

如果你打算写个针对不同分辨率构建不同背景的脚本，可以不考虑特定分辨率的兼容性，毕竟目标机器就那一种分辨率。

{% endnote %}

### 启动项菜单栏

```ruby
+ boot_menu {
  #visible = true

  left = 10%
  top = 25%
  width = 80%
  height = 45%

  menu_pixmap_style = "menu_*.png"

  #item_font = "Unifont Regular 16"
  item_color = "#CCCCCC"
  item_pixmap_style = "item_*.png"
  item_height = 24
  item_spacing = 12
  item_padding = 8

  #selected_item_font = "inherit"
  selected_item_color= "#FFFFFF"
  selected_item_pixmap_style = "select_*.png"

  icon_width = 32
  icon_height = 32
  #item_icon_space = 8

  scrollbar = true
  #scrollbar_width = 16
  #scrollbar_frame = "scrollbar_*.png"
  scrollbar_thumb = "scrollbar_thumb_*.png"
  #scrollbar_thumb_overlay = false
  #scrollbar_slice = "east"
  ##scrollbar_left_pad = 0
  ##scrollbar_right_pad = 0
  #scrollbar_top_pad = 8
  #scrollbar_bottom_pad = 8
}
```

启动项菜单栏用于显示GRUB各启动项，包含若干样式：

* 菜单栏边框样式：遵循`Styled Box`样式；
* 启动项边框样式：包含未选中和选中样式，遵循`Styled Box`样式；
* 图标：需要将各个发行版图标存至`icons/`目录，只能复制别人的或手搓；
* 滚动条样式：遵循`Styled Box`样式。

此外，还需要控制菜单在屏幕中的显示位置和大小。

{% note danger %}

请注意全局配置和部件内部配置写法的区别！错误的写法会导致无法载入主题！

{% endnote %}

#### 位置与大小

```py
+ boot_menu {
  # ...
  top = 50%
  left  = 25%
  height = 270  # 1080*0.25
  width = 50%
  # ...
}
```

支持绝对值（像素）、百分比值（相对于目标分辨率）和二者混合（如`10%+250`、`80%-500`）。

例如，如果你设置了上述参数，那么在`1920*1080`的分辨率下，菜单栏将水平居中，上边缘与屏幕中心齐平；占据50%屏幕宽和25%屏幕高，如下：

![位置大小示意图](size-1.png)

而在其它分辨率下，菜单栏的高是固定值，占270像素，其它参数将动态适配屏幕分辨率。

因此，如果你将一些UI部件素材整合进背景图片中，你需要根据UI部件的情况严格计算UI内元素的位置大小，并且计算的参数**仅适用于一组相同比例的分辨率**；如果部件与背景是分离的，情况就没那么遭了，有一些误差也无所谓。比如，对于我的[自制主题](https://github.com/FZQ0003/grub-theme-cyankylin)，当目标分辨率为`1024*768`时，呈现形式如下：

![1024*768分辨率预览图](preview-1024.jpg)

可见，此时一些部件与背景图内部元素出现了少许错位。因此，在设计时应该考虑周全。

#### 菜单栏边框样式

```ruby
+ boot_menu {
  # ...
  menu_pixmap_style = "menu_*.png"
  # ...
}
```

如果想在不修改背景的情况下对菜单栏进行美化，就需要自行绘制素材，并设置上述样式字段。所有边框类样式都遵循`Styled Box`格式。

`Styled Box`可以说是各样式中最核心的东西了。我认为这部分最适合自动化生成，出于以下几点原因：

* 像素总数很小，`16*16`等大小完全能满足需求；
* 边框基本为方形或圆角样式，算法层面实现简单；
* 边框基本是轴对称和中心对称的，这样只需要处理4个边框素材即可。

在GRUB中，一种边框样式由[⑨](https://www.bilibili.com/video/BV1rs41197Xn/)张图片表示（以`menu_*.png`为例）：

```text
menu_nw.png  menu_n.png  menu_ne.png
menu_w.png   menu_c.png  menu_e.png
menu_sw.png  menu_s.png  menu_se.png
```

文件的后缀代表了所属方位（如`nw`是`northwest`的缩写，表示左上角）。

图片内容参考如下。

![边框样式图片](box-info-1.png)

在渲染时，边框的四角会**原封不动**地渲染；而四个垂直方向的素材会根据边框的长宽大小进行**纵向或横向拉伸**（只拉伸一个方向）；中心素材会被拉伸到边框的大小。因此，最终结果可能是这样的：

![边框样式渲染效果](box-info-2.png)

{% note info %}

这些图片不必完整定义：比如可以只定义N、C和S方向素材，作为滚动条使用。

{% endnote %}

#### 启动项

```ruby
+ boot_menu {
  # ...
  item_font = "Unifont Regular 16"
  item_color = "#CCCCCC"
  item_pixmap_style = "item_*.png"
  item_height = 32
  item_spacing = 40  # 16 * 2 + 8
  item_padding = 8

  selected_item_font = "inherit"
  selected_item_color= "#FFFFFF"
  selected_item_pixmap_style = "select_*.png"
  # ...
}
```

如果说菜单栏属于某种列表的容器，那么启动项就是列表里的各个元素。如果你有Android开发经验，应该不难理解二者关系。而这里的字段名也非常好理解。

启动项主要分为两种状态：未选中状态和选中状态。二者的字体、颜色和样式可以不同。

{% note warning %}

如果对启动项应用边框样式，需要**同时**设计未选中和选中状态下的样式，而且涉及到的素材大小应完全一致，否则会出现错位。

如果添加滚动条样式，需要保证菜单栏右侧边框（对应NE、E、SE方向）的**宽度足以容纳滚动条**（如果将滚动条置于左侧，则需要保证左侧边框能容纳）。

{% endnote %}

{% note info %}

启动项的排版宜使用绝对大小（像素），因为文字字体只能使用绝对大小。

在实际应用中，对于未选中启动项，可以使用和选中状态边框大小相同，但是内容是全透明的素材，相当于一种占位符；为了保证对称性，建议同时增加菜单栏两侧边框的宽度。

{% endnote %}

#### 图标

```ruby
+ boot_menu {
  # ...
  icon_width = 32
  icon_height = 32
  item_icon_space = 8
  # ...
}
```

图标没啥办法，只能自己去找了。大致思路是从原始图片进行缩小，和启动项所占高度匹配即可。

{% note info %}

如果不打算使用图标，可以在`theme.txt`中`boot_menu`块设置`item_icon_space = 0`字段。

{% endnote %}

假设所有边框素材均为`16*16`大小，那么结合启动项和图标配置的渲染结果如下：

![启动项渲染预览](menu-1.png)

这里的边框颜色非常醒目，可以试试目测各个空隙的距离。

#### 滚动条

```ruby
+ boot_menu {
  # ...
  scrollbar = true
  scrollbar_width = 72  # 16 * 4 + 8
  scrollbar_frame = "scrollbar_*.png"
  scrollbar_thumb = "scrollbar_thumb_*.png"
  scrollbar_thumb_overlay = false
  #scrollbar_slice = "east"
  #scrollbar_left_pad = 0
  #scrollbar_right_pad = 0
  scrollbar_top_pad = 8
  scrollbar_bottom_pad = 8
  # ...
}
```

滚动条是在菜单栏边缘渲染的**两个**特殊`Styled Box`，可以控制两种样式：

* `scrollbar_frame`：滚动条背景，可以理解为滚动条后面那个凹槽；
* `scrollbar_thumb`：滚动条本体。

{% note warning %}

为了能够完美显示滚动条，需要综合考虑菜单栏边框素材大小和滚动条素材大小。

{% endnote %}

可以用`scrollbar_thumb_overlay`字段控制滚动条背景和本体的**边缘**是否重合。这个需要根据素材决定：如果背景素材是上下箭头那种类型的，就设置为`false`，这样上下箭头会完整显示。

{% note warning %}

如果设置了S和W素材，需要手动设置`scrollbar_width`字段，保证以下要求，否则GRUB将不会渲染进度条：

* 若`scrollbar_thumb_overlay = false`，则值不小于`scrollbar_frame`和`scrollbar_thumb`S和W素材**宽度的总和**；
* 若`scrollbar_thumb_overlay = true`，则值不小于`scrollbar_frame`S和W素材宽度和或`scrollbar_thumb`S和W素材宽度和。

{% endnote %}

`scrollbar_slice`字段控制滚动条位置，默认右边，改了就反直觉了属于是。

`scrollbar_*_pad`字段控制边距。

{% note warning %}

这里的`scrollbar_left_pad`和`scrollbar_right_pad`字段似乎无效，我没测出来。先别用了。

{% endnote %}

假设除菜单栏外，所有边框素材均为`16*16`大小，菜单栏边框宽度为`128`，则上述配置的渲染结果如下（注意看右侧）：

![滚动条渲染预览](menu-2.png)

至此，菜单栏介绍完毕。

### GRUB终端

```yaml
terminal-font: "Unifont Regular 16"
terminal-box: "terminal_*.png"
terminal-left: "10%"
terminal-width: "80%"
terminal-top: "10%"
terminal-height: "80%"
terminal-border: "16"
```

GRUB终端可以看成特殊的`Styled Box`。`terminal-border`字段描述了终端文字到边框的距离，看成某种`padding`即可。

### 自动启动倒计时

在定义完各个部件后，主题构建也接近尾声了，剩下的部件看着添加就好。

不过，如果设置了倒计时自动启动，要如何在屏幕上显示信息呢？

可以选择使用以下三种部件：

* `label`：（倒计时）文本
* `progress_bar`：进度条
* `circular_progress`：圆形进度条

{% note info %}

以下三种部件都需要添加`id = "__timeout__"`字段。

{% endnote %}

#### 倒计时文本

```ruby
+ label {
  #visible = true
  id = "__timeout__"

  left = 10%
  top = 10%
  width = 80%
  height = 16

  text = "Booting in %d seconds"
  font = "Unifont Regular 16"
  color = "#FFFFFF"
  align = "center"
}
```

{% note info %}

文本框可以显示任意文字。只有倒计时文本才需要添加`id = "__timeout__"`。

可以使用预设文本：`@KEYMAP_SHORT@`、`@KEYMAP_MIDDLE@`、`@KEYMAP_LONG@`。不建议使用`@KEYMAP_LONG@`，太长了容易顶出屏幕。

{% endnote %}

#### 进度条

```ruby
+ progress_bar {
  id = "__timeout__"

  left = 20%
  top = 80%
  width = 60%
  height = 32

  fg_color = "#777777"
  bg_color = "#333333"
  border_color = "#FFFFFF"
  text_color = "#FFFFFF"

  #bar_style = "progress_frame_*.png"
  #highlight_style = "progress_hl_*.png"
  #highlight_overlay = false

  font = "Unifont Regular 16"
  text = "@TIMEOUT_NOTIFICATION_SHORT@"
}
```

如果没有设置`style`，就分别设置`fg_color`、`bg_color`、`border_color`，反之不用。

如果设置了`style`，那么进度条可看作横板滚动条，关键配置也是相同的。这里不再赘述。

#### 圆形进度条

```ruby
+ circular_progress {
  id = "__timeout__"

  left = 20%
  top = 85%
  width = 10%
  height = 10%

  center_bitmap = "cir_center.png"
  tick_bitmap = "cir_tick.png"
  num_ticks = 128
  ticks_disappear = false
  start_angle = 0
}
```

这个用得很少。`center_bitmap`和`tick_bitmap`字段是必须要设置的，分别代表中心和圆环。剩下的自己试吧。

### 其它部件

#### 图片

```ruby
+ image {
  id = "__timeout__"

  left = 40%
  top = 85%
  width = 10%
  height = 10%

  file = "image.png"
}
```

注意图片会拉伸，建议大小设置为绝对值（像素）。

#### 容器

* `canvas`：画布
* `hbox`：水平布局
* `vbox`：垂直布局

```ruby
+ vbox {
  left = 0
  top = 15%
  width = 100%
  height = 15%

  + label {
    text = "<Text 1>"
    color = "#FF0000"
    align = "center"
  }

  + label {
    text = "<Text 2>"
    color = "#00FF00"
    align = "center"
  }

  + label {
    text = "<Text 3>"
    color = "#0000FF"
    align = "center"
  }
}
```

参考Android的布局了，可以算是自适应。但是，如果里面的东西冒出来了，这个布局可就要变形了。

## 参考技术选型

至此，你已经完成了`theme.txt`的编写！如果你还没有制作素材，就快去做吧！下面的技术选型可供参考。

### 手搓方案

在不考虑自动化构建的情况下，直接找别的主题然后自己修改是最节省时间的方案。若有图像编辑和UI设计基础，也可以自己手搓一套主题。

以下是编辑/创建主题各个文件的选型参考：

* `theme.txt`主题文件：任意文本编辑器。需要阅读文档，参考[众多主题](https://www.gnome-look.org/browse?cat=109)，了解各项参数作用；一些部件位置大小需要手算。
* 背景、LOGO等图片元素：`Adobe Photoshop`等图像编辑工具。
* `Styled Boxes`等素材：官方推荐`Inkscape`；当然，你也可以用上述图像编辑工具，但最好支持像素级别的修改。只要能保证输出符合要求的图片即可。
* 自定义字体：使用`grub-mkfont`工具。

当然，也可以考虑一些邪道。比如，本人在手搓[自制主题](https://github.com/FZQ0003/grub-theme-cyankylin)时，使用`Blender`制作了背景图片以及`Styled Boxes`素材，效果极佳。

![邪道预览图](preview-1080p.jpg)

![邪道工程截图](screenshot-blender-1.jpg)

![几何节点与素材渲染参考](screenshot-blender-2.jpg)

此外，[这个视频](https://www.bilibili.com/video/BV12FMdzuEdS/)提供了使用PPT做背景的思路，我觉得也算邪道（迫真）。

### 自动化构建方案

在手搓过程中，不难发现：素材制作流程基本上都差不多，做个背景图，设计一下边框UI，写个文本，就差不多做好了。那么，有没有办法将这套流程自动化呢？

比如，我制作一套模板，做几个自定义配置项，最后根据实际的屏幕分辨率生成主题？

答案是可行的，而且只需要考虑如何构建图像和`theme.txt`文本即可（边框等素材本质是低像素的图像）。

以下是不同编程语言的方案参考，你也可以摸索适合自己的方案。

#### Python 方案

* `theme.txt`：编写逻辑，实现部件位置大小计算和纯文本生成。
* 背景图片：`pillow` / `opencv-python`（经典库了属于是）。
* 其它素材：这里我建议copy别人主题，或者在上述图像库基础上使用`numpy`从像素层面手搓边框算法，注意各部分图像大小需要互相匹配。

#### CPP 方案

如果不喜欢安装`python`和各种库，也可以考虑走编译路线，最后做成一个cli工具，更爽一些。

* `theme.txt`：同上。
* 背景图片：`opencv`库，依赖部分需要自行解决。
* 其它素材：`opencv`库提供了`cv::Mat`等类，可以逐像素处理素材。
* 命令行处理：手搓 / `Boost.ProgramOptions` / `argparse`等第三方库。

当然，我的邪道也可以自动化构建：将场景都弄好，最后直接用命令行渲染。

## 总结

通过上述分析，我们可以大致了解一个GRUB主题的组成，以及如何构建素材和编写配置。受篇幅所限，这里没有给出实战环节，这里就先挖个坑吧。

还记得上面我给的特别花花的截图吗？为了能更直观地体现各配置所反映的效果，我做了一个主题Demo。可以通过访问[这个仓库](https://github.com/FZQ0003/grub-theme-disaster-design)获取。

最后给个Demo截图吧：

![Demo主菜单截图](demo-1.png)

![Demo二级菜单截图](demo-2.png)
