/**
 * 喜马拉雅FM API
 */
var Api = {
    // 专辑列表
    "albumInfo": "http://mobile.ximalaya.com/mobile/v1/album/track?albumId=%1&pageId=%2&pageSize=20&isAsc=true",
    // 搜索 &core=%1&kw=%2&page=%3 core: album 专辑 user 主播
    "search": "http://search.ximalaya.com/front/v1?condition=relation&device=IOS&search_version=1.3&version=6.3.45&plan=b&paidFilter=false&rows=20&core=%1&kw=%2&page=%3"
};