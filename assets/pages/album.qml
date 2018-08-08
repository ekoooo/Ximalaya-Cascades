import bb.cascades 1.4
import tech.lwl 1.0
import "asset:///pages/child"

Page {
    id: albumPage
    
    property variant albumId // 专辑ID
    property bool listLoading: false
    property bool detailLoading: false
    property bool isAsc
    
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
            layout: DockLayout {}
            
            WebImageView {
                visible: listLoading
                url: "asset:///images/no_content.png"
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                scalingMethod: ScalingMethod.AspectFill
            }
            
            ListView {
                id: listLv
                property variant common_: common
                
                scrollRole: ScrollRole.Main
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                bottomPadding: ui.du(14)
                
                leadingVisual: Container {
                    leftPadding: ui.du(1)
                    rightPadding: ui.du(1)
                    topPadding: ui.du(1)
                    bottomPadding: ui.du(1)
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    DropDown {
                        id: isAscDropDown
                        property bool isInitChange: true
                        
                        title: qsTr("顺序")
                        options: [
                            Option {
                                text: qsTr("正序")
                                value: true
                            },
                            Option {
                                text: qsTr("倒叙")
                                value: false
                            }
                        ]
                        onSelectedValueChanged: {
                            if(isAscDropDown.isInitChange) {
                                isAscDropDown.isInitChange = false;
                                return;
                            }
                            
                            // 存入缓存中，供播放器用（顺序在获取专辑信息前面）
                            _misc.setConfig(common.settingsKey.trackListIsAsc + albumId, selectedValue ? "1" : "0");
                            
                            getAlbumInfo(pageIdDropDown.selectedValue);
                        }
                    }
                    
                    DropDown {
                        id: pageIdDropDown
                        property variant ddCurrentAlbumInfo: currentAlbumInfo
                        property bool isInitChange: true
                        property bool isAddOptions: false
                        
                        title: qsTr("翻页")
                        enabled: true
                        onSelectedValueChanged: {
                            if(pageIdDropDown.isInitChange) {
                                pageIdDropDown.isInitChange = false;
                                return;
                            }
                            
                            getAlbumInfo(selectedValue);
                        }
                        onDdCurrentAlbumInfoChanged: {
                            if(!ddCurrentAlbumInfo) {return}
                            
                            if(!isAddOptions) {
                                isAddOptions = true;
                                
                                var data = ddCurrentAlbumInfo['data'];
                                var maxPageId = data['maxPageId'];
                                var pageSize = data['pageSize'];
                                var pageId = data['pageId'];
                                var totalCount = data['totalCount'];
                                
                                var option;
                                
                                for(var i = 1; i <= maxPageId; i++) {
                                    option = dropDownOption.createObject();
                                    option.value = i;
                                    option.selected = i == pageId;
                                    option.text = qsTr("第") + i + qsTr("页");
                                    
                                    add(option);
                                }
                            }
                        }
                        
                        attachedObjects: [
                            ComponentDefinition {
                                id: dropDownOption
                                Option {}
                            }
                        ]
                    }
                }
                
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
                        TrackItem {
                            listItemData: ListItemData
                            common: ListItem.view.common_
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
        isAsc = _misc.getConfig(common.settingsKey.trackListIsAsc + albumId, "1") === "1";
        isAscDropDown.setSelectedIndex(isAsc ? 0 : 1);
        
        initTimer.start();
    }
    
    // 获取声音信息
    function getAlbumInfo(pageId) {
        common.apiAlbumInfo(albumListRequester, albumId, pageId);
    }
}
