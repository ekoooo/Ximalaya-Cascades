import bb.cascades 1.4
import bb.device 1.4
import bb.multimedia 1.4
import tech.lwl 1.0
import "asset:///pages/child"

Page {
    id: apRoot
    objectName: "audioPlayer"
    
    // 播放器需要的基本信息
    property AudioPlayer audioPlayer
    property variant trackId // 当前播放声音ID，如果是直接打开播放器，请传入：-1
    property variant trackInfo: {} // 当前播放声音的信息
    property variant albumInfo // 当前页的专辑信息
    property variant listAlbumInfo // 当前列表显示的专辑信息
    
    // 用于 timeline 和 pause 状态
    property variant mediaState: MediaState.Stopped // 播放器状态
    property variant duration: 0 // 长度
    property variant position: 0 // 当前播放位置
    
    // 加载中标志
    property bool isLoading: true
    
    titleBar: TitleBar {
        title: (trackInfo['nickname'] || qsTr("演播")) + '：' + (trackInfo['title'] || qsTr("无"))
        scrollBehavior: TitleBarScrollBehavior.Sticky
    }

    actions: [
        ActionItem {
            title: qsTr("上一集")
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///images/bb10/ic_reply.png"
            onTriggered: {
                audioPlayer.previous();
            }
        },
        ActionItem {
            title: mediaState === MediaState.Started ? qsTr("暂停") : qsTr("播放")
            ActionBar.placement: ActionBarPlacement.Signature
            imageSource: mediaState === MediaState.Started ? "asset:///images/bb10/ic_pause.png" : "asset:///images/bb10/ic_play.png"
            onTriggered: {
                if(mediaState === MediaState.Started) {
                    audioPlayer.pause();
                }else {
                    audioPlayer.play();
                }
            }
        },
        ActionItem {
            title: qsTr("下一集")
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///images/bb10/ic_forward.png"
            onTriggered: {
                audioPlayer.next();
            }
        }
    ]

    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        Container {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            layout: StackLayout {
                
            }
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                ListView {
                    scrollRole: ScrollRole.Main
                    dataModel: ArrayDataModel {
                        id: dm
                    }
                    onTriggered: {
                        if(dm.data(indexPath)['__type']) {
                            return;
                        }
                        // 如果是播放的不是当前页的话，则需要更新专辑信息
                        if(listAlbumInfo['data']['pageId'] != albumInfo['data']['pageId']) {
                            audioPlayer.setAlbumInfo(listAlbumInfo);
                        }
                        // 付费声音处理
                        if(dm.data(indexPath)['isPaid']) {
                            _misc.showToast(qsTr("此集为付费声音 →.→"));
                        }else {
                            audioPlayer.go(dm.data(indexPath)['trackId']);
                        }
                    }
                    // 重写 itemType
                    function itemType(data, indexPath) {
                        return data.__type || "item";
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: "item"
                            CustomListItem {
                                dividerVisible: true
                                Container {
                                    topPadding: ui.du(2)
                                    bottomPadding: ui.du(2)
                                    leftPadding: ui.du(2)
                                    rightPadding: ui.du(2)
                                    verticalAlignment: VerticalAlignment.Center
                                    
                                    Container {
                                        layout: StackLayout {
                                            orientation: LayoutOrientation.LeftToRight
                                        }
                                        WebImageView {
                                            url: ListItemData['coverSmall']
                                            preferredWidth: ui.du(5)
                                            preferredHeight: ui.du(5)
                                            scalingMethod: ScalingMethod.AspectFill
                                            failImageSource: "asset:///images/audio_player/loading.png"
                                            loadingImageSource: "asset:///images/audio_player/loading.png"
                                        }
                                        Label {
                                            text: ListItemData['title']
                                            textStyle {
                                                color: ListItemData['isPaid'] ? ui.palette.secondaryTextOnPlain : ui.palette.textOnPlain
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    ]
                }
            }
            // 操作按钮
            Container {
                background: ui.palette.plain
                topPadding: ui.du(2)
                bottomPadding: ui.du(2)
                leftPadding: ui.du(2)
                rightPadding: ui.du(2)
                
                verticalAlignment: VerticalAlignment.Center
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Button {
                    text: qsTr("上一页")
                    horizontalAlignment: HorizontalAlignment.Fill
                    appearance: ControlAppearance.Primary
                    enabled: listAlbumInfo && listAlbumInfo['data']['pageId'] > 1
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    onClicked: {
                         _misc.showToast("上一页");
                    }
                }
                Button {
                    text: qsTr("下一页")
                    horizontalAlignment: HorizontalAlignment.Fill
                    appearance: ControlAppearance.Primary
                    enabled: listAlbumInfo && listAlbumInfo['data']['pageId'] < listAlbumInfo['data']['maxPageId']
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    onClicked: {
                        _misc.showToast("下一页");
                    }
                }
            }
            // 底部进度条
            ItemContainer {
                layout_: StackLayout {}
                background: ui.palette.plain
                verticalAlignment: VerticalAlignment.Bottom
                
                Slider {
                    fromValue: 0
                    toValue: duration
                    value: position
                    onTouch: {
                        if(event.isUp() || event.isCancel()) {
                            audioPlayer.seekTime(parseInt(immediateValue, 10));
                        }
                    }
                }
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    topPadding: ui.du(1)
                    leftPadding: ui.du(2)
                    rightPadding: ui.du(2)
                    Label {
                        text: formatTime(position)
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        textStyle {
                            base: SystemDefaults.TextStyles.SubtitleText
                            color: Color.Gray
                        }
                    }
                    Label {
                        text: formatTime(duration)
                        textStyle {
                            base: SystemDefaults.TextStyles.SubtitleText
                            color: Color.Gray
                        }
                    }
                }
            }
        }

        // loading
        Container {
            id: loadingContainer
            property bool isRun: isLoading
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            
            onIsRunChanged: {
                if(isRun) {
                    opacity = 1;
                    loadingContainer.visible = true;
                }else {
                    loadingHideAni.play();
                }
            }
            
            animations: [
                FadeTransition {
                    id: loadingHideAni
                    fromOpacity: 1
                    toOpacity: 0
                    duration: 200
                    onEnded: {
                        loadingContainer.visible = false;
                    }
                }
            ]
            
            WebImageView {
                url: "asset:///images/image_top_default.png"
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                scalingMethod: ScalingMethod.AspectFill
            }
            Container {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                ActivityIndicator {
                    running: true
                    preferredHeight: 100
                    preferredWidth: 100
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                }
                Label {
                    text: qsTr("正在加载中...")
                    verticalAlignment: VerticalAlignment.Center
                    textStyle {
                        color: Color.White
                    }
                }
            }
        }
    }
    
    onTrackIdChanged: {
        var currentPlayTrackId = _misc.getConfig(common.settingsKey.currentPlayTrackId, "");
        // 如果 trackId 发生变化则播放（保存操作在 go 中）
        if(currentPlayTrackId != trackId && trackId !== -1) {
            audioPlayer.setAlbumInfo(albumInfo);
            audioPlayer.go(trackId);
        }else {
            if(trackId === -1) { // 如果是直接打开播放器
                trackId = currentPlayTrackId;
                return;
            }
            if(!audioPlayer.albumInfo) { // 关闭设备，继续点击播放最后一个播放声音，此 albumInfo 会为空，所以要处理
                _misc.setConfig(common.settingsKey.currentPlayTrackId, "");
                trackId = currentPlayTrackId;
                return;
            }
            // 初始化信息
            albumInfo = audioPlayer.albumInfo;
            // 如果是暂停状态进来的，也继续播放
            audioPlayer.play();
            // 渲染界面
            render();
            renderList(albumInfo);
            
            isLoading = false;
        }
    }
    
    // ===================== connect start ===================== 
    function currentTrackChanged(trackId) {
        trackId = audioPlayer.trackId;
        render();
    }
    function positionChanged(p) {
        position = p;
    }
    function durationChanged(d) {
        duration = d;
    }
    function mediaStateChanged(ms) {
        if(ms === MediaState.Unprepared || ms === MediaState.Prepared) {
            isLoading = true;
        }else {
            isLoading = false;
        }
        
        mediaState = ms;
    }
    function albumInfoChanged() {
        albumInfo = audioPlayer.albumInfo;
        renderList(albumInfo)
    }
    function albumEnd(flag) {
        if(flag == 1) {
            _misc.showToast(qsTr("专辑播放完毕"));
        }else {
            _misc.showToast(qsTr("播放列表已无上一集"));
        }
        isLoading = false;
    }
    function track404() {
        _misc.showToast(qsTr("暂无播放"));
        isLoading = false;
    }
    function preNextTrack() {
        isLoading = true;
    }
    // ===================== connect end ===================== 
    function renderList(albumInfo) {
        listAlbumInfo = albumInfo; // 保存当前列表专辑信息
        
        dm.clear();
        dm.insert(0, albumInfo['data']['list']);
    }
    
    // 开始渲染
    function render() {
        trackInfo = audioPlayer.getCurrentTrackInfo();
        position = audioPlayer.position;
        duration = audioPlayer.duration;
        mediaState = audioPlayer.mediaState;
    }
    
    function formatTime(s) {
        var minutes = Math.floor(s/1000/60);
        var seconds = Math.floor(s/1000%60);
        return qsTr("%1:%2").arg(minutes < 10 ? "0" + minutes : "" + minutes).arg(seconds < 10 ? "0" + seconds : "" + seconds);
    }
}
