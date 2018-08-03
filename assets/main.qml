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
                listRequester.send("http://mobile.ximalaya.com/mobile/v1/album/track?albumId=4756811&pageId=1&pageSize=20&device=android&isAsc=true");
            }
        }
    }
    
    attachedObjects: [
        AudioPlayer {
            id: player
            onMyPositionChanged: {
                audioPlayerUIPage && audioPlayerUIPage.positionChanged(position)
            }
            onMyDurationChanged: {
                audioPlayerUIPage && audioPlayerUIPage.durationChanged(duration);
            }
            onMyMediaStateChanged: {
                audioPlayerUIPage && audioPlayerUIPage.mediaStateChanged(mediaState);
            }
            onCurrentTrackChanged: {
                audioPlayerUIPage && audioPlayerUIPage.currentTrackChanged();
            }
            onPreviousOrNext: {
                audioPlayerUIPage && audioPlayerUIPage.previousOrNext(flag);
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
