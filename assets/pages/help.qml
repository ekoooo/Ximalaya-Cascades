import bb.cascades 1.4
import tech.lwl 1.0
import "asset:///pages/child"

Page {
    objectName: "helpPage"
    
    actionBarVisibility: ChromeVisibility.Compact
    
    ScrollView {
        scrollRole: ScrollRole.Main
        
        Container {
            bottomPadding: ui.du(14)
            Header {
                title: qsTr("模块&功能")
            }
            ItemContainer {
                layout_: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }
                Label {
                    text: qsTr("分类、搜索、分类列表等。")
                    multiline: true
                }
                Label {
                    text: qsTr("查看、播放专辑、查看主播、定时关闭等。")
                    multiline: true
                }
                Label {
                    text: qsTr("帮助、赞助、关于、设置。")
                    multiline: true
                }
            }
            Divider {}
            Header {
                title: qsTr("快捷键")
            }
            Container {
                id: shortCutKeyContainer
                
                onCreationCompleted: {
                    var shortCutKey = common.shortCutKey;
                    var shortCutList = shortCutKey['shortCutList'];
                    var key, label, i, length = shortCutList.length, labelKey;
                    
                    for(i = 0; i < length; i++) {
                        key = shortCutKey[shortCutList[i]];
                        label = shortCutKey[shortCutList[i] + 'Label'];
                        
                        var item = shortCutKeyItem.createObject();
                        item.key = key;
                        item.label = label;
                        
                        shortCutKeyContainer.add(item);
                    }
                }
            }
            ItemContainer {
                Label {
                    text: qsTr("为保证不与系统快自带捷键冲突，有的快捷键是根据拼音首字母指定的。")
                    textStyle {
                        base: SystemDefaults.TextStyles.SubtitleText
                        color: Color.Gray
                    }
                    multiline: true
                }
            }
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: shortCutKeyItem
            ItemContainer {
                property variant key;
                property variant label;
                Label {
                    text: label
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                }
                Label {
                    text: key
                }
            }
        }
    ]
}
