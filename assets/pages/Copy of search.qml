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
        }
    }
    
    Container {
        ListView {
            id: lv
            property variant layoutFrame
            property variant searchParams_: searchPage.searchParams
            
            horizontalAlignment: HorizontalAlignment.Fill
            layout: StackListLayout {
                orientation: LayoutOrientation.LeftToRight
                headerMode: ListHeaderMode.None
            }
            flickMode: FlickMode.SingleItem
            snapMode: SnapMode.LeadingEdge
            scrollIndicatorMode: ScrollIndicatorMode.None
            dataModel: ArrayDataModel {
                id: dm
            }
            
            function itemType(data, indexPath) {
                return data;
            }
            
            listItemComponents: [
                // 专辑
                ListItemComponent {
                    type: "0"
                    Container {
                        id: albumContainer
                        property variant searchParams_: ListItem.view.searchParams_
                        preferredWidth: ListItem.view.layoutFrame.width
                        
                        Header {
                            title: qsTr("专辑")
                            subtitle: qsTr("共") + albumContainer.searchParams_['album']['numFound'] + qsTr("个搜索结果")
                        }
                        
                        ListView {
                            id: albumLv
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
                                        Label {
                                            id: xxxx
                                            text: "test"
                                        }
                                    }
                                }
                            ]
                        }
                    }
                },
                // 主播
                ListItemComponent {
                    type: "1"
                    Container {
                        preferredWidth: ListItem.view.layoutFrame.width
                        preferredHeight: ListItem.view.height
                        ListView {
                            id: anchorLv
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                            dataModel: ArrayDataModel {
                                id: anchorDm
                            }
                        }
                    }
                }
            ]
            
            onCreationCompleted: {
                dm.clear();
                dm.insert(0, ["0", "1"])
            }
            
            attachedObjects: [
                LayoutUpdateHandler {
                    onLayoutFrameChanged: {
                        lv.layoutFrame = layoutFrame
                    }
                }
            ]
        }
    }
    
    attachedObjects: [
        Requester {
            id: albumRequester
            onBeforeSend: {
                searchParams.album.isLoading = true;
            }
            onFinished: {
                searchParams.album.isLoading = false;
                searchPage.setListInfo('album', JSON.parse(data));
            }
            onError: {
                _misc.showToast(error);
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

            common.apiSearch(albumRequester, 'album', kw, 1);
            common.apiSearch(userRequester, 'user', kw, 1);
        }else {
            updateSearchParams(type, { kw: kw });
            
            if(type === 'album') {
                common.apiSearch(albumRequester, type, kw, searchParams[type]['page'] + 1);
            }else if(type === 'user') {
                common.apiSearch(userRequester, type, kw, searchParams[type]['page'] + 1);
            }
        }
    }
    
    function setListInfo(type, data) {
        var response = data['response'];

        updateSearchParams(type, {
            isLoading: false,
            totalPage: response.totalPage,
            numFound: response.numFound
        });
        
        
        if(type === 'album') {
            
        }else if(type === 'user') {
            
        }
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
