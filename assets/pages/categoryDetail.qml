import bb.cascades 1.4
import tech.lwl 1.0

Page {
    property variant categoryId
    property variant keywordId // 此参数用于 itemType == 1 时，直接搜索一级搜索条件
    
    Container {
        
    }
    
    attachedObjects: [
        Requester {
            id: keywordsRequester
            onFinished: {
                console.log('keywordsRequester', data);
            }
            onError: {
                _misc.showToast(error);
            }
        },
        Requester {
            id: metadatasRequester
            onFinished: {
                console.log('metadatasRequester', data);
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
