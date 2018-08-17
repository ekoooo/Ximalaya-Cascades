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
        preferredHeight: ui.du(16) // 12 + 2 + 2
        
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        // Cover Container
        Container {
            id: coverContainer
            preferredWidth: ui.du(12)
            preferredHeight: ui.du(12)
            layout: DockLayout {}
            
            WebImageView {
                url: listItemData['cover_path'] || listItemData['coverLarge'] || ''
                failImageSource: "asset:///images/ting_default.png"
                loadingImageSource: "asset:///images/ting_default.png"
                scalingMethod: ScalingMethod.AspectFill
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
            }
            
            WebImageView {
                visible: listItemData['is_paid'] || listItemData['isPaid'] || false
                url: "asset:///images/pay_icon.png"
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Top
                preferredWidth: coverContainer.preferredWidth / 3
                preferredHeight: coverContainer.preferredHeight / 3
            }
        }
        // Audio Info Container
        Container {
            leftPadding: ui.du(2)
            rightPadding: ui.du(2)
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
            verticalAlignment: VerticalAlignment.Fill
            
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Container {
                    visible: listItemData['is_finished'] == 2 || listItemData['serialState'] == 2
                    background: ui.palette.primary
                    leftPadding: ui.du(0.4)
                    rightPadding: ui.du(0.4)
                    rightMargin: ui.du(1)
                    verticalAlignment: VerticalAlignment.Center
                    Label {
                        text: qsTr("完结")
                        textStyle {
                            base: SystemDefaults.TextStyles.SmallText
                            color: ui.palette.textOnPrimary
                        }
                    }
                }
                Container {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    Label {
                        text: listItemData['title']
                    }
                }
            }
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                Label {
                    text: listItemData['custom_title'] || listItemData['intro']
                    textStyle {
                        base: SystemDefaults.TextStyles.SubtitleText
                        color: Color.Gray
                    }
                }
            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                WebImageView {
                    url: "asset:///images/sound_playtimes_icon.png"
                    preferredWidth: ui.du(3)
                    preferredHeight: ui.du(3)
                    scalingMethod: ScalingMethod.AspectFill
                }
                Container {
                    rightMargin: ui.du(2)
                    Label {
                        text: common.parsePlayerNum(listItemData['play'] || listItemData['playTimes'] || listItemData['playsCounts'])
                        textStyle {
                            base: SystemDefaults.TextStyles.SmallText
                            color: Color.Gray
                        }
                    }
                }
                WebImageView {
                    url: "asset:///images/album_tracks_icon.png"
                    preferredWidth: ui.du(3)
                    preferredHeight: ui.du(3)
                    scalingMethod: ScalingMethod.AspectFill
                }
                Container {
                    leftMargin: ui.du(1)
                    
                    Label {
                        text: listItemData['tracks'] + qsTr("集")
                        textStyle {
                            base: SystemDefaults.TextStyles.SmallText
                            color: Color.Gray
                        }
                    }
                }
            }
        }
    }
}
