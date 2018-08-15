import bb.cascades 1.4
import tech.lwl 1.0
import "asset:///pages/child"

Page {
    property bool isLoading: true
    actionBarVisibility: ChromeVisibility.Compact
    
    titleBar: TitleBar {
        title: qsTr("分类")
        scrollBehavior: TitleBarScrollBehavior.NonSticky
    }
    
    Container {
        layout: DockLayout {}
        
        ListView {
            property variant btn: categoriesItemButton
            property variant lastViewCategory: tabbedPane.lastViewCategory
            
            bottomPadding: ui.du(14)
            
            dataModel: ArrayDataModel {
                id: dm
            }
            function itemType(data, indexPath) {
                return 'displayStyleType:' + data.displayStyleType;
            }
            listItemComponents: [categoriesListViewListItem, categoriesListItem0, categoriesListItem1]
            attachedObjects: [
                CategoriesListViewListItem {
                    id: categoriesListViewListItem
                },
                CategoriesListItem0 {
                    id: categoriesListItem0
                },
                CategoriesListItem1 {
                    id: categoriesListItem1
                },
                ComponentDefinition {
                    id: categoriesItemButton
                    content: CategoriesItemButton {}
                }
            ]
        }
        
    }
    
    attachedObjects: [
        Requester {
            id: categoriesRequester
            onBeforeSend: {
                isLoading = true;
            }
            onFinished: {
                isLoading = false;
                try {
                    var rt = JSON.parse(data);
                    if(rt.ret === 0) {
                        var list = rt['list']
                        // 给最近浏览留个位置
                        list.unshift({
                            displayStyleType: '-1'
                        });
                        dm.clear();
                        dm.insert(0, list);
                    }else {
                        _misc.showToast(rt['msg'] || qsTr("主页数据异常，请重试"));
                    }
                }catch (e) {
                    _misc.showToast(qsTr("主页数据格式错误，请重试"));
                }
            }
            onError: {
                isLoading = false;
                _misc.showToast(error);
            }
        }
    ]
    
    onCreationCompleted: {
        common.apiCategories(categoriesRequester);
    }
}
