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
        "audioPlayerOpVisible": "audioPlayerOpVisible"
    }
    
    // 快捷键
    property variant shortCutKey: {
        
    }
    
    // 打开对话框
    function openDialog(title, body) {
        _misc.openDialog(qsTr("确定"), qsTr("取消"), title, body);
    }
    
    // ============ api start ============
    function apiAlbumInfo(requester, albumId, pageId) {
        requester.send(qsTr(api.albumInfo).arg(albumId.toString()).arg(pageId.toString()));
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
