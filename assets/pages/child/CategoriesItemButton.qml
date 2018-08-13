import bb.cascades 1.4
import tech.lwl 1.0

Container {
    property variant info: {
        itemType: 0,
        itemDetail: {
            // itemType: 0
            categoryId: 0,
            name: '',
            title: '',
            categoryType: 0,
            moduleType: 0,
            filterSupported: true,
            // itemType: 1
            keywordId: 0,
            keywordName: ''
            // categoryId: 0
        },
        isDisplayCornerMark: false,
        coverPath: ''
    }
    property bool isLast: false
    property bool isCenter: true
    property int lineWidth: 4

    background: ui.palette.plain
    topPadding: ui.du(3)
    bottomPadding: ui.du(3)
    leftPadding: isCenter ? 0 : ui.du(2)
    
    margin.rightOffset: isLast ? 0 : lineWidth
    margin.bottomOffset: lineWidth
    
    horizontalAlignment: HorizontalAlignment.Fill
    onTouch: {
        if(event.isUp()) {
            // 1. 跳转
            // 2. 保存最近浏览
            var lastViewArr = JSON.parse(tabbedPane.lastViewCategory);
            // 判断是否存在
            for(var i = 0; i < lastViewArr.length; i++) {
                if(JSON.stringify(lastViewArr[i]) === JSON.stringify(info)) {
                    return;
                }
            }
            
            if(lastViewArr.length < 3) {
                lastViewArr.unshift(info);
            }else {
                lastViewArr[2] = lastViewArr[1];
                lastViewArr[1] = lastViewArr[0];
                lastViewArr[0] = info;
            }
            var lastViewStr = JSON.stringify(lastViewArr);
            
            _misc.setConfig(common.settingsKey.lastViewCategory, lastViewStr);
            // 更新
            tabbedPane.lastViewCategory = lastViewStr;
        }
    }
    
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        horizontalAlignment: isCenter ? HorizontalAlignment.Center : HorizontalAlignment.Fill
        
        WebImageView {
            visible: !!info['coverPath']
            url: info['coverPath'] || ''
            preferredHeight: ui.du(3.8)
            preferredWidth: ui.du(3.8)
            scalingMethod: ScalingMethod.AspectFill
            verticalAlignment: VerticalAlignment.Center
        }
        Container {
            leftPadding: ui.du(0.5)
            Label {
                text: info['itemType'] === 0 ? info['itemDetail']['title'] : info['itemDetail']['keywordName']
                textStyle.color: ui.palette.textOnPlain
            }
        }
    }
}
