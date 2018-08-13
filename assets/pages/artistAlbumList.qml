import bb.cascades 1.4
import tech.lwl 1.0
import "asset:///pages/child"

Page {
    property variant uid // 主播的ID
    property bool isLoading: true
    property variant totalCount: 0
    property variant maxPageId: 1
    property variant pageId: 1
    
    actionBarVisibility: ChromeVisibility.Compact
    
    titleBar: TitleBar {
        title: qsTr("全部专辑")
        scrollBehavior: TitleBarScrollBehavior.NonSticky
    }
    
    Container {
        layout: DockLayout {}
        // list
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container {
                Header {
                    title: qsTr("共有%1张专辑").arg(totalCount)
                }
                ListView {
                    id: lv
                    property variant common_: common
                    bottomPadding: ui.du(14)
                    
                    onTriggered: {
                        goAlbumPage(dm.data(indexPath)['albumId']);
                    }
                    dataModel: ArrayDataModel {
                        id: dm
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: ''
                            AlbumItem {
                                listItemData: ListItemData
                                common: ListItem.view.common_
                            }
                        }
                    ]
                    attachedObjects: [
                        ListScrollStateHandler {
                            onAtEndChanged: {
                                if(atEnd && !dm.isEmpty() && !isLoading && pageId < maxPageId) {
                                    common.apiArtistAlbums(listRequester, uid, pageId + 1, 20);
                                }
                            }
                        }
                    ]
                }
            }
        }
        // loding
        Container {
            visible: isLoading
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.create(0,0,0,0.2)
            ActivityIndicator {
                running: isLoading
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                preferredHeight: ui.du(10)
                preferredWidth: ui.du(10)
            }
        }
    }
    
    attachedObjects: [
        Requester {
            id: listRequester
            onBeforeSend: {
                isLoading = true;
            }
            onFinished: {
                isLoading = false;
                try {
                    var rt = JSON.parse(data);
                    if(rt.ret === 0) {
                        if(rt.pageId === 1) {
                            dm.clear();
                            dm.insert(0, rt['list']);
                            // 保存要用到的信息
                            totalCount = rt['totalCount'];
                            maxPageId = rt['maxPageId'];
                        }else {
                            dm.append(rt['list']);
                        }
                        
                        pageId = rt['pageId'];
                    }else {
                        _misc.showToast(qsTr("主播专辑列表异常，请重试"));
                    }
                }catch (e) {
                    _misc.showToast(qsTr("主播专辑列表获取失败，请重试"));
                }
            }
            onError: {
                isLoading = false;
                _misc.showToast(error);
            }
        },
        QTimer {
            id: initTimer
            interval: 300
            onTimeout: {
                initTimer.stop();
                common.apiArtistAlbums(listRequester, uid, 1, 20);
            }
        },
        ComponentDefinition {
            id: albumPage
            source: "asset:///pages/album.qml"
        }
    ]
    
    onUidChanged: {
        initTimer.start();
    }
    
    function goAlbumPage(albumId) {
        var page = albumPage.createObject();
        page.albumId = albumId;
        // page.from = 'artistIntroPage';
        nav.push(page);
    }
}
