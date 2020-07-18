import bb.cascades 1.4
import "asset:///pages/child"

Page {
    objectName: "aboutPage"
    actionBarVisibility: ChromeVisibility.Compact
    
    Container {
        Header {
            title: qsTr("关于") + ' v' + common.version
        }
        ScrollView {
            scrollRole: ScrollRole.Main
            
            Container {
                bottomPadding: ui.du(14)
                ItemContainer {
                    Label {
                        text: qsTr('开发：<a href="https://github.com/ekoooo">ekoo</a>。<br/>' + 
                        '开源：<a href="https://github.com/ekoooo/Ximalaya-Cascades">Ximalaya-Cascades</a>。<br/>' + 
                        '建议：希望添加的功能或发现的问题可以通过 <a href="https://github.com/ekoooo/Ximalaya-Cascades/issues">Issue(推荐)</a> 或 <a href="mailto: ' + common.developerEmail + '">邮件</a> 告知。')
                        textStyle {
                            base: SystemDefaults.TextStyles.SubtitleText
                            color: Color.Gray
                        }
                        multiline: true
                        textFormat: TextFormat.Html
                    }
                }
                Divider {}
                Header {
                    title: qsTr("初衷")
                }
                ItemContainer {
                    Label {
                        text: qsTr('　　有了看——《知乎日报》，再来个听——《喜马拉雅》。')
                        multiline: true
                    }
                }
                Divider {}
                Header {
                    title: qsTr("声明")
                }
                ItemContainer {
                    Label {
                        text: qsTr('　　本项目文字声音等内容均由 <a href="http://www.ximalaya.com/">喜马拉雅</a> 提供。若被告知需停止共享与使用，本人会及时删除整个项目。请您了解相关情况，并遵守相关协议。')
                        textFormat: TextFormat.Html
                        multiline: true
                    }
                }
            }
        }
    }
}
