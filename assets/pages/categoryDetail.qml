import bb.cascades 1.4
import tech.lwl 1.0
import "asset:///pages/child"

Page {
    property variant categoryId
    property variant keywordId // 此参数用于 itemType == 1 时，直接搜索一级搜索条件
    
    actionBarVisibility: ChromeVisibility.Compact
    titleBar: TitleBar {
        id: titleBar
        title: " "
        scrollBehavior: TitleBarScrollBehavior.NonSticky
    }
    
    Container {
        KeywordsListView {
            id: keywordsListView
            onSelected: {
                metadatasContainer.visible = !keywordId;
                _misc.showToast(keywordId);
            }
        }
        MetadatasContainer {
            id: metadatasContainer
            onSelected: {
                _misc.showToast(metadatasInfo);
            }
        }
    }
    
    attachedObjects: [
        Requester {
            id: keywordsRequester
            onFinished: {
                var rt = JSON.parse(data);
                if(rt['ret'] === 0) {
                    keywordsListView.keywords = rt['keywords'];
                    titleBar.title = rt['categoryInfo']['title'];
                }else {
                    _misc.showToast(rt['msg'] || qsTr("获取 keywords 失败，请重试"));
                }
            }
            onError: {
                _misc.showToast(error);
            }
        },
        Requester {
            id: metadatasRequester
            onFinished: {
                var rt = JSON.parse(data);
                if(rt['ret'] === 0) {
                    metadatasContainer.metadatas = rt['metadatas'];
                }else {
                    _misc.showToast(rt['msg'] || qsTr("获取 metadatas 失败，请重试"));
                }
            }
            onError: {
                _misc.showToast(error);
            }
        },
        QTimer {
            id: initTimer
            interval: 300
            onTimeout: {
                initTimer.stop();
                initSearchParams();
            }
        }
    ]
    
    onCategoryIdChanged: {
        initTimer.start();
    }
    
    function initSearchParams() {
        common.apiKeywords(keywordsRequester, categoryId);
        common.apiMetadatas(metadatasRequester, categoryId);
    }
}
