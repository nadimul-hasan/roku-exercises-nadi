' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub InitScreenStack()
    m.screenStack = []
end sub

sub ShowScreen(node as object)
    prev = m.screenStack.Peek() ' take current screen from screen stack but don't delete it
    if prev <> invalid
        prev.visible = false ' hide current screen if it exist
    end if
    m.top.AppendChild(node) ' add new screen to scene
    ' show new screen
    node.visible = true
    node.SetFocus(true)
    m.screenStack.Push(node) ' add new screen to the screen stack
end sub

sub CloseScreen(node as object)
    if node = invalid or (m.screenStack.Peek() <> invalid and m.screenStack.Peek().IsSameNode(node))
        last = m.screenStack.Pop() ' remove screen from screenStack
        last.visible = false ' hide screen
        m.top.RemoveChild(last)
        ' take previous screen and make it visible
        prev = m.screenStack.Peek()
        if prev <> invalid
            prev.visible = true
            prev.SetFocus(true)
        end if
    end if
end sub

sub AddScreen(node as object)
    m.top.AppendChild(node) ' add new screen to scene
    m.screenStack.Push(node) ' add new screen to the screen stack
end sub

sub ClearScreenStack()
    if m.screenStack.Count() > 1
        while m.screenStack.Count() > 1
            last = m.screenStack.Pop() ' remove screen from screenStack
            if last.visible = true
                last.visible = false ' hide screen
            end if
            m.top.RemoveChild(last)
        end while
    else
        m.screenStack.Peek().visible = false ' take current screen from screen stack but don't delete it
    end if
end sub

function GetCurrentScreen()
    return m.screenStack.Peek()
end function

function IsScreenInScreenStack(node as object) as boolean
    ' check if screen stack contains specified node
    for each screen in m.screenStack
        result = screen.IsSameNode(node)
        if result = true
            return true
        end if
    end for
    return false
end function