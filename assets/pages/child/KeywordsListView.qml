import bb.cascades 1.4

Container {
    id: listViewContainer
    visible: false
    property variant keywords
    property variant boxHeight: ui.du(8)
    
    background: ui.palette.plain
    preferredHeight: boxHeight
    
    signal selected(variant keywordId);
    
    ListView {
        property variant boxHeight_: boxHeight
        property variant keywordId_ // 当前选中的 keywordId
        
        layout: StackListLayout {
            orientation: LayoutOrientation.LeftToRight
            headerMode: ListHeaderMode.None
        }
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        scrollIndicatorMode: ScrollIndicatorMode.None
        scrollRole: ScrollRole.None
        
        onTriggered: {
            keywordId_ = dm.data(indexPath)['keywordId'];
            listViewContainer.selected(keywordId_);
        }
        
        dataModel: ArrayDataModel {
            id: dm
        }
        listItemComponents: [
            ListItemComponent {
                type: ''
                Container {
                    id: itemContainer
                    layout: DockLayout {}
                    preferredHeight: ListItem.view.boxHeight_
                    leftPadding: ui.du(2)
                    rightPadding: ui.du(2)
                    
                    Label {
                        verticalAlignment: VerticalAlignment.Center
                        text: ListItemData['keywordName']
                        textStyle.color: ListItemData['keywordId'] == itemContainer.ListItem.view.keywordId_ ? ui.palette.primary : ui.palette.textOnPlain
                    }
                }
            }
        ]
    }
    
    Divider {
        topMargin: 0
    }
    onKeywordsChanged: {
        var list = keywords || [];
        list.unshift({
            keywordName: "全部"
        });
        
        dm.clear();
        dm.insert(0, list);
        
        listViewContainer.visible = true;
    }
}