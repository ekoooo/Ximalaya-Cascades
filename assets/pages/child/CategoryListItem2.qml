import bb.cascades 1.4

ListItemComponent {
    type: "displayStyleType:-1"
    Container {
        id: lastViewItemContainer
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            horizontalAlignment: HorizontalAlignment.Fill
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: ui.du(3)
                bottomPadding: ui.du(3)
                rightPadding: ui.du(3)
                
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
                        background: ui.palette.plain
                    }
                    Label {
                        text: qsTr("最近浏览")
                        textStyle.color: ui.palette.secondaryTextOnPlain
                    }
                }
            }
            Container {
                id: lastViewBtnContainer
                property variant lastViewBtnData: JSON.parse(lastViewItemContainer.ListItem.view.lastViewCategory)
                
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                CategoryItemButtonBox {
                    id: lastViewBtn1
                    label: "无"
                }
                CategoryItemButtonBox {
                    id: lastViewBtn2
                    label: "无"
                }
                CategoryItemButtonBox {
                    id: lastViewBtn3
                    label: "无"
                }
                
                onLastViewBtnDataChanged: {
                    var len = lastViewBtnData.length;
                    if(len >= 1) {
                        lastViewBtn1.label = getLabel(0)
                    }
                    if(len >= 2) {
                        lastViewBtn2.label = getLabel(1)
                    }
                    if(len >= 3) {
                        lastViewBtn3.label = getLabel(2)
                    }
                }
                
                function getLabel(index) {
                    return lastViewBtnData[index]['itemType'] == 0 ? lastViewBtnData[index]['itemDetail']['title'] : lastViewBtnData[index]['itemDetail']['keywordName'];
                }
            }
        }
        Divider {
            opacity: 0
            topMargin: 0
        }
    }
}