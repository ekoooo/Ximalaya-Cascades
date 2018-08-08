import bb.cascades 1.4
import tech.lwl 1.0

CustomListItem {
    property variant listItemData
    property variant common
    
    Container {
        leftPadding: ui.du(2)
        rightPadding: ui.du(2)
        topPadding: ui.du(2)
        bottomPadding: ui.du(2)
        preferredHeight: ui.du(14) // 10 + 2 + 2
        verticalAlignment: VerticalAlignment.Center
        
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        // Cover Container
        Container {
            preferredWidth: ui.du(10)
            preferredHeight: ui.du(10)
            
            layout: DockLayout {}
            
            WebImageView {
                url: listItemData['coverMiddle'] || ''
                failImageSource: "asset:///images/play_in_track_item.png"
                loadingImageSource: "asset:///images/play_in_track_item.png"
                scalingMethod: ScalingMethod.AspectFit
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
            }
        }
        // Track Info Container
        Container {
            leftPadding: ui.du(2)
            rightPadding: ui.du(2)
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
            verticalAlignment: VerticalAlignment.Fill
            // title
            Container {
                Label {
                    text: listItemData['title']
                    textStyle {
                        color: common.isNotFree(ListItemData) ? Color.Gray : ui.palette.textOnPlain
                    }
                }
            }
            // info
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                
                WebImageView {
                    url: "asset:///images/sound_playtimes_icon.png"
                    preferredWidth: ui.du(3)
                    preferredHeight: ui.du(3)
                    scalingMethod: ScalingMethod.AspectFill
                    verticalAlignment: VerticalAlignment.Center
                }
                Container {
                    rightMargin: ui.du(2)
                    Label {
                        text: common.parsePlayerNum(listItemData['playtimes'])
                        textStyle {
                            base: SystemDefaults.TextStyles.SmallText
                            color: Color.Gray
                        }
                    }
                    verticalAlignment: VerticalAlignment.Center
                }
                WebImageView {
                    url: "asset:///images/sound_comments_icon.png"
                    preferredWidth: ui.du(2.3)
                    preferredHeight: ui.du(2.3)
                    scalingMethod: ScalingMethod.AspectFit
                    verticalAlignment: VerticalAlignment.Center
                }
                Container {
                    rightMargin: ui.du(2)
                    Label {
                        text: listItemData['comments']
                        textStyle {
                            base: SystemDefaults.TextStyles.SmallText
                            color: Color.Gray
                        }
                    }
                    verticalAlignment: VerticalAlignment.Center
                }
                WebImageView {
                    url: "asset:///images/sound_duration_icon.png"
                    preferredWidth: ui.du(2.5)
                    preferredHeight: ui.du(2.5)
                    scalingMethod: ScalingMethod.AspectFill
                    verticalAlignment: VerticalAlignment.Center
                }
                Container {
                    rightMargin: ui.du(2)
                    Label {
                        text: common.formatPlayerDuration(listItemData['duration'] * 1000)
                        textStyle {
                            base: SystemDefaults.TextStyles.SmallText
                            color: Color.Gray
                        }
                    }
                    verticalAlignment: VerticalAlignment.Center
                }
            }
        }
    }
}