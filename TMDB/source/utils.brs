' Helper function convert AA to Node
function ContentListToSimpleNode(contentList as object, nodeType = "ContentNode" as string) as object
    result = CreateObject("roSGNode", nodeType) ' create node instance based on specified nodeType
    if result <> invalid
        ' go through contentList and create node instance for each item of list
        for each itemAA in contentList
            item = CreateObject("roSGNode", nodeType)
            item.SetFields(itemAA)
            result.AppendChild(item)
        end for
    end if
    return result
end function

' Helper function convert seconds to mm:ss format
' getTime(138) returns 2:18
function GetTime(length as integer) as string
    minutes = (length \ 60).ToStr()
    seconds = length mod 60
    if seconds < 10
        seconds = "0" + seconds.ToStr()
    else
        seconds = seconds.ToStr()
    end if
    return minutes + ":" + seconds
end function

' Helper function clone node children
function CloneChildren(node as object, startItem = 0 as integer)
    numOfChildren = node.GetChildCount() ' get number of row items
    ' populate children array only with  items started from selected one.
    ' example: row has 3 items. user select second one so we must take just second and third items.
    children = node.GetChildren(numOfChildren - startItem, startItem)
    childrenClone = []
    ' go through each item of children array and clone them.
    for each child in children
        ' we need to clone item node because it will be damaged in case of video node content invalidation
        childrenClone.Push(child.Clone(false))
    end for
    return childrenClone
end function

' Helper function finds child node by specified contentId
function FindNodeById(content as object, contentId as string) as object
    for each element in content.GetChildren(-1, 0)
        if element.id = contentId
            return element
        else if element.getChildCount() > 0
            result = FindNodeById(element, contentId)
            if result <> invalid
                return result
            end if
        end if
    end for
    return invalid
end function

' Reads and returns the value of the specified key
function RegRead(key as string, section = invalid as dynamic) as dynamic
    if section = invalid then section = "Default"
    reg = CreateObject("roRegistrySection", section)
    if reg.Exists(key) then return reg.Read(key)
    return invalid
end function

' Replaces the value of the specified key
sub RegWrite(key as string, val as string, section = invalid as dynamic)
    if section = invalid then section = "Default"
    reg = CreateObject("roRegistrySection", section)
    reg.Write(key, val)
    reg.Flush()
end sub

' Deletes the specified key
sub RegDelete(key as string, section = invalid as dynamic)
    if section = invalid then section = "Default"
    reg = CreateObject("roRegistrySection", section)
    reg.Delete(key)
    reg.Flush()
end sub


function getURL() as string
    return "BASE URL HERE"
end function