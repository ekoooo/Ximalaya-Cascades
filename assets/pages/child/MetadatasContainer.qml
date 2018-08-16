import bb.cascades 1.4

Container {
    id: container
    visible: false
    
    property variant metadatas
    property variant boxHeight: ui.du(5)
    property variant padding: ui.du(1)
    property variant activeInfo: { // 当前选中的
        
    }
    signal selected(variant metadatasInfo);
    
    preferredHeight: 0
    background: ui.palette.plain
    topPadding: padding
    bottomPadding: padding
    
    ListView {
        property variant item_: item
        dataModel: ArrayDataModel {
            id: dm
        }
        
        listItemComponents: [
            ListItemComponent {
                type: ''
                ScrollView {
                    id: sv
                    scrollViewProperties {
                        scrollMode: ScrollMode.Horizontal
                    }
                    
                    Container {
                        id: itemContainer
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        onCreationCompleted: {
                            var values = ListItemData['metadataValues'];
                            
                            sv.ListItem.view.addItem(itemContainer, ListItemData, ListItemData['id']);
                            for (var i = 0; i < values.length; i ++) {
                                sv.ListItem.view.addItem(itemContainer, values[i], ListItemData['id']);
                            }
                        }
                    }
                }
            }
        ]
        
        function addItem(thiz, data, top) {
            var obj = item.createObject();
            obj.data = data;
            obj.top = top;
            thiz.add(obj);
        }
        
        attachedObjects: [
            ComponentDefinition {
                id: item
                content: Container {
                    property variant data: {}
                    property variant top
                    
                    layout: DockLayout {}
                    preferredHeight: boxHeight
                    leftPadding: ui.du(2)
                    rightPadding: ui.du(2)
                    
                    Label {
                        verticalAlignment: VerticalAlignment.Center
                        text: data['displayName']
                        textStyle.base: SystemDefaults.TextStyles.SubtitleText
                        textStyle.color: (container.activeInfo[top] == data['id'] || (top == data['id'] && !container.activeInfo[top])) ? ui.palette.primary : ui.palette.secondaryTextOnPlain
                    }
                    
                    onTouch: {
                        if(event.isUp()) {
                            var ai = container.activeInfo;
                            // 如果是选择了默认全部，则为空
                            if(top == data['id']) {
                                delete ai[top]
                            }else {
                                ai[top] = data['id'];
                            }
                            
                            var activeInfoStr = JSON.stringify(container.activeInfo);
                            var aiStr = JSON.stringify(ai);
                            if(activeInfoStr !== aiStr) {
                                var reg = new RegExp('[\{\}\"]', 'g');
                                var aiStr = aiStr.replace(reg, '');
                                // 搜索条件变更
                                container.selected(aiStr);
                            }
                            
                            container.activeInfo = ai;
                        }
                    }
                }
            }
        ]
    }
    
    onMetadatasChanged: {
        dm.clear();
        dm.insert(0, metadatas);
        
        container.preferredHeight = (boxHeight * metadatas.length) + (container.padding * 2);
        container.visible = true;
    }
}