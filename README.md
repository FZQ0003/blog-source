# F_Qilin's Blog Source

这里存放了博客各文章的Markdown文件、一些静态资源和配置等文件。

## Changed

* 采用了不同于主题预设的[`Giscus`](https://giscus.app/)评论区。
  * 主题配置`post.comments.type`设为`user`时将启用该评论区。
  * 主题评论插件配置`giscus.theme-*`不起作用。
* 添加和修改了一些CSS样式。
* 修改了版权界面。
  * 指定了非`CC`许可协议，或对文章加密，则背景图标改变。
  * 加密文章的默认许可协议为`禁止转载`，并在主题配置中新增了`post.copyright.license_encrypt`配置。
* 添加了对镜像站的检测。
  * 主题配置`index.check_url.enable`：启用检测。
  * 主题配置`index.check_url.note_type`：便签样式。
  * 主题配置`index.check_url.failed_text`：检测不通过文字，用`%s`指定主站链接在文本位置。
* 主页背景图可动态切换。
  * 可通过主题配置设置图库、刷新时切换方式、手动切换方式等，具体可见主题配置文件中带有`NEW`注释的部分。
  * 主题配置`index.banner_img`作为切换失败时默认图片。
  * 扩展性设计，以便日后开发。

## How to Deploy

> [!NOTE]
>
> 该部署方式**不会**读取或部署部分内容，如加密文章、敏感数据等。

确保已经安装了Node.js。执行下列命令后，将`public`文件夹内容部署到服务器中，注意部署位置应与配置相同。

``` sh
# bash pre_deploy.sh
npm install
npm run-script build
# bash post_deploy.sh
```

## Known Issues

* 文章图片的相对路径与Markdown不同。例如：在`article.md`中`![Pic](pic.png)`对应的图片路径为`article/pic.png`。
* 配置文件不完整。若使用其他功能，需要补全相应配置。

## License

博客文章默认采用[`CC BY-SA 4.0`](https://creativecommons.org/licenses/by-sa/4.0/)许可。个别文章采用[`CC BY-NC-ND 4.0`](https://creativecommons.org/licenses/by-nc-nd/4.0/)许可。**加密文章禁止分享。**

涉及到主题修改的部分采用[`GPL-3.0`](https://www.gnu.org/licenses/gpl-3.0.txt)许可。
