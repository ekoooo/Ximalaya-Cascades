/**
 * 喜马拉雅FM API
 */
var Api = {
    // 开发者消息
    "message": "http://lwl.tech/app/ximalaya/message",
    // 专辑列表（cpp也有这个地址，要一致）
    "albumInfo": "http://mobile.ximalaya.com/mobile/v1/album/track?albumId=%1&pageId=%2&pageSize=20&isAsc=%3",
    // 搜索 &core=%1&kw=%2&page=%3 core: album 专辑 user 主播
    "search": "http://search.ximalaya.com/front/v1?condition=relation&device=iPhone&search_version=1.3&version=6.3.45&operator=3&plan=b&paidFilter=false&rows=20&core=%1&kw=%2&page=%3",
    // 专辑信息(这里只取一条专辑声音)，付费声音必须传入 1&_device=iPhone&bb10&6.3.45 cookie才能有用
    "albumDetail":"http://mobile.ximalaya.com/mobile/v1/album?device=iPhone&pageSize=1&albumId=%1",
    // 主播信息
    "artistIntro": "http://mobile.ximalaya.com/mobile/v1/artist/intro?device=iPhone&toUid=%1",
    // 主播的专辑
    "artistAlbums": "http://mobile.ximalaya.com/mobile/v1/artist/albums?device=iPhone&pageSize=%1&pageId=%2&toUid=%3",
    // 分类
    "categories": "http://mobile.ximalaya.com/mobile/discovery/v4/categories?channel=&device=iPhone&version=6.3.45",
    // 一级搜索条件
    "keywords": "http://mobile.ximalaya.com/mobile/discovery/v1/category/keywords?device=iPhone&categoryId=%1",
    // 二级搜索条件
    "metadatas": "http://mobile.ximalaya.com/mobile/discovery/v2/category/metadatas?device=iPhone&version=6.3.45&categoryId=%1",
    // 搜索一级
    "keywordAlbums": "http://mobile.ximalaya.com/mobile/discovery/v3/category/keyword/albums?device=iPhone&operator=3&status=0&version=6.3.45&pageSize=20&calcDimension=hot&categoryId=%1&keywordId=%2&pageId=%3",
    // 搜索二级
    "metadataAlbums": "http://mobile.ximalaya.com/mobile/discovery/v2/category/metadata/albums?device=iPhone&status=0&version=6.3.45&pageSize=20&categoryId=%1&metadatas=%2&pageId=%3&calcDimension=%4"
};