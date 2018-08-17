import bb.cascades 1.4

ListItemComponent {
    type: "displayStyleType:-1"
    ScrollView {
        id: top
        scrollViewProperties.scrollMode: ScrollMode.Horizontal
        
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
                property variant lastViewBtnData: JSON.parse(top.ListItem.view.lastViewCategory)
                
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                CategoryHistoryButton {
                    id: lastViewBtn1
                    label: "无"
                    onClick: {
                        lastViewBtnContainer.goCategoryDetailPage(0);
                    }
                }
                CategoryHistoryButton {
                    id: lastViewBtn2
                    label: "无"
                    onClick: {
                        lastViewBtnContainer.goCategoryDetailPage(1);
                    }
                }
                CategoryHistoryButton {
                    id: lastViewBtn3
                    label: "无"
                    onClick: {
                        lastViewBtnContainer.goCategoryDetailPage(2);
                    }
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
                
                function goCategoryDetailPage(index) {
                    var page = top.ListItem.view.categoryDetailPage.createObject();
                    page.categoryId = lastViewBtnData[index]['itemDetail']['categoryId'];
                    if(lastViewBtnData[index]['itemType'] === 1) {
                        page.keywordId = lastViewBtnData[index]['itemDetail']['keywordId'];
                    }
                    top.ListItem.view.nav_.push(page);
                }
            }
        }
    }
}