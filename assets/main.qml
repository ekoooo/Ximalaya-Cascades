import bb.cascades 1.4
import bb.multimedia 1.4
import tech.lwl 1.0
import "asset:///common"
import "asset:///pages" as Page

TabbedPane {
    id: tabbedPane
    property variant nav: activeTab.tabNav // 所以页面可用导航
    property bool backButtonVisiable: _misc.getConfig(common.settingsKey.backButtonVisiable, "1") === "1" // 是否显示返回按钮
    // audioPlayerUI property start
    property variant audioPlayerUIPage // 播放器页面
    property variant albumInfo // 专辑信息(当播放列表)
    property variant albumDetail // 专辑详情
    property variant trackId // 声音ID
    // audioPlayerUI property end
    property variant lastViewCategory: _misc.getConfig(common.settingsKey.lastViewCategory, "[]")
    
    showTabsOnActionBar: false
    activeTab: indexTab // 默认 activeTab 为 主页
    
    shortcuts: [
        Shortcut {
            key: common.shortCutKey.openPlayer
            onTriggered: {
                if(isOnPlayerPage()) {
                    return;
                }
                pushAudioPlayerUI(-1);
            }
        },
        Shortcut {
            key: common.shortCutKey.back
            onTriggered: {
                if(nav.count() !== 1) {
                    nav.pop();
                }
            }
        },
        Shortcut {
            key: common.shortCutKey.indexPage
            onTriggered: {
                if(isOnPlayerPage()) {
                    nav.pop();
                }
                activeTab = indexTab;
            }
        },
        Shortcut {
            key: common.shortCutKey.searchPage
            onTriggered: {
                if(isOnPlayerPage()) {
                    nav.pop();
                }
                activeTab = searchTab;
            }
        },
        Shortcut {
            key: common.shortCutKey.playLogPage
            onTriggered: {
                if(isOnPlayerPage()) {
                    nav.pop();
                }
                activeTab = playLogTab;
            }
        }
    ]
    
    Menu.definition: MenuDefinition {
        helpAction: HelpActionItem {
            title: qsTr("帮助")
            onTriggered: {
                nav.push(helpPage.createObject());
            }
        }
        settingsAction: SettingsActionItem {
            title: qsTr("设置")
            onTriggered: {
                nav.push(settingsPage.createObject());
            }
        }
        actions: [
            ActionItem {
                title: qsTr("赞助")
                imageSource: "asset:///images/bb10/ic_contact.png"
                onTriggered: {
                    nav.push(sponsorInfoPage.createObject());
                }
            },
            ActionItem {
                title: qsTr("关于作者")
                imageSource: "asset:///images/bb10/ic_edit_bookmarks.png"
                onTriggered: {
                    _misc.invokeBrowser(common.authorWebSite);
                }
            },
            ActionItem {
                title: qsTr("关于")
                imageSource: "asset:///images/bb10/ic_info.png"
                onTriggered: {
                    nav.push(aboutPage.createObject());
                }
            }
        ]
    }
    
    tabs: [
        Tab {
            id: indexTab
            property alias tabNav: indexNav
            title: qsTr("主页")
            imageSource: "asset:///images/bb10/ic_home.png"
            NavigationPane {
                id: indexNav
                Page.index {}
                onPopTransitionEnded: common.onPopTransitionEnded(nav, page)
                onPushTransitionEnded: common.onPushTransitionEnded(nav, page)
                backButtonsVisible: tabbedPane.backButtonVisiable
            }
        },
        Tab {
            id: searchTab
            property alias tabNav: searchNav
            title: qsTr("搜索")
            imageSource: "asset:///images/bb10/ic_search.png"
            NavigationPane {
                id: searchNav
                Page.search {}
                onPopTransitionEnded: common.onPopTransitionEnded(nav, page)
                onPushTransitionEnded: common.onPushTransitionEnded(nav, page)
                backButtonsVisible: tabbedPane.backButtonVisiable
            }
        },
        Tab {
            id: playLogTab
            property alias tabNav: playLogNav
            title: qsTr("播放记录")
            imageSource: "asset:///images/bb10/ic_history.png"
            NavigationPane {
                objectName: "playLogObject"
                id: playLogNav
                Page.playLog {}
                onPopTransitionEnded: common.onPopTransitionEnded(nav, page)
                onPushTransitionEnded: common.onPushTransitionEnded(nav, page)
                backButtonsVisible: tabbedPane.backButtonVisiable
            }
        }
    ]
    
    onActivePaneChanged: {
        // 切换到历史记录，刷新列表
        if(activePane.objectName === 'playLogObject') {
            playLogNav.firstPage.initListData();
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: helpPage
            source: "asset:///pages/help.qml"
        },
        AudioPlayer {
            id: player
            onPositionChanged: {
                audioPlayerUIPage && audioPlayerUIPage.positionChanged(position)
            }
            onDurationChanged: {
                audioPlayerUIPage && audioPlayerUIPage.durationChanged(duration);
            }
            onMediaStateChanged: {
                audioPlayerUIPage && audioPlayerUIPage.mediaStateChanged(mediaState);
            }
            onCurrentTrackChanged: {
                audioPlayerUIPage && audioPlayerUIPage.currentTrackChanged(trackId);
            }
            onAlbumInfoChanged: {
                audioPlayerUIPage && audioPlayerUIPage.albumInfoChanged();
            }
            onAlbumEnd: {
                audioPlayerUIPage && audioPlayerUIPage.albumEnd(flag);
            }
            onTrack404: {
                audioPlayerUIPage && audioPlayerUIPage.track404();
            }
            onPreNextTrack: {
                audioPlayerUIPage && audioPlayerUIPage.preNextTrack();
            }
            onExitTimerInterval: {
                audioPlayerUIPage && audioPlayerUIPage.exitTimerInterval(currentExitTime, exitTime);
            }
        },
        ComponentDefinition {
            id: audioPlayerUI
            source: "asset:///pages/audioPlayerUI.qml"
        },
        QTimer {
            id: audioPlayerUItimer
            interval: 200
            onTimeout: {
                audioPlayerUItimer.stop();
                tabbedPane.initAudioPlayerUIParams();
            }
        },
        QTimer {
            id: messageTimer
            interval: 2000
            onTimeout: {
                messageTimer.stop();
                common.apiMessage(messageRequester);
            }
        },
        Requester {
            id: messageRequester
            onFinished: {
                messageTimer.stop();
                
                var rs = JSON.parse(data);
                var info = rs.info;
                var isFirstShow = _misc.getConfig(common.settingsKey.developerMessageVersion, "0") != info['version'];
                
                if(rs.code === 200 && (isFirstShow || info['always'])) {
                    var version = '『v' + common.version + '』';
                    
                    // 弹出消息
                    common.openDialog(info['title'] + version, '通知日期：' + info['date'] + '\r\n\r\n' + info['body']);
                    // 存储最新的消息版本，只提示一次
                    _misc.setConfig(common.settingsKey.developerMessageVersion, info['version']);
                }
            }
        },
        Common {
            id: common
        },
        ComponentDefinition {
            id: aboutPage
            source: "asset:///pages/about.qml"
        },
        ComponentDefinition {
            id: settingsPage
            source: "asset:///pages/settings.qml"
        },
        ComponentDefinition {
            id: sponsorInfoPage
            source: "asset:///pages/sponsorInfo.qml"
        }
    ]
    
    onCreationCompleted: {
        // 设置主题
        _misc.setTheme(_misc.getConfig(common.settingsKey.theme, "Bright"));
        // 读取消息
        messageTimer.start();
    }
    
    function getPlayer() {
        return player;
    }
    
    // 当前界面时候在播放器界面中
    function isOnPlayerPage() {
        return nav.top.objectName === "audioPlayer";
    }
    
    /**
     * 进入播放器
     * 如果是直接进入，trackId = -1
     */
    function pushAudioPlayerUI(trackId, albumInfo, albumDetail) {
        audioPlayerUIPage = audioPlayerUI.createObject();
        nav.push(audioPlayerUIPage);
        // 保存至 tabbedPane 中，提供给 timer 使用
        tabbedPane.trackId = trackId;
        tabbedPane.albumDetail = albumDetail;
        tabbedPane.albumInfo = albumInfo;
        
        audioPlayerUItimer.start();
    }
    function initAudioPlayerUIParams() {
        audioPlayerUIPage.audioPlayer = player;
        audioPlayerUIPage.albumDetail = tabbedPane.albumDetail;
        audioPlayerUIPage.albumInfo = tabbedPane.albumInfo;
        audioPlayerUIPage.trackId = tabbedPane.trackId; // 注意顺序，trackId 赋值必须在最后面。
    }
}
