import bb.cascades 1.4
import tech.lwl 1.0
import "asset:///pages/child"

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
            textField.onTouch: {
                if(event.isUp()) {
                    if(!textField.focused) { // 如果没有这个，用按钮滚动列表后会导致无法聚焦输入框
                        textField.requestFocus();
                    }
                }
            }
            textField.input.onSubmitted: {
                searchPage.search(textField.text, 'all');
            }
            textField.text: "歌曲"
            onCreationCompleted: {
                searchPage.search(textField.text, 'all');
            }
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
                        id: c1Sc
                        text: qsTr("专辑") + ' - ' + searchParams['album']['numFound']
                        value: "c1"
                    },
                    Option {
                        id: c2Sc
                        text: qsTr("主播") + ' - ' + searchParams['user']['numFound']
                        value: "c2"
                    }
                ]
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
                visible: c1Sc.selected
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                layout: DockLayout {}
                WebImageView {
                    visible: searchParams.album.numFound === 0 && !searchParams.album.isLoading
                    url: "asset:///images/no_content.png"
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    scalingMethod: ScalingMethod.AspectFill
                }
                ListView {
                    id: albumLv
                    property variant common_: common
                    visible: c1Sc.selected
                    
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
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
                            AlbumItem {
                                listItemData: ListItemData
                                common: ListItem.view.common_
                            }
                        }
                    ]
                    attachedObjects: [
                        ListScrollStateHandler {
                            onAtEndChanged: {
                                if(atEnd && !albumDm.isEmpty() && !searchParams.album.isLoading && searchParams.album.page < searchParams.album.totalPage) {
                                    searchPage.search(searchParams.album.kw, 'album');
                                }
                            }
                        }
                    ]
                    
                    onTriggered: {
                        goAlbumPage(albumDm.data(indexPath)['id']);
                    }
                }
                Container {
                    visible: searchParams.album.isLoading
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    layout: DockLayout {}
                    background: Color.create(0,0,0,0.2)
                    
                    ActivityIndicator {
                        visible: true
                        running: searchParams.album.isLoading
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        preferredWidth: ui.du(10)
                        preferredHeight: ui.du(10)
                    }
                }
            }
            
            // 声音 Container
            Container {
                id: c2
                visible: c2Sc.selected
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                layout: DockLayout {}
                
                WebImageView {
                    visible: searchParams.user.numFound === 0 && !searchParams.user.isLoading
                    url: "asset:///images/no_content.png"
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    scalingMethod: ScalingMethod.AspectFill
                }
                
                ListView {
                    id: userLv
                    
                    visible: c2Sc.selected
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    bottomPadding: ui.du(14)
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    
                    dataModel: ArrayDataModel {
                        id: userDm
                    }
                    
                    listItemComponents: [
                        ListItemComponent {
                            type: ""
                            UserItem {
                                listItemData: ListItemData
                            }
                        }
                    ]
                    attachedObjects: [
                        ListScrollStateHandler {
                            onAtEndChanged: {
                                if(atEnd && !userDm.isEmpty() && !searchParams.user.isLoading && searchParams.user.page < searchParams.user.totalPage) {
                                    searchPage.search(searchParams.album.kw, 'user');
                                }
                            }
                        }
                    ]
                }
                
                Container {
                    visible: searchParams.user.isLoading
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    layout: DockLayout {}
                    background: Color.create(0,0,0,0.2)
                    
                    ActivityIndicator {
                        visible: true
                        running: searchParams.user.isLoading
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        preferredWidth: ui.du(10)
                        preferredHeight: ui.du(10)
                    }
                }
            }
        }
    }
    
    
    attachedObjects: [
        Requester {
            id: albumRequester
            onBeforeSend: {
                updateSearchParams('album', { isLoading: true });
            }
            onFinished: {
                try {
                    searchPage.setListInfo('album', JSON.parse(data));
                }catch(e) {
                    resetError(qsTr("搜索专辑系统繁忙，请重试"), 'album');
                }
            }
            onError: {
                resetError(error, 'album');
            }
        },
        Requester {
            id: userRequester
            onBeforeSend: {
                updateSearchParams('user', { isLoading: true });
            }
            onFinished: {
                try {
                    searchPage.setListInfo('user', JSON.parse(data));
                }catch(e) {
                    resetError(qsTr("搜索主播系统繁忙，请重试"), 'user');
                }
            }
            onError: {
                resetError(error, 'user');
            }
        },
        ComponentDefinition {
            id: albumPage
            source: "asset:///pages/album.qml"
        }
    ]
    
    function goAlbumPage(albumId) {
        var page = albumPage.createObject();
        page.albumId = albumId;
        nav.push(page);
    }
    
    // 请求错误处理
    function resetError(error, type) {
        updateSearchParams(type, { isLoading: false });
        _misc.showToast(error);
        // 处理 page
        resetPage(type);
    }
    
    /**
     * 搜索
     * kw 关键字
     * isSearch 如果是搜索动作则搜索两个
     * type 类型 album、user、all
     */
    function search(kw, type) {
        if(!kw || kw.trim() === '') {
            _misc.showToast("请输入关键字进行搜索");
            return;
        }
        
        if(type === 'all') {
            // 初始化
            searchParams = { // 搜索结束后保存
                album: {
                    isLoading: false,
                    page: 1,
                    totalPage: 0,
                    numFound: 0,
                    kw: kw
                },
                user: {
                    isLoading: false,
                    page: 1,
                    totalPage: 0,
                    numFound: 0,
                    kw: kw
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
                common.apiSearch(albumRequester, type, kw, searchParams[type]['page']);
            }else if(type === 'user') {
                common.apiSearch(userRequester, type, kw, searchParams[type]['page']);
            }
        }
    }
    
    function setListInfo(type, data) {
        var response = data['response'];
        
        // 验证
        if(!response) {
            if(data['reason'] && data['reason'] === 'UnableSearch') {
                _misc.showToast(qsTr("很抱歉，根据相关法律和政策，相关搜索结果未给与显示"));
            }else {
                _misc.showToast(qsTr("此关键字无法搜索"));
            }
            
            updateSearchParams(type, {
                isLoading: false
            });
            
            resetPage(type);
            
            return;
        }
        
        var dm;
        if(type === 'album') {
            dm = albumDm;
        }else if(type === 'user') {
            dm = userDm;
        }
        
        if(searchParams[type]['page'] === 1) {
            dm.clear();
            var docs = response['docs'];
            // 如果是搜索专辑，然后有 top 专辑，则放在最前面
            if(type === 'album') {
                if(data.top && data.top.type === 'album') {
                    docs.unshift(data.top.doc);
                }
            }
            dm.insert(0, docs);
        }else {
            dm.append(response['docs'])
        }
        
        updateSearchParams(type, {
            isLoading: false,
            totalPage: response.totalPage,
            numFound: response.showNumFound
        });
    }
    
    function resetPage(type) {
        var page = searchParams[type]['page'];
        if(page > 1) {
            updateSearchParams(type, { page: page - 1 });
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
