import bb.cascades 1.4

ListItemComponent {
    type: "displayStyleType:1"
    
    Container {
        id: top
        topMargin: ui.du(2)
        
        Container {
            leftPadding: ui.du(2)
            topPadding: ui.du(1)
            bottomPadding: ui.du(1)
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Container {
                verticalAlignment: VerticalAlignment.Fill
                preferredWidth: 6
                background: ui.palette.primary
            }
            Label {
                text: ListItemData['groupName']
                textStyle.color: ui.palette.secondaryTextOnPlain
            }
        }
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            layout: GridLayout {
                columnCount: 3
            }
            
            onCreationCompleted: {
                renderButtons();
            }
            
            function renderButtons() {
                var itemList = ListItemData['itemList'];
                var len = itemList.length;
                var b;
                for(var i = 0; i < len; i++) {
                    b = top.ListItem.view.btn.createObject();
                    b.info = itemList[i];
                    b.isLast = ((i + 1) % 3 === 0);
                    b.isCenter = false;
                    add(b);
                }
            }
        }
        Divider {
            opacity: 0
            topMargin: 0
        }
    }
}