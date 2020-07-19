import bb.cascades 1.4
import tech.lwl 1.0
import "asset:///pages/child"

Page {
    objectName: "settingsPage"
    
    actionBarVisibility: ChromeVisibility.Compact
    
    property variant imageCacheSize: "calcing"
    property variant requestCacheSize: "calcing"
    
    onCreationCompleted: {
        calcInfo(true);
    }
    
    function calcInfo(init) {
        if(init) {
            backButtonVisiableToggleButton.checked = _misc.getConfig(common.settingsKey.backButtonVisiable, "1") === "1";
            themeToggleButton.checked = _misc.getConfig(common.settingsKey.theme, "Light") === "Dark";

            var sourceType = _misc.getConfig(common.settingsKey.audioPlayerSourceType, "playPathHq");
            playSourceDropDown.setSelectedIndex(common.sourceTypeArr.indexOf(sourceType));
        }
        
        imageCacheSize = _misc.webImageViewCacheSize();
        requestCacheSize = _misc.requesterCacheSize();
    }
    
    ScrollView {
        scrollRole: ScrollRole.Main
        
        Container {
            bottomPadding: ui.du(14)
            // 视觉设置
            Container {
                Header {
                    title: qsTr("视觉设置")
                }
                ItemContainer {
                    Label {
                        verticalAlignment: VerticalAlignment.Center
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        text: qsTr("应用暗色主题")
                    }
                    
                    ToggleButton {
                        id: themeToggleButton
                        verticalAlignment: VerticalAlignment.Center
                        onCheckedChanged: {
                            if(checked) {
                                _misc.setConfig(common.settingsKey.theme, "Dark");
                                _misc.setTheme("Dark");
                            }else {
                                _misc.setConfig(common.settingsKey.theme, "Bright");
                                _misc.setTheme("Bright");
                            }
                        }
                    }
                }
                ItemContainer {
                    Label {
                        text: qsTr("与文章护眼模式相互独立，护眼模式直接在文章页中可设置")
                        textStyle {
                            base: SystemDefaults.TextStyles.SubtitleText
                            color: Color.Gray
                        }
                        multiline: true
                    }
                }
                Divider {}
            }
            
            // 播放音质设置
            Container {
                Header {
                    title: qsTr("设置播放源音质")
                }
                
                ItemContainer {
                    DropDown {
                        id: playSourceDropDown
                        title: qsTr("音质")
                        options: []
                        onCreationCompleted: {
                            var sourceTypeArr = common.sourceTypeArr;
                            
                            for(var i = 0; i < sourceTypeArr.length; i++) {
                                var option = dropDownOption.createObject();
                                dropDownOption.createObject();
                                option.text = sourceTypeArr[i];
                                option.value = sourceTypeArr[i];
                                
                                add(option);
                            }
                        }
                        onSelectedValueChanged: {
                            _misc.setConfig(common.settingsKey.audioPlayerSourceType, selectedValue);
                        }
                        
                        attachedObjects: [
                            ComponentDefinition {
                                id: dropDownOption
                                Option {
                                    
                                }
                            }
                        ]
                    }
                }
                
                Divider {}
            }
            
            // 是否显示返回按钮
            Container {
                Header {
                    title: qsTr("返回按钮")
                }
                ItemContainer {
                    Label {
                        verticalAlignment: VerticalAlignment.Center
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        text: qsTr("是否显示返回按钮")
                    }
                    
                    ToggleButton {
                        id: backButtonVisiableToggleButton
                        verticalAlignment: VerticalAlignment.Center
                        onCheckedChanged: {
                            if(checked) {
                                _misc.setConfig(common.settingsKey.backButtonVisiable, "1");
                            }else {
                                _misc.setConfig(common.settingsKey.backButtonVisiable, "0");
                            }
                            
                            // 更新主页信息
                            tabbedPane.backButtonVisiable = checked;
                        }
                    }
                }
                Divider {}
            }
            
            // 应用缓存
            Container {
                Header {
                    title: qsTr("应用缓存")
                }
                ItemContainer {
                    Label {
                        verticalAlignment: VerticalAlignment.Bottom
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        text: qsTr("图片缓存")
                    }
                    
                    Label {
                        verticalAlignment: VerticalAlignment.Bottom
                        text: imageCacheSize
                        implicitLayoutAnimationsEnabled: false
                        textStyle {
                            base: SystemDefaults.TextStyles.SubtitleText
                        }
                    }
                }
                ItemContainer {
                    Label {
                        verticalAlignment: VerticalAlignment.Bottom
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        text: qsTr("数据缓存")
                    }
                    Label {
                        verticalAlignment: VerticalAlignment.Bottom
                        text:  requestCacheSize
                        implicitLayoutAnimationsEnabled: false
                        textStyle {
                            base: SystemDefaults.TextStyles.SubtitleText
                        }
                    }
                }
                ItemContainer {
                    Label {
                        text: qsTr("图片最大缓存：100MB。数据最大缓存：100MB")
                        textStyle {
                            base: SystemDefaults.TextStyles.SubtitleText
                            color: Color.Gray
                        }
                        multiline: true
                    }
                }
                ItemContainer {
                    layout_: DockLayout {
                    
                    }
                    horizontalAlignment: HorizontalAlignment.Fill
                    Button {
                        text: qsTr("清空缓存")
                        horizontalAlignment: HorizontalAlignment.Center
                        onClicked: {
                            try {
                                _misc.clearCache();
                                calcInfo();
                            }catch(e) {
                                _misc.showToast(e);
                            }
                        }
                    }
                }
                Divider {}
            }
            
            // 重置应用
            Container {
                Header {
                    title: qsTr("重置应用")
                }
                ItemContainer {
                    Label {
                        text: qsTr("重置应用将恢复默认设置，以及清空缓存")
                        textStyle {
                            base: SystemDefaults.TextStyles.SubtitleText
                            color: Color.Gray
                        }
                        multiline: true
                    }
                }
                ItemContainer {
                    layout_: DockLayout {
                    
                    }
                    horizontalAlignment: HorizontalAlignment.Fill
                    Button {
                        text: qsTr("重置应用")
                        horizontalAlignment: HorizontalAlignment.Center
                        onClicked: {
                            try {
                                _misc.reset();
                                calcInfo(true);
                            }catch(e) {
                                _misc.showToast(e);
                            }
                        }
                    }
                }
            }
        }
    }
}
