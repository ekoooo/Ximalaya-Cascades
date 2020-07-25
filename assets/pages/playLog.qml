import bb.cascades 1.4
import bb.system 1.2
import tech.lwl 1.0
import "asset:///components"

Page {
    id: playLog
    property variant totalCount: 0
    
    actionBarVisibility: ChromeVisibility.Compact
    
    titleBar: TitleBar {
        title: qsTr("播放记录")
        scrollBehavior: TitleBarScrollBehavior.Sticky
    }
    
    Container {
        Header {
            title: qsTr("共有%1条历史记录").arg(totalCount)
        }
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        ListView {
            id: lv
            property variant common_: common
            property variant dm_: dm
            property variant root_: playLog
            property variant deleteDialog_: deleteDialog
            // 删除的下标
            property variant deletePlayLogAlbumId
            
            dataModel: ArrayDataModel {
                id: dm
            }
            scrollRole: ScrollRole.Main
            
            leadingVisual: RefreshHeader {
                id: refreshHeader
                onRefreshTriggered: {
                    initListData();
                    stopRefreshTimer.start();
                }
            }
            onTouch: {
                refreshHeader.onListViewTouch(event);
            }
            eventHandlers: [
                TouchKeyboardHandler {
                    onTouch: {
                        refreshHeader.onListViewTouch(event);
                    }
                }
            ]
            listItemComponents: [
                ListItemComponent {
                    type: ''
                    CustomListItem {
                        id: customListItem
                        
                        gestureHandlers: [
                            LongPressHandler {
                                onLongPressed: {
                                    customListItem.ListItem.view.deleteDialog_.show();
                                    customListItem.ListItem.view.deletePlayLogAlbumId = ListItemData['albumId'];
                                }
                            }
                        ]
                        
                        Container {
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            verticalAlignment: VerticalAlignment.Center
                            
                            // cover image
                            Container {
                                layout: DockLayout {}
                                preferredWidth: ui.du(20)
                                preferredHeight: ui.du(20)
                                
                                gestureHandlers: [
                                    TapHandler {
                                        onTapped: {
                                            customListItem.ListItem.view.root_.goAlbumPage(ListItemData.mAlbumDetail['albumId']);
                                        }
                                    }
                                ]
                                
                                WebImageView {
                                    url: "asset:///images/album_cover_bg.png"
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    verticalAlignment: VerticalAlignment.Fill
                                    scalingMethod: ScalingMethod.AspectFill
                                    implicitLayoutAnimationsEnabled: false
                                }
                                Container {
                                    property variant pWidth: ui.du(2.2)
                                    layout: DockLayout {}
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    verticalAlignment: VerticalAlignment.Fill
                                    leftPadding: pWidth
                                    rightPadding: pWidth
                                    topPadding: pWidth
                                    bottomPadding: pWidth
                                    
                                    WebImageView {
                                        url: ListItemData.mAlbumDetail['coverLarge'] || "asset:///images/ting_default.png"
                                        horizontalAlignment: HorizontalAlignment.Fill
                                        verticalAlignment: VerticalAlignment.Fill
                                        scalingMethod: ScalingMethod.AspectFill
                                        implicitLayoutAnimationsEnabled: false
                                    }
                                }
                            }
                            // info
                            Container {
                                id: infoContainer
                                property variant textMargin: ui.du(0.5)
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                                leftPadding: ui.du(1)

                                gestureHandlers: [
                                    TapHandler {
                                        onTapped: {
                                            customListItem.ListItem.view.root_.openAudioPlayerUI(ListItemData.trackId, ListItemData.albumInfo, ListItemData.mAlbumDetail, ListItemData.position);
                                        }
                                    }
                                ]
                                
                                Container {
                                    bottomMargin: infoContainer.textMargin
                                    Label {
                                        text: qsTr("专辑：") + ListItemData.mAlbumDetail['title']
                                        textStyle.fontWeight: FontWeight.Bold
                                    }
                                }
                                
                                Container {
                                    bottomMargin: infoContainer.textMargin
                                    Label {
                                        text: qsTr("主播：") + ListItemData.mAlbumDetail['nickname']
                                        textStyle {
                                            base: SystemDefaults.TextStyles.SubtitleText
                                        }
                                    }
                                }
                                Container {
                                    bottomMargin: infoContainer.textMargin
                                    Label {
                                        text: qsTr("声音：") + ListItemData.trackInfo.title
                                        textStyle {
                                            base: SystemDefaults.TextStyles.SubtitleText
                                            color: ui.palette.primary
                                        }
                                    }
                                }
                                Container {
                                    bottomMargin: infoContainer.textMargin
                                    Label {
                                        text: qsTr("已播：") 
                                            + customListItem.ListItem.view.common_.formatPlayerDuration(ListItemData.position) + '/' 
                                            + customListItem.ListItem.view.common_.formatPlayerDuration(ListItemData.trackInfo.duration * 1000)
                                        multiline: true
                                        textStyle {
                                            base: SystemDefaults.TextStyles.SubtitleText
                                            color: Color.Gray
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            ]
            
            attachedObjects: [
                SystemDialog {
                    id: deleteDialog
                    title: "提示"
                    body: "是否删除该条历史记录？"
                    onFinished: {
                        if(deleteDialog.result == SystemUiResult.ConfirmButtonSelection) {
                            tabbedPane.getPlayer().deletePlayLogByAlbumId(lv.deletePlayLogAlbumId);
                            // 删除之后刷新列表
                            initListData();
                        }
                    } 
                }
            ]
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: albumPage
            source: "asset:///pages/album.qml"
        },
        QTimer {
            id: stopRefreshTimer
            interval: 300
            onTimeout: {
                stopRefreshTimer.stop();
                refreshHeader.endRefresh();
            }
        }
    ]
    
    onCreationCompleted: {
        initListData();
    }
    
    function initListData() {
        dm.clear();
        dm.insert(0, JSON.parse(_misc.getConfig(common.settingsKey.playLog, "[]")));
        
        totalCount = dm.size();
    }
    
    function goAlbumPage(albumId) {
        var page = albumPage.createObject();
        page.albumId = albumId;
        nav.push(page);
    }
    
    function openAudioPlayerUI(trackId, albumInfo, mAlbumDetail, position) {
        tabbedPane.pushAudioPlayerUI(trackId, albumInfo, mAlbumDetail);
        // 设置播放位置
        _misc.setConfig(common.settingsKey.playPosition, position);
    }
}
