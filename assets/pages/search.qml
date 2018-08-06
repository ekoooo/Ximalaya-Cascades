import bb.cascades 1.4
import tech.lwl 1.0

Page {
    id: searchPage
    actionBarVisibility: ChromeVisibility.Compact
    
    property variant searchParams: { // 搜索结束后保存
        album: {
            isLoading: false,
            page: 0,
            totalPage: 0,
            numFound: 0,
            kw: undefined
        },
        user: {
            isLoading: false,
            page: 0,
            totalPage: 0,
            numFound: 0,
            kw: undefined
        }
    }
    
    titleBar: TitleBar {
        kind: TitleBarKind.TextField
        kindProperties: TextFieldTitleBarKindProperties {
            textField.hintText: qsTr("搜索专辑、主播")
            textField.inputMode: TextFieldInputMode.Text
            textField.input.keyLayout: KeyLayout.Text
            textField.input.submitKey: SubmitKey.Search
            textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            textField.input.onSubmitted: {
                searchPage.search(textField.text, 'all');
            }
            textField.text: "灵异"
        }
    }
    
    Container {
        // SegmentedControl Container
        Container {
            topPadding: ui.du(1)
            bottomPadding: ui.du(1)
            background: ui.palette.plain
            
            horizontalAlignment: HorizontalAlignment.Fill
            SegmentedControl {
                options: [
                    Option {
                        text: qsTr("专辑") + ' - ' + searchParams['album']['numFound']
                        value: "c1"
                    },
                    Option {
                        text: qsTr("主播") + ' - ' + searchParams['user']['numFound']
                        value: "c2"
                    }
                ]
                onSelectedValueChanged: {
                    if(selectedValue === 'c1') {
                        c1.visible = true;
                        c2.visible = false;
                    }else if(selectedValue === 'c2') {
                        c2.visible = true;
                        c1.visible = false;
                    }
                }
            }
        }
        // listContainer Container
        Container {
            id: listContainer
            horizontalAlignment: HorizontalAlignment.Fill
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
            layout: DockLayout {
                
            }
            
            // 专辑 Container
            Container {
                id: c1
                visible: true
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                ListView {
                    id: albumLv
                    bottomPadding: ui.du(14)
                    
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    dataModel: ArrayDataModel {
                        id: albumDm
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: ""
                            CustomListItem {
                                Container {
                                    leftPadding: ui.du(2)
                                    rightPadding: ui.du(2)
                                    topPadding: ui.du(2)
                                    bottomPadding: ui.du(2)
                                    
                                    layout: StackLayout {
                                        orientation: LayoutOrientation.LeftToRight
                                    }
                                    // Cover Container
                                    Container {
                                        id: coverContainer
                                        preferredWidth: ui.du(12)
                                        preferredHeight: ui.du(12)
                                        layout: DockLayout {
                                            
                                        }
                                        
                                        WebImageView {
                                            url: ListItemData['cover_path']
                                            failImageSource: "asset:///images/ting_default.png"
                                            loadingImageSource: "asset:///images/ting_default.png"
                                            scalingMethod: ScalingMethod.AspectFill
                                            horizontalAlignment: HorizontalAlignment.Fill
                                            verticalAlignment: VerticalAlignment.Fill
                                        }
                                        
                                        WebImageView {
                                            visible: ListItemData['is_paid']
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
                                            Label {
                                                text: ListItemData['title']
                                                textFit.mode: LabelTextFitMode.FitToBounds
                                            }
                                        }
                                        Container {
                                            Label {
                                                text: ListItemData['intro']
                                                textStyle {
                                                    base: SystemDefaults.TextStyles.SubtitleText
                                                    color: Color.Gray
                                                }
                                            }
                                            topPadding: 8
                                            bottomPadding: 8
                                        }
                                        Container {
                                            layout: StackLayout {
                                                orientation: LayoutOrientation.LeftToRight
                                            }
                                            Label {
                                                text: qsTr("播放：") + ListItemData['play']
                                                textStyle {
                                                    base: SystemDefaults.TextStyles.SmallText
                                                    color: Color.Gray
                                                }
                                            }
                                            Label {
                                                text: qsTr("集数：") +ListItemData['tracks']
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
                    ]
                }
            }
            
            // 声音 Container
            Container {
                id: c2
                visible: false
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                ListView {
                    id: anchorLv
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    dataModel: ArrayDataModel {
                        id: userDm
                    }
                }
            }
        }
    }
    
    
    attachedObjects: [
        Requester {
            id: albumRequester
            onBeforeSend: {
                searchParams.album.isLoading = true;
            }
            onFinished: {
                searchPage.setListInfo('album', JSON.parse(data));
            }
            onError: {
                searchParams.album.isLoading = false;
                _misc.showToast(error);
                // 处理 page
                var page = searchParams['album']['page'];
                if(page > 1) {
                    updateSearchParams('album', { page: page - 1 });
                }
            }
        },
        Requester {
            id: userRequester
            onBeforeSend: {
                searchParams.user.isLoading = true;
            }
            onFinished: {
                searchPage.setListInfo('user', JSON.parse(data));
            }
            onError: {
                searchParams.user.isLoading = false;
                _misc.showToast(error);
                // 处理 page
                var page = searchParams['user']['page'];
                if(page > 1) {
                    updateSearchParams('user', { page: page - 1 });
                }
            }
        }
    ]
    
    /**
     * 搜索
     * kw 关键字
     * isSearch 如果是搜索动作则搜索两个
     * type 类型 album、user、all
     */
    function search(kw, type) {
        if(type === 'all') {
            // 初始化
            searchParams = { // 搜索结束后保存
                album: {
                    isLoading: false,
                    page: 1,
                    totalPage: 0,
                    numFound: 0,
                    kw: undefined
                },
                user: {
                    isLoading: false,
                    page: 1,
                    totalPage: 0,
                    numFound: 0,
                    kw: undefined
                }
            }

            common.apiSearch(albumRequester, 'album', kw, 1);
            common.apiSearch(userRequester, 'user', kw, 1);
        }else { // 加载下一页
            updateSearchParams(type, {
                kw: kw,
                page: searchParams[type]['page'] + 1 // 如果加载失败？在 Requester 处理
            });
            
            if(type === 'album') {
                common.apiSearch(albumRequester, type, kw, searchParams[type]['page'] + 1);
            }else if(type === 'user') {
                common.apiSearch(userRequester, type, kw, searchParams[type]['page'] + 1);
            }
        }
    }
    
    function setListInfo(type, data) {
        var response = data['response'];
        
        var dm;
        
        if(type === 'album') {
            dm = albumDm;
        }else if(type === 'user') {
            dm = userDm;
        }
        
        if(searchParams[type]['page'] === 1) {
            dm.clear();
            dm.insert(0, response['docs']);
        }else {
            dm.append(response['docs'])
        }
        
        updateSearchParams(type, {
            isLoading: false,
            totalPage: response.totalPage,
            numFound: response.numFound
        });
    }
    
    function updateSearchParams(type, info) {
        if(type === 'user') {
            var tempInfo = searchParams.user;
            
            searchParams = {
                album: searchParams.album,
                user: {
                    isLoading: info.isLoading == undefined ? tempInfo.isLoading : info.isLoading,
                    totalPage: info.totalPage == undefined ? tempInfo.totalPage : info.totalPage,
                    numFound: info.numFound == undefined ? tempInfo.numFound : info.numFound,
                    page: info.page == undefined ? tempInfo.page : info.page,
                    kw: info.kw == undefined ? tempInfo.kw : info.kw
                }
            }
        }else if(type === 'album') {
            var tempInfo = searchParams.album;
            
            searchParams = {
                user: searchParams.user,
                album: {
                    isLoading: info.isLoading == undefined ? tempInfo.isLoading : info.isLoading,
                    totalPage: info.totalPage == undefined ? tempInfo.totalPage : info.totalPage,
                    numFound: info.numFound == undefined ? tempInfo.numFound : info.numFound,
                    page: info.page == undefined ? tempInfo.page : info.page,
                    kw: info.kw == undefined ? tempInfo.kw : info.kw
                }
            }
        }
    }
}
