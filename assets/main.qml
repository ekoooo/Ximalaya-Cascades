/*
 * Copyright (c) 2011-2015 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.4
import bb.multimedia 1.4
import tech.lwl 1.0
import "asset:///common"

NavigationPane {
    id: nav
    property variant albumInfo
    property variant trackId
    property variant audioPlayerUIPage
    
    Page {
        Container {
            ListView {
                id: lv
                dataModel: ArrayDataModel {
                    id: dm
                }
                onTriggered: {
                    nav.trackId = dm.data(indexPath)['trackId'];
                    nav.goAudioPlayerUI();
                }
                listItemComponents: [
                    ListItemComponent {
                        type: ""
                        CustomListItem {
                            Label {
                                verticalAlignment: VerticalAlignment.Center
                                text: ListItemData['title']
                            }
                        }
                    }
                ]
                onCreationCompleted: {
                    listRequester.send("http://mobile.ximalaya.com/mobile/v1/album/track?albumId=13394295&pageId=2&pageSize=20&device=android&isAsc=true");
                }
            }
            
            Button {
                text: "open"
                onClicked: {
                    nav.trackId = -1;
                    nav.goAudioPlayerUI();
                }
                horizontalAlignment: HorizontalAlignment.Fill
            }
        }
    }
    
    attachedObjects: [
        AudioPlayer {
            id: player
            onPositionChanged: {
                audioPlayerUIPage && audioPlayerUIPage.positionChanged(position)
            }
            onDurationChanged: {
                audioPlayerUIPage && audioPlayerUIPage.durationChanged(duration);
            }
            onMediaStateChanged: {
                audioPlayerUIPage && audioPlayerUIPage.mediaStateChanged(mediaState);
            }
            onCurrentTrackChanged: {
                audioPlayerUIPage && audioPlayerUIPage.currentTrackChanged(trackId);
            }
            onAlbumInfoChanged: {
                audioPlayerUIPage && audioPlayerUIPage.albumInfoChanged();
            }
            onAlbumEnd: {
                audioPlayerUIPage && audioPlayerUIPage.albumEnd(flag);
            }
            onTrack404: {
                audioPlayerUIPage && audioPlayerUIPage.track404();
            }
            onPreNextTrack: {
                audioPlayerUIPage && audioPlayerUIPage.preNextTrack();
            }
            onExitTimerInterval: {
                audioPlayerUIPage && audioPlayerUIPage.exitTimerInterval(currentExitTime, exitTime);
            }
        },
        Common {
            id: common
        },
        Requester {
            id: listRequester
            onFinished: {
                var rs = JSON.parse(data);
                dm.clear();
                dm.insert(0, rs.data.list);
                
                nav.albumInfo = rs;
            }
        },
        ComponentDefinition {
            id: audioPlayerUI
            source: "asset:///pages/AudioPlayerUI.qml"
        },
        QTimer {
            id: timer
            interval: 200
            onTimeout: {
                timer.stop();
                initAudioPlayerUI();
            }
        }
    ]
    
    function goAudioPlayerUI() {
        audioPlayerUIPage = audioPlayerUI.createObject();
        nav.push(audioPlayerUIPage);
        timer.start();
    }
    function initAudioPlayerUI() {
        audioPlayerUIPage.audioPlayer = player;
        audioPlayerUIPage.albumInfo = nav.albumInfo;
        audioPlayerUIPage.trackId = nav.trackId; // 注意顺序，trackId 赋值必须在最后面。
    }
    
    onPopTransitionEnded: {
        page.destroy();
    }
}
