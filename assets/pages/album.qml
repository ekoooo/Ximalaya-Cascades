import bb.cascades 1.4
import tech.lwl 1.0

Page {
    id: albumPage
    
    property variant albumId // 专辑ID
    property bool listLoading: false
    property bool detailLoading: false
    
    property variant currentAlbumInfo // 当前页面的信息
    
    actionBarVisibility: ChromeVisibility.Compact
    
    titleBar: TitleBar {
        scrollBehavior: TitleBarScrollBehavior.Sticky
        kind: TitleBarKind.Segmented
        options: [
            Option {
                text: qsTr("声音列表")
                value: "list"
            },
            Option {
                text: qsTr("专辑信息")
                value: "detail"
            }
        ]
        onSelectedValueChanged: {
            if(selectedValue === 'list') {
                detailContainer.visible = false;
                listContainer.visible = true;
            }else {
                listContainer.visible = false;
                detailContainer.visible = true;
            }
        }
    }
    
    Container {
        layout: DockLayout {}
        // list
        Container {
            id: listContainer
            visible: true
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            ListView {
                id: listLv
                property variant common_: common
                
                scrollRole: ScrollRole.Main
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                onTriggered: {
                    // 付费声音处理
                    if(common.isNotFree(listDm.data(indexPath))) {
                        _misc.showToast(qsTr("此集为付费声音，无法播放"));
                        return;
                    }
                    
                    tabbedPane.pushAudioPlayerUI(listDm.data(indexPath)['trackId'], currentAlbumInfo);
                }
                
                dataModel: ArrayDataModel {
                    id: listDm
                }
                listItemComponents: [
                    ListItemComponent {
                        type: ""
                        CustomListItem {
                            id: trackItem
                            Container {
                                leftPadding: ui.du(2)
                                rightPadding: ui.du(2)
                                topPadding: ui.du(2)
                                bottomPadding: ui.du(2)
                                verticalAlignment: VerticalAlignment.Center
                                
                                Label {
                                    text: ListItemData['title']
                                    textStyle {
                                        color: trackItem.ListItem.view.common_.isNotFree(ListItemData) ? Color.Gray : ui.palette.textOnPlain
                                    }
                                }
                            }
                        }
                    }
                ]
            }
        }
        // detail
        Container {
            id: detailContainer
            visible: false
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
        }
    }
    
    attachedObjects: [
        Requester {
            id: albumDetailRequester
            onBeforeSend: {
                detailLoading = true;
            }
            onFinished: {
                detailLoading = false;
            }
            onError: {
                detailLoading = false;
                _misc.showToast(error);
            }
        },
        Requester {
            id: albumListRequester
            onBeforeSend: {
                listLoading = true;
            }
            onFinished: {
                listLoading = false;
                
                var rs = JSON.parse(data);
                
                if(!rs['data'] || !rs.data['list']) {
                    _misc.showToast(qsTr("声音列表加载失败"));
                    return;
                }
                
                listDm.clear();
                listDm.insert(0, rs.data.list);
                
                albumPage.currentAlbumInfo = rs;
            }
            onError: {
                listLoading = false;
                _misc.showToast(error);
            }
        },
        QTimer {
            id: initTimer
            interval: 200
            onTimeout: {
                initTimer.stop();
                albumPage.getAlbumInfo(1);
            }
        }
    ]
    
    onAlbumIdChanged: {
        initTimer.start();
    }
    
    // 获取声音信息
    function getAlbumInfo(pageId) {
        common.apiAlbumInfo(albumListRequester, albumId, pageId);
    }
}
