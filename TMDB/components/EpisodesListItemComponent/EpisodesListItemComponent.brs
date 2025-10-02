' Copyright (c) 2020 Roku, Inc. All rights reserved.

' entry point of EpisodesListItemComponent
sub Init()
    ' store components to m for populating them with metadata
    m.poster = m.top.FindNode("poster_season")
    m.title = m.top.FindNode("title")
    m.description = m.top.FindNode("description")
    m.info = m.top.FindNode("info")
    ' set font size for title and description Labels
    m.title.font.size = 20
    m.description.font.size = 14
    m.info.font.size = 14
end sub

sub itemContentChanged() ' invoked when episode data is retrieved
    itemContent = m.top.itemContent ' episode metadata
    index = 0
    if itemContent <> invalid
        ' populate components with metadata
        m.poster.uri = itemContent.hdBackgroundURL
        m.title.text = itemContent.title
        divider = " | "
        if itemContent.episodeName <> invalid
            episode = itemContent.episodeName
        else
            episode = "E" + Str(index)'+ itemContent.episodePosition
        end if
        index++

        date = itemContent.releaseDate
        season = itemContent.titleSeason
        m.info.text = episode + divider + date
        m.description.text = itemContent.description
    end if
end sub
