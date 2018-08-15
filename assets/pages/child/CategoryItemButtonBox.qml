import bb.cascades 1.4

Container {
    property variant label
    signal click()
    
    background: ui.palette.plain
    topPadding: ui.du(1)
    bottomPadding: ui.du(1)
    rightPadding: ui.du(3)
    leftPadding: ui.du(3)
    margin.rightOffset: ui.du(3)
    Label {
        text: label
        textStyle.color: ui.palette.secondaryTextOnPlain
    }
    
    onTouch: {
        if(event.isUp()) {
            click();
        }
    }
}