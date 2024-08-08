// Override
hexo.extend.filter.register('theme_inject', injects => {
  // Body
  injects.bodyEnd.file('check_url', 'source/_inject/check_url.ejs');
  injects.bodyEnd.file('switch_banner', 'source/_inject/switch_banner.ejs');
  // Comments
  injects.postComments.file('default', 'source/_inject/comments.ejs');
  injects.pageComments.file('default', 'source/_inject/comments.ejs');
  injects.linksComments.file('default', 'source/_inject/comments.ejs');
  // Copyright
  injects.postCopyright.file('default', 'source/_inject/copyright.ejs');
});
