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
            property variant btn: categoryItemButton
            property variant lastViewCategory: tabbedPane.lastViewCategory
            property variant categoryDetailPage: categoryDetailPage
            property variant nav_: nav
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            bottomPadding: ui.du(14)
            enabled: false // 取消聚焦
            
            dataModel: ArrayDataModel {
                id: dm
            }
            function itemType(data, indexPath) {
                return 'displayStyleType:' + data.displayStyleType;
            }
            listItemComponents: [categoryListItem2, categoryListItem0, categoryListItem1]
            attachedObjects: [
                CategoryListItem2 {
                    id: categoryListItem2
                },
                CategoryListItem0 {
                    id: categoryListItem0
                },
                CategoryListItem1 {
                    id: categoryListItem1
                },
                ComponentDefinition {
                    id: categoryItemButton
                    content: CategoryItemButton {}
                },
                ComponentDefinition {
                    id: categoryDetailPage
                    source: "asset:///pages/categoryDetail.qml"
                }
            ]
        }
        
        // loading
        Container {
            visible: isLoading
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.create(0,0,0,0.2)
            layout: DockLayout {}
            
            ActivityIndicator {
                running: isLoading
                preferredHeight: ui.du(10)
                preferredWidth: ui.du(10)
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
            }
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
