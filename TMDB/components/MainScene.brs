' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of  MainScene
' Note that we need to import this file in MainScene.xml using relative path.
sub Init()
    ' set background color for scene. Applied only if backgroundUri has empty value
    m.top.backgroundUri = "pkg:/images/background.jpg"
    m.loadingIndicator = m.top.FindNode("loadingIndicator") ' store loadingIndicator node to m

    InitScreenStack() ' a.k.a BackStack
    ShowGridScreen()

    ' m.top.setFocus(true)
    m.top.observeField("keyEvent", "onKeyEvent")

    ' RunContentTask(["Now Playing"], ["/now_playing"]) ' retrieving content", endpoint) ' retrieving content
    RunContentTask(["Top Rated", "Now Playing", "Popular"], ["/tv/top_rated","/now_playing", "/tv/popular"]) ' retrieving content", endpoint) ' retrieving content
    m.top.SignalBeacon("AppLaunchComplete")

    ' to handle Roku Pay we need to create channelStore object in the global node
    m.global.AddField("channelStore", "node", false)
    m.global.channelStore = CreateObject("roSGNode", "ChannelStore")
    m.navbar = m.top.findNode("navbar")
    m.navbar.observeField("itemSelected", "onItemSelected")
    setNavbarItems([{ text: "Home" }, { text: "Trending" }])

    m.focusedIndex = 0

end sub

sub setNavbarItems(items as object)
    children = []
    for each item in items 
        navItem = createObject("roSGNode", "NavBarItem")
        navItem.itemContent = item
        children.push(navItem)
    end for

    ' possible duplicate ??
    ' m.navbar = m.top.findNode("navbar")
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

' TODO NADI: does this run twice on single key press ? once with press = true and once with press = false ?
' The OnKeyEvent() function receives remote control key events
function OnkeyEvent(key as string, press as boolean) as boolean
    result = false
    rowList = m.top.findNode("rowList")
    print "<<=>> DEBUG: Key event received: " + key
    print "<<=>> DEBUG: ROWLIST in focus chain: " + rowList.isInFocusChain().ToStr()

    for i = 0 to m.navbar.getChildCount() - 1
        if m.navbar.getChild(i).IsSameNode(m.navbar.focusedChild)
            m.navbar.getChild(i).focused = true

            m.focusedIndex = i
            ' TODO NADI: why do we need to set focused = true again here ? if we already set focus below already ??
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
            prevFocusedNode = m.navbar.getChild(m.focusedIndex)
            prevFocusedNode.focused = false
            newFocusNode = m.navbar.getChild(m.focusedIndex + 1)
            newFocusNode.setFocus(true)
            return true
        else if key = "left" and m.focusedIndex > 0
            prevFocusedNode = m.navbar.getChild(m.focusedIndex)
            prevFocusedNode.focused = false
            newFocusNode = m.navbar.getChild(m.focusedIndex - 1)
            newFocusNode.setFocus(true)
            return true
        else if key = "down"
            ' Move focus from navbar to grid
            rowList.setFocus(true)
            return true
        else if key = "up" and rowList.isInFocusChain()
            print "<<=>> DEBUG: UP key pressed and rowList is in focus chain"
            ' Move focus from grid to navbar
            if m.navbar.getChildCount() > 0
                print m.focusedIndex
                print m.navbar.focusedChild
                ' TODO NADI: why do we need to set focused = true again here ? if we already set focus above
                ' because this is triggered when the up key is pressed and press is true
                ' but m.navbar.focusedChild is still invalid at this point and so for loop isnt entered
                ' that is why we need to set it here
                ' when the onKeyEvent is triggered with press = false, m.navbar.focusedChild is valid
                ' and 
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