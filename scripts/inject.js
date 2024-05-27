// Override
hexo.extend.filter.register('theme_inject', (injects) => {
    // Body
    injects.bodyEnd.file('check_url', 'source/_inject/check_url.ejs');
    // Comments
    injects.postComments.file('default', 'source/_inject/gitalk.ejs');
    injects.pageComments.file('default', 'source/_inject/gitalk.ejs');
    injects.linksComments.file('default', 'source/_inject/gitalk.ejs');
    // Copyright
    injects.postCopyright.file('default', 'source/_inject/copyright.ejs');
});
