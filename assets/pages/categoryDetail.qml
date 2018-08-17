import bb.cascades 1.4
import tech.lwl 1.0
import "asset:///pages/child"

Page {
    id: categoryDetailPage
    property variant categoryId
    property variant keywordId // 此参数用于 itemType == 1 时，直接搜索一级搜索条件
    property variant metadatas: '' // 选中的 metadatas 搜索条件
    property bool listLoading: true
    property variant pageId: 1
    property variant totalPage: 1
    property variant totalCount: 0
    
    actionBarVisibility: ChromeVisibility.Compact
    titleBar: TitleBar {
        id: titleBar
        title: qsTr("加载中...")
        scrollBehavior: TitleBarScrollBehavior.Sticky
        
        acceptAction: ActionItem {
            enabled: !categoryDetailPage.keywordId
            title: common.shortCutKey.toggleMetaPanel + ' '  + (metadatasContainer.visible ? '⇉' : '⇊')
            onTriggered: {
                toggleMetaPanel();
            }
        }
    }
    
    shortcuts: [
        Shortcut {
            key: common.shortCutKey.toggleMetaPanel
            onTriggered: {
                toggleMetaPanel();
            }
        }
    ]
    
    Container {
        layout: DockLayout {}
        
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            KeywordsListView {
                id: keywordsListView
                keywordId: categoryDetailPage.keywordId
                onSelected: {
                    categoryDetailPage.keywordId = keywordId;
                    metadatasContainer.visible = !keywordId;
                }
            }
            MetadatasContainer {
                id: metadatasContainer
                setVisible: !categoryDetailPage.keywordId
                onSelected: {
                    categoryDetailPage.metadatas = metadatasInfo;
                }
            }
            
            WebImageView {
                visible: totalCount == 0 && !listLoading
                url: "asset:///images/no_content.png"
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                scalingMethod: ScalingMethod.AspectFill
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
            }
            
            ListView {
                visible: totalCount != 0
                property variant common_: common
                scrollRole: ScrollRole.Main
                
                function itemType(data, indexPath) {
                    return data.__type || 'item';
                }
                
                attachedObjects: [
                    ListScrollStateHandler {
                        onAtEndChanged: {
                            if(atEnd && !dm.isEmpty() && !listLoading && pageId < totalPage) {
                                if(keywordId) {
                                    common.apiKeywordAlbums(listRequester, categoryId, keywordId, pageId + 1);
                                }else {
                                    common.apiMetadataAlbums(listRequester, categoryId, metadatas, pageId + 1);
                                }
                            }
                        }
                    }
                ]
                
                onTriggered: {
                    goAlbumPage(dm.data(indexPath)['albumId']);
                }
                
                dataModel: ArrayDataModel {
                    id: dm
                }
                listItemComponents: [
                    ListItemComponent {
                        type: 'item'
                        AlbumItem {
                            listItemData: ListItemData
                            common: ListItem.view.common_
                        }
                    }
                ]
            }
        }
        // loading
        Container {
            visible: listLoading
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.create(0,0,0,0.2)
            layout: DockLayout {}
            
            ActivityIndicator {
                running: listLoading
                preferredHeight: ui.du(10)
                preferredWidth: ui.du(10)
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
            }
        }
    }
    
    attachedObjects: [
        Requester {
            id: keywordsRequester
            onFinished: {
                var rt = JSON.parse(data);
                if(rt['ret'] === 0) {
                    keywordsListView.keywords = rt['keywords'];
                    titleBar.title = rt['categoryInfo']['title'];
                }else {
                    _misc.showToast(rt['msg'] || qsTr("获取 keywords 失败，请重试"));
                }
            }
            onError: {
                _misc.showToast(error);
            }
        },
        Requester {
            id: metadatasRequester
            onFinished: {
                var rt = JSON.parse(data);
                if(rt['ret'] === 0) {
                    metadatasContainer.metadatas = rt['metadatas'];
                }else {
                    _misc.showToast(rt['msg'] || qsTr("获取 metadatas 失败，请重试"));
                }
            }
            onError: {
                _misc.showToast(error);
            }
        },
        Requester {
            id: listRequester
            onBeforeSend: {
                listLoading = true;
            }
            onFinished: {
                listLoading = false;
                var rt = JSON.parse(data);
                if(rt['ret'] === 0) {
                    var list = rt['list'];
                    
                    if(rt['pageId'] === 1) {
                        dm.clear();
                        dm.insert(0, list);
                        totalPage = rt['maxPageId'];
                        totalCount = rt['totalCount'];
                    }else {
                        dm.append(list);
                    }
                    pageId = rt['pageId'];
                }else {
                    _misc.showToast(rt['msg'] || qsTr("获取列表数据失败，请重试"));
                }
            }
            onError: {
                listLoading = false;
                _misc.showToast(error);
            }
        },
        QTimer {
            id: initTimer
            interval: 300
            onTimeout: {
                initTimer.stop();
                initSearchParams();
            }
        },
        ComponentDefinition {
            id: albumPage
            source: "asset:///pages/album.qml"
        }
    ]
    
    onCategoryIdChanged: {
        initTimer.start();
    }
    onKeywordIdChanged: {
        if(keywordId) { // 搜索一级条件
            common.apiKeywordAlbums(listRequester, categoryId, keywordId, 1);
        }else { // 搜索二级条件
            common.apiMetadataAlbums(listRequester, categoryId, metadatas, 1);
        }
    }
    onMetadatasChanged: {
        common.apiMetadataAlbums(listRequester, categoryId, metadatas, 1);
    }
    
    function goAlbumPage(albumId) {
        var page = albumPage.createObject();
        page.albumId = albumId;
        nav.push(page);
    }
    
    function initSearchParams() {
        common.apiKeywords(keywordsRequester, categoryId);
        common.apiMetadatas(metadatasRequester, categoryId);
        
        if(!keywordId) { // 搜索全部
            common.apiMetadataAlbums(listRequester, categoryId, '', 1);
        }
    }
    
    function toggleMetaPanel() {
        if(!categoryDetailPage.keywordId) {
            metadatasContainer.visible = !metadatasContainer.visible;
        }
    }
}
