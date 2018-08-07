import bb.cascades 1.4
import "asset:///api.js" as Api

QtObject {
    property variant api: Api.Api
    property variant bbwAddr: "appworld://content/xxxxx"
    property variant developerEmail: "954408050@qq.com"
    
    // 设置 key
    property variant settingsKey: {
        // 主题
        "theme": "theme",
        // 是否显示返回按钮
        "backButtonVisiable": "backButtonVisiable",
        // 开发者消息版本
        "developerMessageVersion": "developerMessageVersion",
        // 当前播放的 trackId
        "currentPlayTrackId": "currentPlayTrackId",
        // 播放器操作面板显示状态
        "audioPlayerOpVisible": "audioPlayerOpVisible",
        /**
         * 播放声音源
         * playUrl64 e.g. 5.26mb // 默认
         * playUrl32 e.g. 2.63mb
         * playPathAacv224 e.g. 2.04mb
         * playPathAacv164 e.g. 5.33mb
         */
        "audioPlayerSourceType": "audioPlayerSourceType"
    }
    
    // 快捷键
    property variant shortCutKey: {
        
    }
    
    // 打开对话框
    function openDialog(title, body) {
        _misc.openDialog(qsTr("确定"), qsTr("取消"), title, body);
    }
    
    /**
     * 格式化数字
     * 12300 1.23万
     * 123000000 1.23亿
     */
    function parsePlayerNum(num) {
        var rs = num;
        if(num >= 10000 && num < 100000000) {
            rs = Math.round((num/10000)*100)/100 + qsTr("万");
        }else if(num >= 100000000) {
            rs = Math.round((num/100000000)*100)/100 + qsTr("亿");
        }
        return rs;
    }
    
    function isNotFree(itemInfo) {
        return itemInfo['isPaid'] && !itemInfo['isFree'];
    }
    
    // ============ nav start ============
    function onPopTransitionEnded(nav, page) {
        page.destroy();
    }
    
    function onPushTransitionEnded(nav, page) {
    
    }
    // ============ nav end ============
    
    // ============ api start ============
    function apiAlbumInfo(requester, albumId, pageId) {
        requester.send(qsTr(api.albumInfo).arg(albumId.toString()).arg(pageId.toString()));
    }
    function apiSearch(requester, core, kw, page) {
        // core: album 专辑 user 主播
        requester.send(qsTr(api.search).arg(core).arg(encodeURIComponent(kw)).arg(page.toString()));
    }
    function apiAlbumDetail(requester, albumId) {
        requester.setHeaders({"Cookie": "1&_device=iPhone&bb10&6.3.45"});
        requester.send(qsTr(api.albumDetail).arg(albumId.toString()));
    }
    // ============ api end ============
    function httpGetAsync(theUrl, callback) {
        var xmlHttp = new XMLHttpRequest();
        xmlHttp.onreadystatechange = function() { 
            if(xmlHttp.readyState == 4) {
                if(xmlHttp.status == 200) {
                    callback(true, xmlHttp.responseText);
                }else {
                    callback(false, xmlHttp.statusText);
                }
            }
        }
        xmlHttp.open("GET", theUrl, true); // true for asynchronous 
        xmlHttp.send(null);
    }
}
