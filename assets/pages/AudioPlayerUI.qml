import bb.cascades 1.4
import bb.device 1.4
import bb.multimedia 1.4
import tech.lwl 1.0
import "asset:///pages/child"

Page {
    id: apRoot
    objectName: "audioPlayer"
    
    property AudioPlayer audioPlayer
    // 如果 trackId 改变，而且不为空，则为更换播放，如果为空则为打开播放器
    property variant trackId
    property variant albumInfo
    // 当前播放信息
    property variant trackInfo: {}
    // 是否是更新播放
    property bool isChangedTrackId: false
    
    property variant mediaState: MediaState.Stopped // 播放器状态
    property variant duration: 0 // 长度
    property variant position: 0 // 当前播放位置
    
    property bool isLoading: true
    
    titleBar: TitleBar {
        title: qsTr("正在播放：") + (trackInfo['title'] || qsTr("无"))
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
        
        // 底部封面背景
        WebImageView {
            url: trackInfo['coverLarge'] || ""
            scalingMethod: ScalingMethod.AspectFill
            failImageSource: "asset:///images/image_top_default.png"
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            implicitLayoutAnimationsEnabled: false
        }
        
        Container {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            background: Color.create(0,0,0,0.3)
            layout: StackLayout {}
            
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                layout: DockLayout {}
                horizontalAlignment: HorizontalAlignment.Center
                
                Container {
                    layout: DockLayout {}
                    verticalAlignment: VerticalAlignment.Center
                    
                    Container {
                        id: cdContainer
                        horizontalAlignment: HorizontalAlignment.Center
                        layout: DockLayout {
                        
                        }
                        margin.topOffset: ui.du(10)
                        
                        WebImageView {
                            url: "asset:///images/audio_player/aco.png"
                            preferredWidth: displayInfo.pixelSize.width * 0.45
                            preferredHeight: displayInfo.pixelSize.width * 0.45
                            scalingMethod: ScalingMethod.AspectFit
                            horizontalAlignment: HorizontalAlignment.Center
                        }
                        WebImageView {
                            url: "asset:///images/audio_player/add.png"
                            preferredWidth: displayInfo.pixelSize.width * 0.45
                            preferredHeight: displayInfo.pixelSize.width * 0.45
                            scalingMethod: ScalingMethod.AspectFit
                            horizontalAlignment: HorizontalAlignment.Center
                        }
                        animations: [
                            RotateTransition {
                                id: cdRotateTransition
                                fromAngleZ: cdContainer.rotationZ || 0
                                toAngleZ: (cdContainer.rotationZ || 0) + 360
                                duration: 10000
                                easingCurve: StockCurve.Linear
                                repeatCount: AnimationRepeatCount.Forever
                            }
                        ]
                        onCreationCompleted: {
                        
                        }
                    }
                    
                    Container {
                        horizontalAlignment: HorizontalAlignment.Center
                        translationY: ui.du(-18)
                        rotationZ: -45
                        layout: DockLayout {
                        
                        }
                        WebImageView {
                            url: "asset:///images/audio_player/af.png"
                            preferredHeight: ui.du(40)
                            preferredWidth: ui.du(40)
                            scalingMethod: ScalingMethod.AspectFit
                            verticalAlignment: VerticalAlignment.Bottom
                        }
                        animations: [
                            RotateTransition {
                                id: afAniStoped
                                fromAngleZ: 0
                                toAngleZ: -45
                                duration: 400
                                easingCurve: StockCurve.Linear
                            },
                            RotateTransition {
                                id: afAniStarted
                                fromAngleZ: -45
                                toAngleZ: 0
                                duration: 400
                                easingCurve: StockCurve.Linear
                            }
                        ]
                    }
                }
            }
            // 底部进度条
            ItemContainer {
                layout_: StackLayout {}
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
                verticalAlignment: VerticalAlignment.Bottom
            }
        }

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
    
    attachedObjects: [
        DisplayInfo {
            id: displayInfo
        }
    ]
    
    onTrackIdChanged: {
        // 如果 trackId 发生变化则播放（保存操作在 go 中）
        if(_misc.getConfig(common.settingsKey.currentPlayTrackId, "") != trackId && !!trackId) {
            isChangedTrackId = true;
            audioPlayer.setAlbumInfo(albumInfo);
            audioPlayer.go(trackId);
        }else {
            isChangedTrackId = false;
            isLoading = false;
            // 如果是暂停状态进来的，也继续播放
            audioPlayer.play();
            render();
        }
    }
    
    // connect start
    function currentTrackChanged() {
        render();
    }
    function positionChanged(p) {
        position = p;
    }
    function durationChanged(d) {
        duration = d;
    }
    function mediaStateChanged(ms) {
        if(ms === MediaState.Unprepared) {
            isLoading = true;
        }else {
            isLoading = false;
        }
        
        mediaState = ms;
        updateAni();
    }
    function previousOrNext(flag) {
        isLoading = true;
    }
    // connect end
    
    // 开始渲染
    function render() {
        trackInfo = audioPlayer.getCurrentTrackInfo();
        position = audioPlayer.position;
        duration = audioPlayer.duration;
        mediaState = audioPlayer.mediaState;
        
        updateAni();
    }
    
    // 更新动画
    function updateAni() {
        if(mediaState != MediaState.Started) {
            cdRotateTransition.stop();
            afAniStoped.play();
        }else {
            cdRotateTransition.play();
            afAniStarted.play();
        }
    }
    
    function formatTime(s) {
        var minutes = Math.floor(s/1000/60);
        var seconds = Math.floor(s/1000%60);
        return qsTr("%1:%2").arg(minutes < 10 ? "0" + minutes : "" + minutes).arg(seconds < 10 ? "0" + seconds : "" + seconds);
    }
}
