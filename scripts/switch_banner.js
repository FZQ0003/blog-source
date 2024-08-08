var util = require('hexo-util');

// const pages = ['index', 'post', 'archive', 'category', 'tag', 'about', 'page', 'page404', 'links'];
const pages = ['index'];  // TODO
var banners = {};
hexo.locals.set('banners', banners);
for (let page of pages) {
  banners[page] = { list: [], default: hexo.config.theme_config[page].banner_img };
  var config = hexo.config.theme_config[page].switch_banner || {};
  if (config.enable) {
    var patterns = (config.pattern || []).map(p_str => {
      return new util.Pattern(p_str);
    });
    hexo.source.addProcessor(path => {
      for (let p of patterns) {
        let m = p.match(path);
        if (m) { return m; }
      }
    }, file => {
      if (file.type !== 'delete') {
        banners[page].list.push(hexo.config.root + file.path);
      }
    });
  }
}

// Sort
hexo.extend.filter.register("before_generate", () => {
  for (let page of pages) { banners[page].list.sort(); }
});
