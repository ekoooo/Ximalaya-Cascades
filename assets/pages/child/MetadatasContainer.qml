import bb.cascades 1.4

Container {
    id: container
    visible: false
    
    property bool setVisible
    property variant metadatas
    property variant boxHeight: ui.du(5)
    property variant padding: ui.du(1)
    property variant activeInfo: { // 当前选中的
        
    }
    property variant insertIndexInfo: { // 二级中的子级
        
    }
    signal selected(variant metadatasInfo);
    
    preferredHeight: 0
    background: ui.palette.plain
    topPadding: padding
    bottomPadding: padding
    
    ListView {
        id: lv
        property variant item_: item
        scrollIndicatorMode: ScrollIndicatorMode.None
        scrollRole: ScrollRole.None
        
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
                        property variant listItemData: ListItemData
                        
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        onListItemDataChanged: {
                            var values = ListItemData['metadataValues'];
                            removeAll(); // 必须清理
                            
                            sv.ListItem.view.addItem(itemContainer, ListItemData, ListItemData['id'], ListItemData['__index']);
                            for (var i = 0; i < values.length; i ++) {
                                sv.ListItem.view.addItem(itemContainer, values[i], ListItemData['id'], ListItemData['__index']);
                            }
                        }
                    }
                }
            }
        ]
        
        function addItem(thiz, data, top, index) {
            var obj = item.createObject();
            obj.data = data;
            obj.top = top;
            obj.index = index;
            thiz.add(obj);
        }
        
        function updateHeight() {
            container.preferredHeight = (boxHeight * dm.size()) + (container.padding * 2);
        }
        
        function deleteChildMetas(index, len) {
            if(len) {
                var tmpAI = activeInfo;
                
                for(var i = index + len; i > index; i--) {
                    // 删除选择的条件
                    var topId = dm.data([i])['id'];
                    if(topId in tmpAI) {
                        delete tmpAI[topId];
                    }
                    
                    dm.removeAt(i);
                }
                
                activeInfo = tmpAI;
            }
        }
        
        attachedObjects: [
            ComponentDefinition {
                id: item
                content: Container {
                    property variant data: {}
                    property variant top
                    property variant index
                    
                    layout: DockLayout {}
                    preferredHeight: boxHeight
                    leftPadding: ui.du(2)
                    rightPadding: ui.du(2)
                    
                    // background: index != undefined ? Color.Transparent : Color.White
                    
                    Label {
                        verticalAlignment: VerticalAlignment.Center
                        text: data['displayName']
                        textStyle.base: SystemDefaults.TextStyles.SubtitleText
                        textStyle.color: (container.activeInfo[top] == data['id'] || (top == data['id'] && !container.activeInfo[top])) ? ui.palette.primary : ui.palette.secondaryTextOnPlain
                    }
                    
                    onTouch: {
                        if(event.isUp()) {
                            if((data.metadatas && data.metadatas.length > 0 && index != undefined) || (top == data['id'] && index != undefined)) { // 二级 metas 管理
                                // 删除旧的插入节点
                                lv.deleteChildMetas(index, container.insertIndexInfo[index]);
                                // 如果是点击了全部，则不需再添加了，否则需要加入新的，并存入插入信息
                                var insertInfo = container.insertIndexInfo
                                if(top == data['id']) { // 点击了全部，这删除
                                    insertInfo[index] = 0;
                                }else {
                                    insertInfo[index] = data.metadatas.length;
                                    // 插入
                                    dm.insert(index + 1, data.metadatas);
                                }
                                container.insertIndexInfo = insertInfo;
                                // 更新高度
                                lv.updateHeight();
                            }
                            
                            var ai = container.activeInfo;
                            // 如果是选择了默认全部，则为空
                            if(top == data['id']) {
                                delete ai[top];
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
        var list = metadatas;
        list.push({
            displayName: "最火",
            id: 'calcDimension',
            metadataValues: [{
                displayName: "最近更新",
                id: 1
            },{
                displayName: "经典",
                id: 2
            }]
        });
        
        // 加上 index
        for(var i = 0; i < list.length; i++) {
            list[i]['__index'] = i;
        }
        
        dm.clear();
        dm.insert(0, list);
        
        // update ui
        lv.updateHeight();
        container.visible = setVisible;
    }
}