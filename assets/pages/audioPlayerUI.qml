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
    
    property bool opVisible: _misc.getConfig(common.settingsKey.audioPlayerOpVisible, "1") === "1"

    titleBar: TitleBar {
        scrollBehavior: TitleBarScrollBehavior.Sticky
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties {
            Container {
                leftPadding: ui.du(2)
                rightPadding: ui.du(2)
                topPadding: ui.du(2)
                bottomPadding: ui.du(2)
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                WebImageView {
                    url: trackInfo['smallLogo'] || ''
                    scalingMethod: ScalingMethod.AspectFit
                    verticalAlignment: VerticalAlignment.Center
                    failImageSource: "asset:///images/audio_player/loading.png"
                    loadingImageSource: "asset:///images/audio_player/loading.png"
                    implicitLayoutAnimationsEnabled: false
                }
                Container {
                    verticalAlignment: VerticalAlignment.Center
                    leftPadding: ui.du(2)
                    Container {
                        Label {
                            text: qsTr("演播：") + (trackInfo['nickname'] || '无')
                            textStyle {
                                base: SystemDefaults.TextStyles.SubtitleText
                            }
                        }
                    }
                    Container {
                        Label {
                            text: qsTr("正在播放：") + (trackInfo['title'] || '无')
                            textStyle {
                                base: SystemDefaults.TextStyles.SubtitleText
                            }
                        }
                    }
                }
            }
        }
    }

    actions: [
        ActionItem {
            title: qsTr("上一集")
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///images/bb10/ic_reply.png"
            onTriggered: {
                audioPlayer.previous();
            }
            enabled: !isLoading
            shortcuts: [
                Shortcut {
                    key: "s"
                }
            ]
        },
        ActionItem {
            title: mediaState === MediaState.Started ? qsTr("暂停") : qsTr("播放")
            ActionBar.placement: ActionBarPlacement.Signature
            imageSource: mediaState === MediaState.Started ? "asset:///images/bb10/ic_pause.png" : "asset:///images/bb10/ic_play.png"
            onTriggered: {
                if(audioPlayer.mediaState === MediaState.Unprepared) {
                    return;
                }

                if(mediaState === MediaState.Started) {
                    audioPlayer.pause();
                }else {
                    audioPlayer.play();
                }
            }
            enabled: !isLoading
            shortcuts: [
                Shortcut {
                    key: "space"
                }
            ]
        },
        ActionItem {
            title: qsTr("下一集")
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///images/bb10/ic_forward.png"
            onTriggered: {
                audioPlayer.next();
            }
            enabled: ! isLoading
            shortcuts: [
                Shortcut {
                    key: "x"
                }
            ]
        },
        ActionItem {
            title: opVisible ? qsTr("关闭操作面板") : qsTr("打开操作面板")
            ActionBar.placement: ActionBarPlacement.InOverflow
            imageSource: "asset:///images/bb10/ic_show_vkb.png"
            onTriggered: {
                opVisible = !opVisible;
                _misc.setConfig(common.settingsKey.audioPlayerOpVisible, opVisible ? "1" : "0");
            }
            shortcuts: [
                Shortcut {
                    key: "h"
                }
            ]
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
                layout: DockLayout {
                    
                }
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                // 背景小猫猫，表示无播放
                WebImageView {
                    visible: !listAlbumInfo
                    url: "asset:///images/no_content.png"
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    scalingMethod: ScalingMethod.AspectFill
                }
                ListView {
                    property variant common_: common
                    
                    scrollRole: ScrollRole.Main
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    dataModel: ArrayDataModel {
                        id: dm
                    }
                    onTriggered: {
                        if(dm.data(indexPath)['__type']) {
                            return;
                        }
                        // 付费声音处理
                        if(common.isNotFree(dm.data(indexPath))) {
                            _misc.showToast(qsTr("此集为付费声音，无法播放"));
                            return;
                        }
                        // 如果是播放的不是当前页的话，则需要更新专辑信息
                        if(listAlbumInfo['data']['pageId'] != albumInfo['data']['pageId']) {
                            audioPlayer.setAlbumInfo(listAlbumInfo);
                        }
                        audioPlayer.go(dm.data(indexPath)['trackId']);
                    }
                    // 重写 itemType
                    function itemType(data, indexPath) {
                        return data.__type || "item";
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: "item"
                            CustomListItem {
                                id: trackItem
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
                                            layoutProperties: StackLayoutProperties {
                                                spaceQuota: 1
                                            }
                                            text: ListItemData['title']
                                            textStyle {
                                                color: trackItem.ListItem.view.common_.isNotFree(ListItemData) ? Color.Gray : ui.palette.textOnPlain
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
                id: opContainer
                visible: opVisible
                background: ui.palette.plain
                topPadding: ui.du(2)
                bottomPadding: ui.du(2)
                leftPadding: ui.du(2)
                rightPadding: ui.du(2)
                
                verticalAlignment: VerticalAlignment.Center
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Container {
                    id: exitBtnContainer
                    property variant currentExitTime: 0
                    property variant exitTime: 0
                    rightPadding: ui.du(1)
                    
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    implicitLayoutAnimationsEnabled: false
                    
                    Button {
                        text: exitBtnSubContainer.visible ? qsTr("停止") : qsTr("定时关闭")
                        appearance: exitBtnContainer.getAppearanceType(0)
                        onClicked: {
                            if(exitBtnSubContainer.visible) {
                                exitBtnContainer.clickBtn(-1);
                            }
                            
                            exitBtnSubContainer.visible = true;
                            paginationContainer.visible = false;
                        }
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                    }
                    Container {
                        id: exitBtnSubContainer
                        visible: false
                        
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 3
                        }
                        Button {
                            text: qsTr("0.5")
                            appearance: exitBtnContainer.getAppearanceType(30)
                            onClicked: {
                                exitBtnContainer.clickBtn(30);
                            }
                        }
                        Button {
                            text: qsTr("1.0")
                            appearance: exitBtnContainer.getAppearanceType(60)
                            onClicked: {
                                exitBtnContainer.clickBtn(60);
                            }
                        }
                        Button {
                            text: qsTr("2.0")
                            appearance: exitBtnContainer.getAppearanceType(120)
                            onClicked: {
                                exitBtnContainer.clickBtn(120);
                            }
                        }
                        Button {
                            text: qsTr("3.0")
                            appearance: exitBtnContainer.getAppearanceType(180)
                            onClicked: {
                                exitBtnContainer.clickBtn(180);
                            }
                        }
                        Button {
                            text: "✘"
                            appearance: ControlAppearance.Primary
                            onClicked: {
                                exitBtnSubContainer.visible = false;
                                paginationContainer.visible = true;
                            }
                        }
                    }
                    
                    function getAppearanceType(min) {
                        return exitBtnContainer.exitTime/1000/60 === min ? ControlAppearance.Primary : ControlAppearance.Plain
                    }
                    
                    function clickBtn(min) {
                        if(min === -1) { // 停止定时关闭
                            if(exitBtnContainer.exitTime != 0) {
                                _misc.showToast(qsTr("定时关闭已取消"));
                            }
                            // 先提示，在停止，因为停止信号会马上发送过来
                            audioPlayer.startExitTimer(-1);
                        }else {
                            if(exitBtnContainer.exitTime/1000/60 !== min) {
                                audioPlayer.startExitTimer(min);
                                
                                _misc.showToast(min + qsTr("分钟后自动关闭"));
                            }else {
                                _misc.showToast(qsTr("定时关闭，剩余：") + formatTime(exitBtnContainer.exitTime - exitBtnContainer.currentExitTime));
                            }
                        }
                    }
                }
                Container {
                    id: paginationContainer
                    visible: true
                    horizontalAlignment: HorizontalAlignment.Fill
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 3
                    }
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
                            if(!listAlbumInfo) {
                                return;
                            }
                            common.apiAlbumInfo(albumInfoRequester, listAlbumInfo['data']['list'][0]['albumId'], listAlbumInfo['data']['pageId'] - 1);
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
                            if(!listAlbumInfo) {
                                return;
                            }
                            common.apiAlbumInfo(albumInfoRequester, listAlbumInfo['data']['list'][0]['albumId'], listAlbumInfo['data']['pageId'] + 1);
                        }
                    }
                    Button {
                        text: listAlbumInfo ? (listAlbumInfo['data']['pageId'] + '/' + listAlbumInfo['data']['maxPageId']) : '0/0'
                        horizontalAlignment: HorizontalAlignment.Fill
                        appearance: ControlAppearance.Plain
                        // enabled: false
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                    }
                }
            }
            // 底部进度条
            ItemContainer {
                id: timelineContainer
                visible: opVisible
                layout_: StackLayout {}
                background: ui.palette.plain
                verticalAlignment: VerticalAlignment.Bottom
                
                Slider {
                    fromValue: 0
                    toValue: duration
                    value: position
                    onTouch: {
                        if((event.isUp() || event.isCancel()) && audioPlayer.mediaState !== MediaState.Unprepared) {
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
            visible: isLoading
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            background: Color.create(0,0,0,0.5)
            
            ActivityIndicator {
                running: true
                preferredHeight: 100
                preferredWidth: 100
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
            }
        }
    }
    
    attachedObjects: [
        Requester {
            id: albumInfoRequester
            onBeforeSend: {
                isLoading = true;
            }
            onFinished: {
                isLoading = false;
                var rt = JSON.parse(data);
                if(rt.ret === 0) {
                    renderList(rt);
                }else {
                    _misc.showToast(rt.msg);
                }
            }
            onError: {
                _misc.showToast(error);
                isLoading = false;
            }
        }
    ]
    
    onTrackIdChanged: {
        var currentPlayTrackId = _misc.getConfig(common.settingsKey.currentPlayTrackId, "");
        var isEmptyAlbumInfo = !audioPlayer.albumInfo;
        
        /**
         * 进入播放器，初始化
         * (currentPlayTrackId != trackId) ==> 切换声音
         * (trackId === -1) ==> 直接打开播放器
         * (isEmptyAlbumInfo) 关闭应用，继续点击播放最后一个播放声音，应该初始化 albumInfo
         */
        if(currentPlayTrackId != trackId || trackId === -1 || isEmptyAlbumInfo) { // 切换声音，或者直接进入播放器
            var playTrackId = trackId;
            
            if(trackId === -1) { // 如果是直接打开播放器，则取出相应的信息
                playTrackId = currentPlayTrackId;
                albumInfo = audioPlayer.albumInfo;

                // 如果连播放器中都没有消息，则是新打开播放器，什么都没播放
                if(!albumInfo) {
                    isLoading = false;
                    return;
                }
            }
            // 继续验证专辑信息是否存在
            if(!albumInfo) {
                _misc.showToast(qsTr("无专辑信息，播放失败"));
                isLoading = false;
                return;
            }
            
            audioPlayer.setAlbumInfo(albumInfo);
            audioPlayer.go(playTrackId);
        }else {
            // 初始化信息
            albumInfo = audioPlayer.albumInfo;
            // 如果是暂停状态进来的，也继续播放
            // audioPlayer.play();
            // 渲染界面
            render();
            renderList(albumInfo);
            
            isLoading = false;
        }
    }
    
    // connect start 
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
        if(JSON.stringify(listAlbumInfo) !== JSON.stringify(albumInfo)) {
            renderList(albumInfo)
        }
    }
    function albumEnd(flag) {
        if(flag == 1) {
            _misc.showToast(qsTr("专辑播放完毕"));
        }else {
            _misc.showToast(qsTr("没有可播放的上一集"));
        }
        isLoading = false;
    }
    function track404() {
        isLoading = false;
        _misc.showToast(qsTr("无法播放付费声音"));
    }
    function preNextTrack() {
        isLoading = true;
    }
    function exitTimerInterval(currentExitTime, exitTime) {
        exitBtnContainer.currentExitTime = currentExitTime;
        exitBtnContainer.exitTime = exitTime;
    }
    // connect end 
    
    // 保存当前专辑信息，并加载列表
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
    
    // 格式化时间戳为：mm:ss
    function formatTime(s) {
        return common.formatPlayerDuration(s);
    }
}
