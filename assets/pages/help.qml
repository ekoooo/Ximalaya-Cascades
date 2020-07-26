import bb.cascades 1.4
import tech.lwl 1.0
import "asset:///pages/child"

Page {
    objectName: "helpPage"
    
    actionBarVisibility: ChromeVisibility.Compact
    
    titleBar: TitleBar {
        title: qsTr("帮助")
        scrollBehavior: TitleBarScrollBehavior.Sticky
    }
    
    ScrollView {
        scrollRole: ScrollRole.Main
        
        Container {
            bottomPadding: ui.du(14)
            
            Header {
                title: qsTr("“播放记录”说明")
            }
            ItemContainer {
                layout_: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }
                Label {
                    text: qsTr("播放记录最多记录近 50 几条记录，当前声音播放位置每5秒记录一次，需要查看最新记录记得刷新列表。")
                    multiline: true
                }
                Label {
                    text: qsTr("如需删除某条记录，可长按进行删除")
                    textStyle {
                        base: SystemDefaults.TextStyles.SubtitleText
                        color: Color.Gray
                    }
                }
            }
            
            Divider {}
            Header {
                title: qsTr("专辑声音列表")
            }
            ItemContainer {
                layout_: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }
                Label {
                    text: qsTr("专辑声音列表可下拉选择声音排序规则：“正序/倒叙”，也可以进行翻页。")
                    multiline: true
                }
            }
            
            Divider {}
            Header {
                title: qsTr("快捷键说明")
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
                    textStyle.fontWeight: FontWeight.Bold
                }
            }
        }
    ]
}
