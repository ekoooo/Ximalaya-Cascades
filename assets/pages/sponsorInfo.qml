import bb.cascades 1.4
import tech.lwl 1.0

Page {
    objectName: "sponsorInfoPage"
    actionBarVisibility: ChromeVisibility.Compact
    titleBar: TitleBar {
        title: qsTr("我要赞助")
        scrollBehavior: TitleBarScrollBehavior.NonSticky
    }
    
    ScrollView {
        scrollRole: ScrollRole.Main
        
        Container {
            bottomPadding: ui.du(14)
            topPadding: ui.du(2)
            Label {
                text: qsTr("如果你想，就请开发者喝杯矿泉水吧！")
                horizontalAlignment: HorizontalAlignment.Center
                multiline: true
                margin {
                    leftOffset: ui.du(2)
                    rightOffset: ui.du(2)
                    topOffset: ui.du(5)
                    bottomOffset: ui.du(5)
                }
                textStyle {
                    fontSize: FontSize.Medium
                }
            }
            Divider {}
            Header {
                title: qsTr("微信赞助")
            }
            WebImageView {
                url: "asset:///images/qr_wxpay.png"
                preferredWidth: ui.du(30)
                scalingMethod: ScalingMethod.AspectFit
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
            }
            Divider {}
            Header {
                title: qsTr("支付宝赞助")
            }
            WebImageView {
                url: "asset:///images/qr_alipay.png"
                preferredWidth: ui.du(30)
                scalingMethod: ScalingMethod.AspectFit
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
            }
        }
    }
}
