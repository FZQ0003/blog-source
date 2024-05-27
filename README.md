# F_Qilin's Blog Source

这里存放了博客各文章的Markdown文件、一些静态资源和配置等文件。

Here are stored the Markdown files of each blog article, some static resources and configuration files.

## Changed

* 修改了Gitalk评论区。
  * 主题配置`post.comments`不起作用。
  * 文章必须配置`comment_id`以开启评论区。生成的`Issue Label`格式：`Comment: comment_id`。
* 添加和修改了一些CSS样式。
* 修改了版权界面。
  * 指定了非`CC`许可协议，或对文章加密，则背景图标改变。
  * 加密文章的默认许可协议为`禁止转载`，并在主题配置中新增了`post.copyright.license_encrypt`配置。
* 添加了对镜像站的检测。
<!-- * 主页背景图改为每日一图。 -->

* Modified the Gitalk comment area.
  * Theme config `post.comments` does not work.
  * Articles must be configured with `comment_id` to open comments. Generated `Issue Label` format: `Comment: comment_id`.
* Added and modified some CSS styles.
* Modified the copyright section.
  * If a non-`CC` license is specified, or the article is encrypted, the background icon will change.
  * The default license agreement for encrypted articles is `No reproduction without permission`, and a `post.copyright.license_encrypt` has been added to theme config.
* Added detection of mirror sites.
<!-- * Changed the homepage background image to daily picture. -->

## How to Deploy

> [!NOTE]
>
> 该部署方式**不会**读取或部署部分内容，如加密文章、敏感数据等。
>
> This deployment method **will not** read or deploy some content, such as encrypted articles, sensitive data, etc.

确保已经安装了Node.js。执行下列命令后，将`public`文件夹内容部署到服务器中，注意部署位置应与配置相同。

Make sure Node.js is installed. After executing the following command, deploy the contents of the `public` folder to the server. Note that the deployment location should be the same as the configuration.

``` sh
# bash pre_deploy.sh
npm install
npm run-script build
# bash post_deploy.sh
```

## Known Issues

* 文章图片的相对路径与Markdown不同。例如：在`article.md`中`![Pic](pic.png)`对应的图片路径为`article/pic.png`。
* 配置文件不完整。若使用其他功能，需要补全相应配置。

* The relative path of article images is different from that of Markdown. For example, in `article.md`, the image path corresponding to `![Pic](pic.png)` is `article/pic.png`.
* Configuration files are incomplete. If you use other functions, you need to complete the corresponding configuration.

## License

博客文章默认采用[`CC BY-SA 4.0`](https://creativecommons.org/licenses/by-sa/4.0/)许可。个别文章采用[`CC BY-NC-ND 4.0`](https://creativecommons.org/licenses/by-nc-nd/4.0/)许可。**加密文章禁止分享。**

涉及到主题修改的部分采用[`GPL-3.0`](https://www.gnu.org/licenses/gpl-3.0.txt)许可。

Blog articles are licensed under the [`CC BY-SA 4.0`](https://creativecommons.org/licenses/by-sa/4.0/) license by default. Individual articles are licensed under the [`CC BY-NC-ND 4.0`](https://creativecommons.org/licenses/by-nc-nd/4.0/) license. **Encrypted articles are prohibited from sharing.**

Parts involving theme modifications are licensed under [`GPL-3.0`](https://www.gnu.org/licenses/gpl-3.0.txt).
