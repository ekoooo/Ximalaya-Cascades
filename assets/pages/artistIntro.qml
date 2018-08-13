import bb.cascades 1.4
import tech.lwl 1.0
import "asset:///components"
import "asset:///pages/child"

// 主播信息
Page {
    id: artistIntroPage
    property variant uid
    property bool loading: true
    property bool albumsLoading: true
    // 当前主播信息
    property variant introInfo: {
        nickname: qsTr("昵称"),
        followings: 0,
        followers: 0,
        ptitle: qsTr("无")
    }
    // 主播专辑
    property variant artistInfo: {
        isInit: true,
        list: [],
        totalCount: 0
    }
    
    actionBarVisibility: ChromeVisibility.Compact
    
    Container {
        layout: DockLayout {}
        
        WebImageView {
            url: introInfo['backgroundLogo'] || "asset:///images/no_content.png"
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            scalingMethod: ScalingMethod.AspectFill
            implicitLayoutAnimationsEnabled: false
        }
        
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ScrollView {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                scrollRole: ScrollRole.Main
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    // 头像 Container
                    Container {
                        id: logoContainer
                        property variant logoWidth: ui.du(16)
                        
                        horizontalAlignment: HorizontalAlignment.Fill
                        preferredHeight: logoContainer.logoWidth * 1.5
                        layout: DockLayout {}
                        
                        WebImageView {
                            preferredHeight: logoContainer.logoWidth / 2
                            url: "asset:///images/radius.amd"
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Bottom
                        }
                        
                        // 头像
                        Container {
                            layout: DockLayout {}
                            preferredWidth: logoContainer.logoWidth
                            preferredHeight: logoContainer.logoWidth
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Bottom
                            
                            WebImageView {
                                url: introInfo['mobileLargeLogo'] || ''
                                failImageSource: "asset:///images/avatars_icon.png"
                                loadingImageSource: "asset:///images/avatars_icon.png"
                                scalingMethod: ScalingMethod.AspectFill
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                            }
                        }
                    }
                    // content Container
                    Container {
                        background: Color.White
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        // base info
                        Container {
                            topPadding: ui.du(2)
                            bottomPadding: ui.du(2)
                            leftPadding: ui.du(2)
                            rightPadding: ui.du(2)
                            horizontalAlignment: HorizontalAlignment.Fill
                            // 昵称
                            Container {
                                horizontalAlignment: HorizontalAlignment.Center
                                layout: StackLayout {
                                    orientation: LayoutOrientation.LeftToRight
                                }
                                Label {
                                    text: introInfo['nickname']
                                    textStyle {
                                        base: SystemDefaults.TextStyles.BodyText
                                        fontWeight: FontWeight.Bold
                                    }
                                }
                                WebImageView {
                                    url: getUrl()
                                    preferredHeight: ui.du(3)
                                    scalingMethod: ScalingMethod.AspectFit
                                    verticalAlignment: VerticalAlignment.Center
                                    
                                    function getUrl() {
                                        if(introInfo['anchorGrade'] > 0 && introInfo['anchorGrade'] <= 17) {
                                            return "asset:///images/user_grade/individual_orangeV" + introInfo['anchorGrade'] + ".png";
                                        }else {
                                            return "";
                                        }
                                    }
                                }
                            }
                            // 关注和粉丝
                            Container {
                                horizontalAlignment: HorizontalAlignment.Center
                                topMargin: ui.du(1)
                                bottomMargin: ui.du(1)
                                layout: StackLayout {
                                    orientation: LayoutOrientation.LeftToRight
                                }
                                Label {
                                    text: qsTr("关注：") + introInfo['followings']
                                }
                                Label {
                                    text:  qsTr("粉丝：") + introInfo['followers']
                                }
                            }
                            // 认证
                            Container {
                                visible: !!introInfo['verifyType']
                                horizontalAlignment: HorizontalAlignment.Center
                                Label {
                                    text: getVerifyTypeStr() + (introInfo['ptitle'] || qsTr("个人认证"))
                                    textStyle.color: Color.Gray
                                    
                                    function getVerifyTypeStr() {
                                        var type = introInfo['verifyType'];
                                        
                                        if(type === 2) {
                                            return qsTr("机构认证：");
                                        }else {
                                            return qsTr("认证：");
                                        }
                                    }
                                }
                            }
                        }
                        Line{}
                        // desc info
                        Container {
                            bottomPadding: ui.du(2)
                            leftPadding: ui.du(2)
                            rightPadding: ui.du(2)
                            Label {
                                text: qsTr("TA 的信息")
                                textStyle.fontWeight: FontWeight.Bold
                            }
                            Container {
                                visible: !!introInfo['gender']
                                Label {
                                    text: qsTr("性别：") + getGenderStr()
                                    textStyle.color: Color.Gray
                                    
                                    function getGenderStr() {
                                        if(introInfo['gender'] == 1) {
                                            return qsTr("男");
                                        }else {
                                            return qsTr("女");
                                        }
                                    }
                                }
                            }
                            Container {
                                visible: !!introInfo['personalSignature']
                                Label {
                                    text: qsTr("简介：") + introInfo['personalSignature']
                                    textStyle.color: Color.Gray
                                    multiline: true
                                }
                            }
                            Container {
                                visible: !!introInfo['userInterestTags']
                                Label {
                                    text: qsTr("兴趣：") + (introInfo['userInterestTags'] || []).join('、')
                                    textStyle.color: Color.Gray
                                    multiline: true
                                }
                            }
                        }
                        Line{}
                        // 他的专辑
                        Container {
                            visible: !!artistIntroPage.artistInfo['totalCount']
                            bottomPadding: ui.du(2)
                            
                            Container {
                                leftPadding: ui.du(2)
                                rightPadding: ui.du(2)
                                bottomPadding: ui.du(2)
                                layout: StackLayout {
                                    orientation: LayoutOrientation.LeftToRight
                                }
                                Label {
                                    text: qsTr("TA 的专辑(%1)").arg(artistIntroPage.artistInfo['totalCount'])
                                    textStyle.fontWeight: FontWeight.Bold
                                    layoutProperties: StackLayoutProperties {
                                        spaceQuota: 1
                                    }
                                }
                                Label {
                                    text: qsTr("查看更多 ➤")
                                    textStyle.textAlign: TextAlign.Right
                                    textStyle.color: Color.Gray
                                    onTouch: {
                                        if(event.isUp()) {
                                            goArtistAlbumListPage();
                                        }
                                    }
                                }
                            }
                            Container {
                                preferredHeight: ui.du((16 + 1) * artistIntroPage.artistInfo['list'].length)
                                ListView {
                                    property variant common_: common
                                    property variant listInfo: artistIntroPage.artistInfo
                                    scrollIndicatorMode: ScrollIndicatorMode.None
                                    dataModel: ArrayDataModel {
                                        id: albumDm
                                    }
                                    
                                    onTriggered: {
                                        goAlbumPage(albumDm.data(indexPath)['albumId']);
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
                                    
                                    onListInfoChanged: {
                                        if(!listInfo.isInit) {
                                            albumDm.clear();
                                            albumDm.insert(0, listInfo['list']);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        Container {
            visible: artistIntroPage.loading || artistIntroPage.albumsLoading
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.create(0,0,0,0.2)
            
            ActivityIndicator {
                running: artistIntroPage.loading
                preferredWidth: ui.du(10)
                preferredHeight: ui.du(10)
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
            }
        }
    }
    
    attachedObjects: [
        Requester {
            id: infoRequester
            onBeforeSend: {
                artistIntroPage.loading = true;
            }
            onFinished: {
                artistIntroPage.loading = false;
                try {
                    var rt = JSON.parse(data);
                    if(rt.ret === 0) {
                        artistIntroPage.introInfo = rt;
                    }else {
                        _misc.showToast(qsTr("主播信息异常，请重试"));
                    }
                }catch (e) {
                    _misc.showToast(qsTr("主播信息获取失败，请重试"));
                }
            }
            onError: {
                artistIntroPage.loading = false;
                _misc.showToast(error);
            }
        },
        Requester {
            id: albumsRequester
            onBeforeSend: {
                artistIntroPage.albumsLoading = true;
            }
            onFinished: {
                artistIntroPage.albumsLoading = false;
                try {
                    var rt = JSON.parse(data);
                    if(rt.ret === 0) {
                        artistIntroPage.artistInfo = rt;
                    }else {
                        _misc.showToast(qsTr("主播专辑异常，请重试"));
                    }
                }catch (e) {
                    _misc.showToast(qsTr("主播专辑获取失败，请重试"));
                }
            }
            onError: {
                artistIntroPage.albumsLoading = false;
                _misc.showToast(error);
            }
        },
        QTimer {
            id: initTimer
            interval: 300
            onTimeout: {
                initTimer.stop();
                
                common.apiArtishIntro(infoRequester, uid);
                // 默认显示5条专辑信息
                common.apiArtistAlbums(albumsRequester, uid, 1, 5);
            }
        },
        ComponentDefinition {
            id: albumPage
            source: "asset:///pages/album.qml"
        },
        ComponentDefinition {
            id: artistAlbumListPage
            source: "asset:///pages/artistAlbumList.qml"
        }
    ]
    
    onUidChanged: {
        initTimer.start();
    }
    
    function goAlbumPage(albumId) {
        var page = albumPage.createObject();
        page.albumId = albumId;
        page.from = 'artistIntroPage';
        nav.push(page);
    }
    
    function goArtistAlbumListPage() {
        var page = artistAlbumListPage.createObject();
        page.uid = uid;
        nav.push(page);
    }
}
