sub Init()
    ' Only initialize bottomBorder, which is a valid child node
    m.bottomBorder = m.top.FindNode("bottomBorder")
    m.label = m.top.FindNode("label")

    ' Example: Access all items from parent if possible



end sub

sub OnContentSet()
    if m.top.itemContent <> invalid and m.top.itemContent.text <> invalid
        m.label.text = m.top.itemContent.text
    else
        m.label.text = "Text"
        print "DEBUG: itemContent or itemContent.text is invalid"
    end if

end sub

sub OnFocusedChanged()
    focused = m.top.focused
    if focused = true
        m.bottomBorder.visible = true
        m.bottomBorder.color = "#FFFFFF"
    else
        m.bottomBorder.visible = false
        m.bottomBorder.color = "#7f7f7f"
        m.label.opacity = 0.7
    end if
end sub

