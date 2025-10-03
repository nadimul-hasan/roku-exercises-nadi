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

    RunContentTask(["Now Playing"], ["/now_playing"]) ' retrieving content", endpoint) ' retrieving content
    m.top.SignalBeacon("AppLaunchComplete")

    ' to handle Roku Pay we need to create channelStore object in the global node
    m.global.AddField("channelStore", "node", false)
    m.global.channelStore = CreateObject("roSGNode", "ChannelStore")
    m.top.findNode("navbar").observeField("itemSelected", "onItemSelected")
    setNavbarItems([])
    m.navbar = m.top.findNode("navbar")

    m.focusedIndex = 0

end sub

sub setNavbarItems(items as object)
    children = []
    for each item in [{ text: "Home" }, { text: "Trending" }]
        navItem = createObject("roSGNode", "NavBarItem")
        navItem.itemContent = item
        children.push(navItem)
    end for
    m.navbar = m.top.findNode("navbar")
    m.navbar.removeChildrenIndex(m.navbar.getChildCount(), 0)
    m.navbar.appendChildren(children)

    ' navbar.getChild(0).setFocus(true)
    ' print "<<=>> DEBUG: setNavbarItems at index: " + " - " + navbar.focusedChild.text
end sub

sub onItemSelected()
    selectedIndex = m.navbar.getChildIndex(m.navbar.focusedChild)
    ' Use the selectedIndex to load content or navigate
    print "<<=>> DEBUG: Item selected at index: " + Str(selectedIndex) + " - " + m.navbar.itemContent.text
end sub

' The OnKeyEvent() function receives remote control key events
function OnkeyEvent(key as string, press as boolean) as boolean
    result = false
    rowList = m.top.findNode("rowList")

    for i = 0 to m.navbar.getChildCount() - 1
        if m.navbar.getChild(i).IsSameNode(m.navbar.focusedChild)
            m.navbar.getChild(i).focused = true

            m.focusedIndex = i
            m.navbar.getChild(m.focusedIndex).setFocus(true)
            exit for
        end if
    end for

    if press

        if key = "back"
            numberOfScreens = m.screenStack.Count()
            ' close top screen if there are two or more screens in the screen stack
            if numberOfScreens > 1
                CloseScreen(invalid)
                result = true
            end if
        else if key = "right" and m.focusedIndex < m.navbar.getChildCount() - 1
            newFocusNode = m.navbar.getChild(m.focusedIndex + 1)
            newFocusNode.setFocus(true)
            return true
        else if key = "left" and m.focusedIndex > 0
            newFocusNode = m.navbar.getChild(m.focusedIndex - 1)
            newFocusNode.setFocus(true)
            return true
        else if key = "down"
            ' Move focus from navbar to grid
            rowList.setFocus(true)
            return true
        else if key = "up" and rowList.isInFocusChain()
            ' Move focus from grid to navbar
            if m.navbar.getChildCount() > 0
                print m.focusedIndex
                print m.navbar.focusedChild
                m.navbar.getChild(m.focusedIndex).setFocus(true)
            end if
            return true
        else if key = "OK" and m.navbar.focusedChild <> invalid
            if m.navbar.getChild(i).itemContent.text = "Trending"
                title = ["Trending"]
                endpoint = ["/trending"]
            else
                title = ["Now Playing"]
                endpoint = ["/now_playing"]
            end if
            RunContentTask(title, endpoint) ' retrieving content
            return true
        end if
    end if

    return result
end function