' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "GetContent"
end sub

sub GetContent()

    rows = []
    index = 0
    for each endpoint in m.top.sectionEndpoint
        sectionName = m.top.sectionName[index]
        sectionEndpoint = m.top.sectionEndpoint[index]

        BASE_URL = getURL()
        ' Available endpoints: trending, now_playing, /movie/popular, /movie/top_rated, tv/popular, tv/top_rated
        url = BASE_URL + sectionEndpoint


        ' request the content feed from the API
        xfer = CreateObject("roURLTransfer")
        xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
        xfer.SetURL(url)
        response = xfer.GetToString()
        rootChildren = []
        rows.push(response)
        index++
    end for
    index = 0
    for each rsp in rows
        homeRowIndex = 0
        if Instr(m.top.sectionEndpoint[index], "/tv/") > 0

            ' parse the feed and build a tree of ContentNodes to populate the GridView
            json = ParseJson(rsp)

            if json <> invalid

                for each category in json

                    value = json.Lookup(category)
                    if Type(value) = "roArray" ' if parsed key value having other objects in it
                        row = {}
                        row.title = m.top.sectionName[index]
                        row.children = []
                        homeItemIndex = 0
                        for each item in value ' parse videos and push them to row

                            jsonSeasons = item.season_details

                            ' ROKU EXERCISE TASK
                            ' FETCH the Seasons data
                            seasons = GetSeasonData(jsonSeasons, homeRowIndex, homeItemIndex, Str(item.id).Trim(), item)
                            itemData = GetSeriesItemData(item)
                            itemData.homeRowIndex = homeRowIndex
                            itemData.homeItemIndex = homeItemIndex
                            itemData.mediaType = category 'update this. category is results
                            if seasons <> invalid and seasons.Count() > 0
                                itemData.children = seasons
                            end if

                            row.children.Push(itemData)
                            homeItemIndex++
                        end for
                        rootChildren.Push(row)
                        homeRowIndex++
                    end if
                end for
                ' set up a root ContentNode to represent rowList on the GridScreen
                contentNode = CreateObject("roSGNode", "ContentNode")
                contentNode.Update({
                    children: rootChildren
                }, true)
                ' populate content field with root content node.
                ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment
                m.top.content = contentNode
            end if

        else

            ' parse the feed and build a tree of ContentNodes to populate the GridView
            json = ParseJson(rsp).results
            if json <> invalid



                value = json
                if Type(value) = "roArray" ' if parsed key value having other objects in it
                    row = {}
                    row.title = m.top.sectionName[index]
                    row.children = []
                    homeItemIndex = 0
                    for each item in value ' parse videos and push them to row
                        if item = invalid
                            exit for
                        end if
                        itemData = GetMovieItemData(item)
                        itemData.homeRowIndex = homeRowIndex
                        itemData.homeItemIndex = homeItemIndex
                        itemData.mediaType = "results" 'update this. category is results

                        row.children.Push(itemData)
                        homeItemIndex++
                    end for
                    rootChildren.Push(row)
                    homeRowIndex++
                end if

                ' set up a root ContentNode to represent rowList on the GridScreen
                contentNode = CreateObject("roSGNode", "ContentNode")
                contentNode.Update({
                    children: rootChildren
                }, true)
                ' populate content field with root content node.
                ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment
                m.top.content = contentNode
            end if


        end if
        index++
    end for

end sub

' ROKU EXERCISE TASK add more data here
function GetMovieItemData(video as object) as object
    item = {}
    ' populate some standard content metadata fields to be displayed on the GridScreen

    if video.overview <> invalid
        item.description = video.overview
    else
        item.description = video.overview
    end if
    item.hdPosterURL = "https://media.themoviedb.org/t/p/w600_and_h900_bestv2" + video.poster_path
    if video.backdrop_path <> invalid
        item.hdBackgroundURL = "https://image.tmdb.org/t/p/w1280/" + video.backdrop_path
    end if

    return item
end function


' ROKU EXERCISE TASK add more data here
function GetSeriesItemData(video as object) as object
    item = {}
    ' populate some standard content metadata fields to be displayed on the GridScreen
    ' Check the TMDB API response for available fields
    ' https://developer.themoviedb.org/reference/tv-series-popular-list
    if video.overview <> invalid
        item.description = video.overview
    else
        item.description = video.overview
    end if
    item.hdPosterURL = "https://media.themoviedb.org/t/p/w600_and_h900_bestv2" + video.poster_path
    item.hdBackgroundURL = "https://image.tmdb.org/t/p/w1280/" + video.backdrop_path

    return item
end function



' ROKU EXERCISE TASK add more data here
function GetEpisodesItemData(episodeItem as object) as object
    item = {}
    ' populate some standard content metadata fields to be displayed on the GridScreen
    ' Check the TMDB API response for available fields
    ' https://developer.themoviedb.org/reference/tv-episode-details

    if episodeItem.overview <> invalid
        item.description = episodeItem.overview
    else
        item.description = "No description available"
    end if

    item.hdBackgroundURL = "https://image.tmdb.org/t/p/w1280/" + episodeItem.backdrop_path

    return item
end function


function GetSeasonData(seasons as object, homeRowIndex as integer, homeItemIndex as integer, seriesId as string, episodeItem as object) as object
    ' ROKU EXERCISE TASK
    ' show seasons data. Use the EpisodesListItemComponent to show each episode in the season
    seasonsArray = []
    seasonCounter = 0
    if seasons <> invalid
        for each season in seasons

            print "Fetching season " + seasonCounter.ToStr() + " for series id " + seriesId
            print "Show data from"
            print GetEpisodesItemData(episodeItem)

            episodes = []

        end for
    end if
    return seasonsArray
end function