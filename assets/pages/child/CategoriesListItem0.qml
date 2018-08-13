import bb.cascades 1.4
import "asset:///pages/child"
import "asset:///components"

ListItemComponent {
    type: "displayStyleType:0"
    
    Container {
        id: top
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            layout: GridLayout {
                columnCount: 4
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
                    b.isLast = ((i + 1) % 4 === 0);
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