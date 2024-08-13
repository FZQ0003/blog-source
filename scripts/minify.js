const minifyHtml = require("@minify-html/node");
// const minifyJs = require("@minify-js/node");
// const lightningCss = require("lightningcss");

// HTML
const html_config = hexo.config.minify_html || {}
if (html_config.enable) {
  hexo.extend.filter.register("after_render:html", data => {
    const minified = minifyHtml.minify(Buffer.from(data), html_config.config || {});
    return minified.toString();
  }, typeof html_config.priority === "number" ? html_config.priority : 999);
}

// JS
// const js_config = hexo.config.minify_js || {}
// if (js_config.enable) {
//   hexo.extend.filter.register("after_render:js", data => {
//     const minified = minifyJs.minify("global", Buffer.from(data));
//     return minified.toString();
//   }, typeof js_config.priority === "number" ? js_config.priority : 999);
// }

// CSS
// const css_config = hexo.config.lightningcss || {}
// if (css_config.enable) {
//   hexo.extend.filter.register("after_render:css", data => {
//     const minified = lightningCss.transform({
//       code: Buffer.from(data),
//       minify: true
//     })
//     return minified.toString();
//   }, typeof css_config.priority === "number" ? css_config.priority : 999);
// }
