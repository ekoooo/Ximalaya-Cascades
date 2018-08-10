import bb.cascades 1.4
import tech.lwl 1.0

CustomListItem {
    property variant listItemData
    Container {
        leftPadding: ui.du(2)
        rightPadding: ui.du(2)
        topPadding: ui.du(2)
        bottomPadding: ui.du(2)
        preferredHeight: ui.du(16) // 12 + 2 + 2
        
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        // 头像 Container
        Container {
            preferredWidth: ui.du(12)
            preferredHeight: ui.du(12)
            layout: DockLayout {}
            
            WebImageView {
                url: listItemData['smallPic'] || ''
                failImageSource: "asset:///images/avatars_icon.png"
                loadingImageSource: "asset:///images/avatars_icon.png"
                scalingMethod: ScalingMethod.AspectFill
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
            }
        }
        // 信息 Container
        Container {
            leftPadding: ui.du(2)
            rightPadding: ui.du(2)
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
            verticalAlignment: VerticalAlignment.Fill
            
            Container {
                verticalAlignment: VerticalAlignment.Top
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Container {
                    Label {
                        text: listItemData['nickname']
                    }
                }
                WebImageView {
                    url: getUrl()
                    preferredHeight: ui.du(2.5)
                    scalingMethod: ScalingMethod.AspectFit
                    verticalAlignment: VerticalAlignment.Center
                    
                    function getUrl() {
                        if(listItemData['anchorGrade'] > 0 && listItemData['anchorGrade'] <= 17) {
                            return "asset:///images/user_grade/individual_orangeV" + listItemData['anchorGrade'] + ".png";
                        }else {
                            return "";
                        }
                    }
                }
            }
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                layout: DockLayout {
                    
                }
                Label {
                    text: listItemData['personDescribe'] || qsTr("暂无简介")
                    textStyle {
                        base: SystemDefaults.TextStyles.SmallText
                        color: ui.palette.primary
                    }
                    verticalAlignment: VerticalAlignment.Center
                }
            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Label {
                    text: qsTr("声音") + listItemData['tracks_counts']
                    textStyle {
                        base: SystemDefaults.TextStyles.SmallText
                        color: Color.Gray
                    }
                }
                Label {
                    text: qsTr("粉丝") + listItemData['followers_counts']
                    textStyle {
                        base: SystemDefaults.TextStyles.SmallText
                        color: Color.Gray
                    }
                }
            }
        }
    }
}
