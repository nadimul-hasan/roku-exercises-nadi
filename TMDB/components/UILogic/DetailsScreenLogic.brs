' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub ShowDetailsScreen(content as object, selectedItem as integer)
    ' create new instance of details screen
    detailsScreen = CreateObject("roSGNode", "DetailsScreen")
    detailsScreen.content = content ' here the content getting passed here is the whole row like "Top Rated"
    detailsScreen.jumpToItem = selectedItem ' set index of item which should be focused
    detailsScreen.ObserveField("visible", "OnDetailsScreenVisibilityChanged")
    detailsScreen.ObserveField("buttonSelected", "OnButtonSelected")
    ShowScreen(detailsScreen)
end sub

sub OnDetailsScreenVisibilityChanged(event as object) ' invoked when DetailsScreen "visible" field is changed
    visible = event.GetData()
    detailsScreen = event.GetRoSGNode()
    currentScreen = GetCurrentScreen()
    screenType = currentScreen.SubType()
    if visible = false
        if screenType = "GridScreen"
            ' update GridScreen's focus when navigate back from DetailsScreen
            currentScreen.jumpToRowItem = [m.selectedIndex[0], detailsScreen.itemFocused]
        else if screenType = "EpisodesScreen"
            ' update EpisodesScreen's focus when navigate back from DetailsScreen
            content = detailsScreen.content.GetChild(detailsScreen.itemFocused)
            currentScreen.jumpToItem = content.numEpisodes
        end if
    end if
end sub

sub OnButtonSelected(event) ' invoked when button in DetailsScreen is pressed
    details = event.GetRoSGNode()
    content = details.content
    buttonIndex = event.getData() ' index of selected button
    button = details.buttons.getChild(buttonIndex)
    selectedItem = details.itemFocused
    if button.id = "see all episodes" ' check if "See all episodes" button is pressed
        ' create EpisodesScreen instance and show it
        ShowEpisodesScreen(content.GetChild(selectedItem), selectedItem) ' content.getChild(selectedItem) is the selected TV show
    end if
end sub

