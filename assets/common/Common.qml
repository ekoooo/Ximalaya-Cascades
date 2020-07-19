import bb.cascades 1.4
import "asset:///api.js" as Api

QtObject {
    property variant api: Api.Api
    property variant bbwAddr: "appworld://content/xxxxx"
    property variant authorWebSite: "http://lwl.tech/"
    property variant developerEmail: "954408050@qq.com"
    property variant version:  Application.applicationVersion
    property variant hardwareInfo: _misc.getHardwareInfo()
    property variant sourceTypeArr: ['playUrl64', 'playUrl32', 'playPathAacv224', 'playPathAacv164', 'playPathHq']
    
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
         * playUrl64 e.g. 5.26mb
         * playUrl32 e.g. 2.63mb
         * playPathAacv224 e.g. 2.04mb
         * playPathAacv164 e.g. 5.33mb
         * 
         * playPathHq 高质量，有的没有 // 默认
         */
        "audioPlayerSourceType": "audioPlayerSourceType",
        // 声音列表是否正序（每个专辑都要存）（cpp也有这个key，要一致）
        "trackListIsAsc": "isAsc::albumId::",
        // 主页最后浏览的三个分类
        "lastViewCategory": "lastViewCategory"
    }
    
    // 快捷键
    property variant shortCutKey: {
        "shortCutList": ['back', 'openPlayer', 'indexPage', 'searhPage', 
        'changeSegmented', 'playPreTrack', 'playNextTrack', 'togglePlayerState', 'togglePlayerOp', 
        'toggleMetaPanel'],
        
        "back": "F",
        "backLabel": qsTr("返回"),
        "openPlayer": "O",
        "openPlayerLabel": qsTr("打开播放器"),
        "indexPage": "I",
        "indexPageLabel": qsTr("主页"),
        "searhPage": "A",
        "searhPageLabel": qsTr("搜索"),
        "changeSegmented": "C",
        "changeSegmentedLabel": qsTr("搜索页、专辑页切换 Tab"),
        "playPreTrack": "S",
        "playPreTrackLabel": qsTr("上一个声音"),
        "playNextTrack": "X",
        "playNextTrackLabel": qsTr("下一个声音"),
        "togglePlayerState": "Space",
        "togglePlayerStateLabel": qsTr("播放/暂停"),
        "togglePlayerOp": "H",
        "togglePlayerOpLabel": qsTr("隐藏/显示 播放器操作面板"),
        "toggleMetaPanel": "H",
        "toggleMetaPanelLabel": qsTr("隐藏/显示 二级搜索条件")
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
    
    /**
     * 格式化时间戳为：mm:ss
     */
    function formatPlayerDuration(s) {
        var minutes = Math.floor(s/1000/60);
        var seconds = Math.floor(s/1000%60);
        return qsTr("%1:%2").arg(minutes < 10 ? "0" + minutes : "" + minutes).arg(seconds < 10 ? "0" + seconds : "" + seconds);
    }
    
    /**
     * 获取日期信息
     * 年、月、日、时、分、秒
     */
    function getDateInfo(date) {
        var year = date.getFullYear();
        var month = date.getMonth() + 1;
        var day = date.getDate();
        var h = date.getHours();
        var m = date.getMinutes();
        var s = date.getSeconds();
        
        month = month < 10 ? '0' + month : month;
        day = day < 10 ? '0' + day : day;
        h = h < 10 ? '0' + h : h;
        m = m < 10 ? '0' + m : m;
        s = s < 10 ? '0' + s : s;
        
        return {
            year: year,
            month: month,
            day: day,
            h: h,
            m: m,
            s: s
        };
    }
    
    /**
     * 格式化时间戳
     * type: 
     *     1 e.g. 07-25 13:31
     *     2 e.g. 2018-07-26 16:35:04
     *     3 e.g. 20180726
     *     4 e.g. 2018/07/26
     */
    function formaTtimestamp(timestamp, type) {
        if(typeof timestamp === 'string') {
            timestamp = Number(timestamp);
        }
        if(timestamp <= 9999999999) {
            timestamp = timestamp * 1000;
        }
        
        var info = getDateInfo(new Date(timestamp));
        
        if(type == 1) {
            return info['month'] + '-' + info['day'] + ' ' + info['h'] + ':' + info['m'];
        }else if(type === 2) {
            return info['year'] + '-' +info['month'] + '-' + info['day'] + ' ' + info['h'] + ':' + info['m'] + ':' + info['s'];
        }else if(type === 3) {
            return info['year'] + '' +info['month'] + '' + info['day']
        }else if(type === 4) {
            return info['year'] + '/' +info['month'] + '/' + info['day']
        }
    }
    
    // ============ nav start ============
    function onPopTransitionEnded(nav, page) {
        page.destroy();
        
        Application.menuEnabled = true;
    }
    
    function onPushTransitionEnded(nav, page) {
        // 帮助、赞助、关于、设置 页面禁止再打开 application menu
        Application.menuEnabled = ['helpPage', 'sponsorPage', 'aboutPage', 'settingsPage', 'sponsorInfoPage'].indexOf(page.objectName) === -1;
    }
    // ============ nav end ============
    
    // ============ api start ============
    // 开发者消息
    function apiMessage(requester) {
        requester.setHeaders({
            "appinfo": getHardwareInfo()
        });
    
        requester.send(api.message);
    }
    
    function apiAlbumInfo(requester, albumId, pageId) {
        var isAsc = _misc.getConfig(settingsKey.trackListIsAsc + albumId, "1") === "1";
        
        requester.send(qsTr(api.albumInfo).arg(albumId.toString()).arg(pageId.toString()).arg(isAsc.toString()));
    }
    function apiSearch(requester, core, kw, page) {
        // core: album 专辑 user 主播
        requester.send(qsTr(api.search).arg(core).arg(encodeURIComponent(kw)).arg(page.toString()));
    }
    function apiAlbumDetail(requester, albumId) {
        requester.setHeaders({"Cookie": "1&_device=iPhone&bb10&6.3.45"});
        requester.send(qsTr(api.albumDetail).arg(albumId.toString()));
    }
    function apiArtishIntro(requester, uid) {
        requester.send(qsTr(api.artistIntro).arg(uid.toString()));
    }
    function apiArtistAlbums(requester, uid, pageId, pageSize) {
        requester.send(qsTr(api.artistAlbums).arg(pageSize.toString()).arg(pageId.toString()).arg(uid.toString()));
    }
    function apiCategories(requester) {
        requester.send(api.categories);
    }
    function apiKeywords(requester, categoryId) {
        requester.send(qsTr(api.keywords).arg(categoryId.toString()));
    }
    function apiMetadatas(requester, categoryId) {
        requester.send(qsTr(api.metadatas).arg(categoryId.toString()));
    }
    function apiKeywordAlbums(requester, categoryId, keywordId, pageId) {
        requester.send(qsTr(api.keywordAlbums).arg(categoryId.toString()).arg(keywordId.toString()).arg(pageId.toString()));
    }
    function apiMetadataAlbums(requester, categoryId, metadatas, pageId) {
        // hot, recent, classic
        // 最火，最近更新(calcDimension:1)，经典(calcDimension:2)
        var calcDimension = 'hot';
        if(metadatas) {
            var metadatasArr = metadatas.split(',');
            var newArr = [];
            for(var i = 0; i < metadatasArr.length; i++) {
                if(metadatasArr[i] === 'calcDimension:1') {
                    calcDimension = 'recent';
                }else if(metadatasArr[i] === 'calcDimension:2') {
                    calcDimension = 'classic';
                }else {
                    newArr.push(metadatasArr[i]);
                }
            }
            metadatas = newArr.join(',');
        }
        
        requester.send(qsTr(api.metadataAlbums).arg(categoryId.toString()).arg(metadatas).arg(pageId.toString()).arg(calcDimension));
    }
    // ============ api end ============
    function getHardwareInfo() {
        var info = hardwareInfo;
        info.version = version;
        return JSON.stringify(info);
    }
    
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
