# SceneGraph master sample

This channel (app for Roku devices) demonstrates how to use SceneGraph to create a simple user interface with multiple screens and navigation. It includes examples of how to create a main menu, display content in a grid, and navigate between screens using the data and content from TMDB API. It's a starter template for building your own Roku channels using SceneGraph and increment with features like displaying movie/show details, grids of items, and more.

## Installation

To run the channel, follow these steps:

1. Download and then extract the channel.

2. In the extracted folder, expand the folder containing the channel you want to run and then compress the contents in the expanded folder to a ZIP file.

3. Follow the steps in [Loading and Running Your Application](https://developer.roku.com/en-gb/docs/developer-program/getting-started/developer-setup.md#step-1-set-up-your-roku-device-to-enable-developer-settings) to enable developer mode on your device and sideload the ZIP file containing the sample onto it.

4. To make it easier, there is a script called `deploy_roku.sh` in the root of the project that you can use to deploy the channel to your Roku device. Just update the `ROKU_IP` and `ROKU_PASS` variables in the script and run it. Run it in your terminal with `./deploy_roku.sh`.

## TMDB API Integration

### Creating a TMDB API Key

1. Go to [The Movie Database (TMDB) website](https://www.themoviedb.org/).
2. Sign up for a free account or log in.
3. Navigate to your account settings and select "API".
4. Click "Create" to generate a new API key.
5. Copy your API key for use in your Roku channel.

### Fetching Data in BrightScript

To fetch data from the TMDB API in BrightScript, use the `roUrlTransfer` component. Here is an example:

```brightscript
// Example: Fetching popular movies from the JSON that I am hosting, using the content from TMDB (Movies, TV Shows and episodes from tv shows)
BASE_URL = "https://joaotargino.pythonanywhere.com"

xfer = CreateObject("roUrlTransfer")
xfer.SetUrl(url)
response = xfer.GetToString()

if response <> invalid
    data = ParseJson(response)
    ' Now you can use "data" as an AA with the results
    ? data
else
    ? "Failed to fetch data from API"
end if
```

You may need to set certificates for HTTPS requests:
xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")

## Deployment

### Local Deployment

Instructions:

1. Save this as deploy_roku.sh in your project root.
2. Update the ROKU_IP and ROKU_PASS variables.
3. Run: chmod +x deploy_roku.sh
4. Execute: ./deploy_roku.sh

## Exercise Tasks

Search for "EXERCISE TASK" comments in the codebase to find where to implement the tasks.

1. Fork the branch
2. Implement the TMDB API
3. Create a menu to display Movies / TV Shows / Other (I've also provided an endpoint for Trending and Now Playing)
4. Implement the Detail Screen
5. 1. The Detail screen must have: Movie Details, Poster, Cast, IMDB Rating, and More! (again, creativity)

Optional

1. Create a Favorite Item in the Menu with locally selected favorite movies and tv shows
2. Create a search bar

### Fetching Data from TMDB API in BrightScript

To fetch data from the TMDB API in BrightScript, use the `roUrlTransfer` component. Here is an example:

```brightscript
// Example: Fetching popular movies from TMDB
apiKey = "YOUR_TMDB_API_KEY"
url = "https://api.themoviedb.org/3/movie/popular?api_key=" + apiKey

xfer = CreateObject("roUrlTransfer")
xfer.SetUrl(url)
response = xfer.GetToString()

if response <> invalid
    data = ParseJson(response)
    ' Now you can use "data" as an AA with the results
    ? data
else
    ? "Failed to fetch data from TMDB"
end if
```

You may need to set certificates for HTTPS requests:
xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")

## Debug

To debug your Roku application, you can use Telnet to connect to your Roku device. Here are the steps:

1. Find the IP address of your Roku device. You can find this in the settings menu under "Network" > "About".
2. Download and install telnet (brew install telnet) if you don't have it already.

```
telnet <ROKU_IP_ADDRESS> 8080 // or 8085
```
