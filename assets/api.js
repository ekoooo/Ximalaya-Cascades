/**
 * 喜马拉雅FM API
 */
var Api = {
    // 专辑列表（cpp也有这个地址，要一致）
    "albumInfo": "http://mobile.ximalaya.com/mobile/v1/album/track?albumId=%1&pageId=%2&pageSize=20&isAsc=%3",
    // 搜索 &core=%1&kw=%2&page=%3 core: album 专辑 user 主播
    "search": "http://search.ximalaya.com/front/v1?condition=relation&device=iPhone&search_version=1.3&version=6.3.45&operator=3&plan=b&paidFilter=false&rows=20&core=%1&kw=%2&page=%3",
    // 专辑信息(这里只取一条专辑声音)，付费声音必须传入 1&_device=iPhone&bb10&6.3.45 cookie才能有用
    "albumDetail":"http://mobile.ximalaya.com/mobile/v1/album?device=iPhone&pageSize=1&albumId=%1"
};