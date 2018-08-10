import bb.cascades 1.4
import tech.lwl 1.0
import "asset:///pages/child"
import "asset:///components"

Page {
    id: albumPage
    
    property variant albumId // 专辑ID
    property bool listLoading: false
    property bool detailLoading: false
    property bool isAsc
    // 当前页面的信息
    property variant currentAlbumInfo: {
        isInit: true,
        data: {
            totalCount: 0
        }
    }
    // 专辑信息里面的字段
    property variant album: {
        title: '-',
        nickname: '-',
        categoryName: '-',
        lastUptrackAt: +new Date('1970/01/01')
    }
    property variant user: {
        nickname: '-',
        followers: 0
    }
    
    actionBarVisibility: ChromeVisibility.Compact
    
    shortcuts: [
        Shortcut {
            key: common.shortCutKey.changeSegmented
            onTriggered: {
                segmentedControl.setSelectedIndex(listSm.selected ? 1 : 0);
            }
        }
    ]
    
    titleBar: TitleBar {
        id: segmentedControl
        scrollBehavior: TitleBarScrollBehavior.Sticky
        kind: TitleBarKind.Segmented
        options: [
            Option {
                id: listSm
                text: qsTr("声音(%1)").arg(currentAlbumInfo['data']['totalCount'])
                value: "list"
                selected: true
            },
            Option {
                id: detailSm
                text: qsTr("专辑信息")
                value: "detail"
            }
        ]
    }
    
    Container {
        layout: DockLayout {}
        // list
        Container {
            id: listContainer
            visible: listSm.selected
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            
            ListView {
                id: listLv
                property variant common_: common
                
                visible: listSm.selected
                scrollRole: listSm.selected ? ScrollRole.Main : ScrollRole.None
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                bottomPadding: ui.du(14)
                
                leadingVisual: Container {
                    leftPadding: ui.du(1)
                    rightPadding: ui.du(1)
                    topPadding: ui.du(1)
                    bottomPadding: ui.du(1)
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    DropDown {
                        id: isAscDropDown
                        property bool isInitChange: true
                        
                        title: qsTr("顺序")
                        options: [
                            Option {
                                text: qsTr("正序")
                                value: true
                            },
                            Option {
                                text: qsTr("倒序")
                                value: false
                            }
                        ]
                        onSelectedValueChanged: {
                            if(isAscDropDown.isInitChange) {
                                isAscDropDown.isInitChange = false;
                                return;
                            }
                            
                            // 存入缓存中，供播放器用（顺序在获取专辑信息前面）
                            _misc.setConfig(common.settingsKey.trackListIsAsc + albumId, selectedValue ? "1" : "0");
                            
                            getAlbumInfo(pageIdDropDown.selectedValue);
                        }
                    }
                    
                    DropDown {
                        id: pageIdDropDown
                        property variant ddCurrentAlbumInfo: currentAlbumInfo
                        property bool isInitChange: true
                        property bool isAddOptions: false
                        
                        title: qsTr("翻页")
                        enabled: true
                        onSelectedValueChanged: {
                            if(pageIdDropDown.isInitChange) {
                                pageIdDropDown.isInitChange = false;
                                return;
                            }
                            
                            getAlbumInfo(selectedValue);
                        }
                        onDdCurrentAlbumInfoChanged: {
                            if(!ddCurrentAlbumInfo.isInit && !isAddOptions) {
                                isAddOptions = true;
                                
                                var data = ddCurrentAlbumInfo['data'];
                                var maxPageId = data['maxPageId'];
                                var pageSize = data['pageSize'];
                                var pageId = data['pageId'];
                                var totalCount = data['totalCount'];
                                
                                var option;
                                
                                for(var i = 1; i <= maxPageId; i++) {
                                    option = dropDownOption.createObject();
                                    option.value = i;
                                    option.selected = i == pageId;
                                    option.text = qsTr("第") + i + qsTr("页");
                                    
                                    add(option);
                                }
                            }
                        }
                        
                        attachedObjects: [
                            ComponentDefinition {
                                id: dropDownOption
                                Option {}
                            }
                        ]
                    }
                }
                
                onTriggered: {
                    // 付费声音处理
                    if(common.isNotFree(listDm.data(indexPath))) {
                        _misc.showToast(qsTr("此集为付费声音，无法播放"));
                        return;
                    }
                    
                    tabbedPane.pushAudioPlayerUI(listDm.data(indexPath)['trackId'], currentAlbumInfo);
                }
                
                dataModel: ArrayDataModel {
                    id: listDm
                }
                listItemComponents: [
                    ListItemComponent {
                        type: ""
                        TrackItem {
                            listItemData: ListItemData
                            common: ListItem.view.common_
                        }
                    }
                ]
            }
        }
        // detail
        ScrollView {
            visible: detailSm.selected
            scrollRole: detailSm.selected ? ScrollRole.Main : ScrollRole.None
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container {
                bottomPadding: ui.du(14)
                
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                // album top
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    // cover image
                    Container {
                        layout: DockLayout {}
                        preferredWidth: ui.du(24)
                        preferredHeight: ui.du(24)
                        
                        WebImageView {
                            url: "asset:///images/album_cover_bg.png"
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            scalingMethod: ScalingMethod.AspectFill
                            implicitLayoutAnimationsEnabled: false
                        }
                        Container {
                            property variant pWidth: ui.du(2.6)
                            layout: DockLayout {}
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            leftPadding: pWidth
                            rightPadding: pWidth
                            topPadding: pWidth
                            bottomPadding: pWidth

                            WebImageView {
                                url: albumPage.album['coverLarge'] || "asset:///images/ting_default.png"
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                scalingMethod: ScalingMethod.AspectFill
                                implicitLayoutAnimationsEnabled: false
                            }
                        }
                    }
                    // info
                    Container {
                        id: infoContainer
                        property variant textMargin: ui.du(1.2)
                        
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        leftPadding: ui.du(1)
                        topPadding: ui.du(2.2)
                        
                        Container {
                            bottomMargin: infoContainer.textMargin
                            Label {
                                text: albumPage.album['title']
                            }
                        }
                        Container {
                            bottomMargin: infoContainer.textMargin
                            Label {
                                text: qsTr("主播：") + albumPage.album['nickname']
                                textStyle {
                                    base: SystemDefaults.TextStyles.SubtitleText
                                    color: ui.palette.primary
                                }
                            }
                        }
                        Container {
                            bottomMargin: infoContainer.textMargin
                            Label {
                                text: qsTr("分类：") + albumPage.album['categoryName']
                                textStyle {
                                    base: SystemDefaults.TextStyles.SubtitleText
                                    color: ui.palette.primary
                                }
                            }
                        }
                        Container {
                            Label {
                                text: qsTr("更新：") + common.formaTtimestamp(albumPage.album['lastUptrackAt'], 4)
                                textStyle {
                                    base: SystemDefaults.TextStyles.SubtitleText
                                    color: Color.Gray
                                }
                            }
                        }
                    }
                }
                Line {}
                // 简介
                Container {
                    leftPadding: ui.du(2)
                    rightPadding: ui.du(2)
                    bottomPadding: ui.du(2)
                    
                    Label {
                        text: qsTr("简介")
                        textStyle.fontWeight: FontWeight.Bold
                    }
                    Label {
                        text: '　　' + (albumPage.album['shortIntro'] || albumPage.album['intro'] || '无')
                        multiline: true
                        textStyle.color: ui.palette.textOnPlain
                        textStyle.lineHeight: 1.1
                    }
                }
                Line {}
                // 主播介绍
                Container {
                    leftPadding: ui.du(2)
                    rightPadding: ui.du(2)
                    bottomPadding: ui.du(2)
                    
                    Label {
                        text: qsTr("主播介绍")
                        textStyle.fontWeight: FontWeight.Bold
                    }
                    // info
                    Container {
                        topPadding: ui.du(2)
                        bottomPadding: ui.du(2)
                        preferredHeight: ui.du(16) // 12 + 2 + 2
                        
                        onTouch: {
                            if(event.isUp()) {
                                _misc.showToast("进入主播界面，功能正在开发中...");
                            }
                        }
                        
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        Container {
                            layout: DockLayout {}
                            preferredWidth: ui.du(12)
                            preferredHeight: ui.du(12)
                            WebImageView {
                                url: albumPage.user['smallLogo'] || "asset:///images/avatars_icon.png"
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                scalingMethod: ScalingMethod.AspectFill
                            }
                        }
                        Container {
                            leftPadding: ui.du(2)
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                            verticalAlignment: VerticalAlignment.Fill
                            
                            Container {
                                layout: StackLayout {
                                    orientation: LayoutOrientation.LeftToRight
                                }
                                Container {
                                    Label {
                                        text: albumPage.user['nickname']
                                    }
                                }
                                WebImageView {
                                    url: getUrl()
                                    preferredHeight: ui.du(2.5)
                                    scalingMethod: ScalingMethod.AspectFit
                                    verticalAlignment: VerticalAlignment.Center
                                    
                                    function getUrl() {
                                        if(albumPage.user['anchorGrade'] > 0 && albumPage.user['anchorGrade'] <= 17) {
                                            return "asset:///images/user_grade/individual_orangeV" + albumPage.user['anchorGrade'] + ".png";
                                        }else {
                                            return "";
                                        }
                                    }
                                }
                            }
                            Container {
                                layout: DockLayout {}
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                                Label {
                                    text: qsTr("粉丝") + albumPage.user['followers']
                                    textStyle {
                                        base: SystemDefaults.TextStyles.SmallText
                                        color: Color.Gray
                                    }
                                    verticalAlignment: VerticalAlignment.Center
                                }
                            }
                            Container {
                                Label {
                                    text: qsTr("点击进入")
                                    textStyle {
                                        base: SystemDefaults.TextStyles.SmallText
                                        color: ui.palette.primary
                                    }
                                }
                            }
                        }
                    }
                    // desc
                    Label {
                        text: albumPage.user['personalSignature']
                        multiline: true
                        textStyle.lineHeight: 1.1
                    }
                }
                Line {
                    visible: !!albumPage.album['tags']
                }
                Container {
                    visible: !!albumPage.album['tags']
                    leftPadding: ui.du(2)
                    rightPadding: ui.du(2)
                    bottomPadding: ui.du(2)
                    
                    Label {
                        text: qsTr("专辑标签")
                        textStyle.fontWeight: FontWeight.Bold
                    }
                    
                    Label {
                        text: albumPage.album['tags'] ? albumPage.album['tags'].split(',').join('、') : qsTr("无")
                        multiline: true
                        textStyle.lineHeight: 1.1
                        textStyle.color: ui.palette.primary
                    }
                }
            }
        }
        
        Container {
            visible: listLoading || detailLoading
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.create(0,0,0,0.2)
            layout: DockLayout {}
            
            ActivityIndicator {
                running: listLoading || detailLoading
                preferredHeight: ui.du(10)
                preferredWidth: ui.du(10)
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
            }
        }
    }
    
    attachedObjects: [
        Requester {
            id: albumDetailRequester
            onBeforeSend: {
                detailLoading = true;
            }
            onFinished: {
                detailLoading = false;
                
                try {
                    var detail = JSON.parse(data);
                    
                    if(detail['ret'] === 0 && detail['data']['album'] && detail['data']['user']) {
                        albumPage.album = detail['data']['album'];
                        albumPage.user = detail['data']['user'];
                    }else {
                        _misc.showToast(qsTr("专辑信息接口调用失败"));
                    }
                }catch(e) {
                    _misc.showToast(qsTr("专辑信息获取失败"));
                }
            }
            onError: {
                detailLoading = false;
                _misc.showToast(error);
            }
        },
        Requester {
            id: albumListRequester
            onBeforeSend: {
                listLoading = true;
            }
            onFinished: {
                listLoading = false;
                
                var rs = JSON.parse(data);
                
                if(!rs['data'] || !rs.data['list']) {
                    _misc.showToast(qsTr("声音列表加载失败"));
                    return;
                }
                
                listDm.clear();
                listDm.insert(0, rs.data.list);
                
                albumPage.currentAlbumInfo = rs;
            }
            onError: {
                listLoading = false;
                _misc.showToast(error);
            }
        },
        QTimer {
            id: initTimer
            interval: 300
            onTimeout: {
                initTimer.stop();
                
                albumPage.getAlbumInfo(1);
                albumPage.getAlbumDetail();
            }
        }
    ]
    
    onAlbumIdChanged: {
        isAsc = _misc.getConfig(common.settingsKey.trackListIsAsc + albumId, "1") === "1";
        isAscDropDown.setSelectedIndex(isAsc ? 0 : 1);
        
        initTimer.start();
    }
    
    // 获取声音信息
    function getAlbumInfo(pageId) {
        common.apiAlbumInfo(albumListRequester, albumId, pageId);
    }
    // 获取专辑信息
    function getAlbumDetail() {
        common.apiAlbumDetail(albumDetailRequester, albumId);
    }
}
