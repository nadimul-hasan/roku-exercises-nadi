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
        ' in brs we don't really care about scopes other than function and global scopes, so that's why rootChildren.Push() was working in the next loop too
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

                            seasons = GetSeasonData(jsonSeasons, homeRowIndex, homeItemIndex, Str(item.id).Trim(), item) ' here we pass the whole tv show data and get back the seasons array
                            itemData = GetSeriesItemData(item) ' whole tv show data
                            itemData.homeRowIndex = homeRowIndex
                            itemData.homeItemIndex = homeItemIndex

                            itemData.mediaType = category 'update this. category is results
                            if seasons <> invalid and seasons.Count() > 0
                                itemData.type = "series"
                                itemData.children = seasons ' here seasons should be an array of associative arrays with each season containing an array of episodes
                            end if

                            row.children.Push(itemData)
                            homeItemIndex++
                        end for
                        rootChildren.Push(row) ' as of now rootChildren is an array of associative arrays
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
    item.title = video.title

    if video.overview <> invalid
        item.description = video.overview
    else
        item.description = video.overview
    end if

    item.releaseDate = video.release_date
    ' item.avg_vote = video.vote_average
    ' item.popularity = video.popularity

    item.hdPosterURL = "https://media.themoviedb.org/t/p/w600_and_h900_bestv2" + video.poster_path
    if video.backdrop_path <> invalid
        item.hdBackgroundURL = "https://image.tmdb.org/t/p/w1280" + video.backdrop_path
    end if

    return item
end function


' ROKU EXERCISE TASK add more data here
function GetSeriesItemData(video as object) as object
    item = {}
    ' populate some standard content metadata fields to be displayed on the GridScreen
    ' Check the TMDB API response for available fields
    ' https://developer.themoviedb.org/reference/tv-series-popular-list
    item.title = video.name
    item.releaseDate = video.first_air_date
    if video.overview <> invalid
        item.description = video.overview
    else
        item.description = video.overview
    end if

    item.hdPosterURL = "https://media.themoviedb.org/t/p/w600_and_h900_bestv2" + video.poster_path
    item.hdBackgroundURL = "https://image.tmdb.org/t/p/w1280" + video.backdrop_path

    return item
end function



' ROKU EXERCISE TASK add more data here
function GetEpisodesItemData(episodeItem as object) as object
    item = {}
    ' populate some standard content metadata fields to be displayed on the GridScreen
    ' Check the TMDB API response for available fields
    ' https://developer.themoviedb.org/reference/tv-episode-details
    item.name = episodeItem.name
    item.episode_number = episodeItem.episode_number
    item.avgVote = episodeItem.vote_average
    item.releaseDate = episodeItem.air_date
    ' TODO NADI: add cast memebers and stuff too maybe for the other screen

    if episodeItem.overview <> invalid
        item.description = episodeItem.overview
    else
        item.description = "No description available"
    end if

    ' item.hdBackgroundURL = "https://image.tmdb.org/t/p/w1280" + episodeItem.backdrop_path
    if episodeItem.still_path <> invalid
        item.still_path = "https://image.tmdb.org/t/p/w1280" + episodeItem.still_path
    else
        item.still_path = invalid
    end if

    return item
end function


function GetSeasonData(seasons as object, homeRowIndex as integer, homeItemIndex as integer, seriesId as string, episodeItem as object) as object
    ' ROKU EXERCISE TASK
    ' show seasons data. Use the EpisodesListItemComponent to show each episode in the season
    ' seasons = season_details
    ' episodeItem = each element of the results array

    seasonsArray = []
    seasonCounter = 0
    if seasons <> invalid
        for each season in seasons
            episodeCounter = 0

            print "Fetching season " + seasonCounter.ToStr() + " for series id " + seriesId
            print "Show data from"
            ' TODO NADI: MAKE SURE EPISODEITEM IS THE ACTUAL EPISODE AND NOT THE WHOLE DAMN THING
            ' print GetEpisodesItemData(episodeItem)
            ' print "SEASON ID: " + season._id

            ' getting the episodes array
            jsonEps = season.episodes
            episodes = []
            ' (𖦹~𖦹)?? TODO NADI: why is it that when season.season_number gets mapped to
            ' episodes.seasonNumber, on the EpisodesScreen.brs file, it comes as a string (empty string)
            ' but when it is mapped to episodes.season_number, it comes as the actual season number ????
            ' and same thing happens with episode number tooo Check GetEpisodesItemData function above
            ' HOWWWWWWWWWW T_T
            ' for each episode in jsonEps 
            for each episode in season.episodes
                ' push each episode after mapping the data
                episodeData = GetEpisodesItemData(episode)
                episodeData.titleSeason = season.name
                episodeData.contentType = "episode"
                episodeData.numEpisodes = episodeCounter
                episodes.Push(episodeData)
                episodeCounter++
            end for

            seasonData = {}
            seasonData.titleSeason = season.name ' add season title to the season
            seasonData.title = "Season " + season.season_number.ToStr() ' add season title to the season
            seasonData.season_number = season.season_number ' add season number to the season
            seasonData.air_date = season.air_date ' add air date to the season
            seasonData.children = episodes ' add episodes array to the season
            seasonData.contentType = "section"

            'TODO NADI: ╮(￣ω￣;)╭ push the episodes for each season to the seasons array (here idx is the season number TBD)
            seasonsArray.Push(seasonData)
            seasonCounter++
        end for
    end if
    ' final structure of seasonsArray
    ' seasonsArray = [
    '   {
    '       titleSeason: "Season 1",
    '       season_number: 1,
    '       air_date: "2008-01-20",
    '       children: [ array of episodes ],
    '       contentType: "section"
    '   },
    '   {
    '       titleSeason: "Season 2",
    '       season_number: 2,
    '       air_date: "2009-01-18",
    '       children: [ array of episodes ],
    '       contentType: "section"
    '   }
    ' ]
    ' here we don't have to add an explicit children field to the seasonsArray because
    ' when we set seasonsArray to the children field of the series item in GetSeriesItemData function
    ' it automatically creates a children field for each season in the seasonsArray
    return seasonsArray
end function