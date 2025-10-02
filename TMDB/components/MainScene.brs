' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of  MainScene
' Note that we need to import this file in MainScene.xml using relative path.
sub Init()
    ' set background color for scene. Applied only if backgroundUri has empty value
    m.top.backgroundUri = "pkg:/images/background.jpg"
    m.loadingIndicator = m.top.FindNode("loadingIndicator") ' store loadingIndicator node to m

    InitScreenStack()
    ShowGridScreen()

    ' m.top.setFocus(true)
    m.top.observeField("keyEvent", "onKeyEvent")

    RunContentTask(["Now Playing"], ["/tv/top_rated"]) ' retrieving content", endpoint) ' retrieving content
    m.top.SignalBeacon("AppLaunchComplete")

    ' to handle Roku Pay we need to create channelStore object in the global node
    m.global.AddField("channelStore", "node", false)
    m.global.channelStore = CreateObject("roSGNode", "ChannelStore")


    m.focusedIndex = 0

end sub

' The OnKeyEvent() function receives remote control key events
function OnkeyEvent(key as string, press as boolean) as boolean
    result = false
    rowList = m.top.findNode("rowList")

    if press
        if key = "back"
            numberOfScreens = m.screenStack.Count()
            ' close top screen if there are two or more screens in the screen stack
            if numberOfScreens > 1
                CloseScreen(invalid)
                result = true
            end if
        else if key = "right" and m.focusedIndex < rowList.getChildCount() - 1
            newFocusNode = m.focusedIndex + 1
            newFocusNode.setFocus(true)
            return true
        else if key = "left" and m.focusedIndex > 0
            newFocusNode = m.focusedIndex - 1
            newFocusNode.setFocus(true)
            return true
        else if key = "down"
            ' Move focus from navbar to grid
            rowList.setFocus(true)
            return true

        end if
    end if

    return result
end function
