var express = require('express');
const geohash = require('ngeohash');
const axios = require('axios');
var cors = require('cors');
const bodyParser = require('body-parser');
const SpotifyWebApi = require('spotify-web-api-node');
var app = express();
app.use(cors());
app.use(bodyParser.json());
const api_key = "<APIKEY>";

const path = require('path');
const exp = require('constants');
const root = path.join(__dirname,'dist');
app.use(express.static(root))

//const { response } = require('express');


app.get('/autocomplete', async function (request, res) {
    var keyword = request.query.keyword;
    console.log(keyword);
    var apiUrl = "https://app.ticketmaster.com/discovery/v2/suggest.json?apikey=<APIKEY>&keyword=" + keyword;
    console.log(apiUrl)
    await axios.get(apiUrl).then(response => {
        //return response.data;
        res.send(response.data);
    });
})

app.get('/all_events', async function (request, res) {
    var keyword = request.query.keyword;
    var segmentId = request.query.segmentId;
    var radius = request.query.radius;
    var latitude = request.query.latitude;
    var longitude = request.query.longitude;
    //    var keyword = querystring.escape("Taylor Swift");
    //    var segmentId = "KZFzniwnSyZfZ7v7nJ";
    //    var radius = 10;
    //    var latitude = 40.7127753;
    //    var longitude = -74.0059728;
    var geoPoint = geohash.encode(latitude, longitude, 7);
    apiUrl = "https://app.ticketmaster.com/discovery/v2/events.json?apikey=" + api_key + "&keyword=" + keyword + "&segmentId=" + segmentId + "&radius=" + radius + "&unit=miles&geoPoint=" + geoPoint;
    console.log(apiUrl);
    await axios.get(apiUrl).then(response => {
        datas = response.data;
        if (!("_embedded" in datas)) {
            res.json({ "error": "No events found" });
        }
        console.log(datas);
        events = datas["_embedded"]["events"];

        event_list = []
        for (let i = 0; i < events.length; i++) {
            event_details = {}

            // 1 - date and time
            if ('dates' in events[i] && 'start' in events[i]['dates']) {
                if ('localDate' in events[i]['dates']['start']) {
                    if ('localTime' in events[i]['dates']['start']) {
                         var dt = events[i]['dates']['start']['localDate'] + "|" + events[i]['dates']['start']['localTime'];
                         event_details.date = dt.slice(0, -3);
                    } else {
                        event_details.date = events[i]['dates']['start']['localDate'];
                    }
                } else {
                    event_details.date = "";
                }
            } else {
                event_details.date = "";
            }

            // 2 - image url
            if ('images' in events[i] && 'url' in events[i]['images'][0])
                event_details.imgurl = events[i]['images'][0]['url'];
            else
                event_details.imgurl = "";

            // 3 - name of the event
            if ('name' in events[i])
                event_details.evename = events[i]['name'];
            else
                event_details.evename = "";

            // 4 - Genre
            if ('classifications' in events[i] && 'segment' in events[i]['classifications'][0] && 'name' in events[i]['classifications'][0]['segment'])
                event_details.genre = events[i]['classifications'][0]['segment']['name'];
            else
                event_details.genre = "";

            // 5 - venue name
            if ('_embedded' in events[i] && 'venues' in events[i]['_embedded'] && 'name' in events[i]['_embedded']['venues'][0])
                event_details.venue = events[i]['_embedded']['venues'][0]['name'];
            else
                event_details.venue = "";

            // 6 - id of event
            if ('id' in events[i])
                event_details.eveId = events[i]['id'];
            else
                event_details.eveId = "";

            event_list.push(event_details);

        }
        console.log("Event list:");
        console.log(event_list);

        if(event_list.length > 1)
        event_list.sort((a, b) => new Date(a.date) - new Date(b.date));

        //return event_list.json();
        //console.log(json(event_list));
        res.json(event_list);
    }).catch(error => {
        console.error(error);
    });
})

app.get('/event_details', async function (request, res) {
    ids = request.query.eveid;
    apiUrl = 'https://app.ticketmaster.com/discovery/v2/events/' + ids + '.json?apikey=' + api_key;
    console.log(apiUrl);
    await axios.get(apiUrl).then(response => {
        events = response.data;
        if (!("_embedded" in events)) {
            return res.json({ "error": "No events found" });
        }

        genre = ""
        g = []
        holder = events["classifications"][0]
        if ("subGenre" in holder)
            g.push(holder["subGenre"]["name"])
        else
            g.push("")
        if ("genre" in holder)
            g.push(holder["genre"]["name"])
        else
            g.push("")
        if ("segment" in holder)
            g.push(holder["segment"]["name"])
        else
            g.push("")
        if ("subType" in holder)
            g.push(holder["subType"]["name"])
        else
            g.push("")
        if ("type" in holder)
            g.push(holder["type"]["name"])
        else
            g.push("")

        for (let i = 0; i < 5; i++) {
            if (g[i] == "" || g[i] == "Undefined" || g[i] == null)
                continue;
            else if (i == 0)
                genre += g[i];
            else if (genre == "")
                genre += g[i];
            else
                genre += "|" + g[i];
        }

        min_price = 0;
        max_price = 0;
        //currency = "";
        if ('priceRanges' in events) {
            price_range = events["priceRanges"];
            if (price_range) {
                min_price = price_range[0].min;
                max_price = price_range[0].max;
                //currency = price_range[0].currency;
            }
        }

        detail = {};
        // Date -  0
        if ('dates' in events && 'start' in events['dates']) {
            if ('localDate' in events['dates']['start']) //&& 'localTime' in events['dates']['start'])
                if(events['dates']['start']['localDate'] != "Undefined" )//&& events['dates']['start']['localTime'] != "Undefined")
                detail.date = events['dates']['start']['localDate'] //+ " " + events['dates']['start']['localTime'];
            else
                detail.date = "";
        } else {
            detail.date = "";
        }

        // Artist - 1
        names = "";
        genreArtst = "";
        if (events["_embedded"]["attractions"] != undefined) {
            val = events["_embedded"]["attractions"]
            console.log(val);
            if (val.length > 1){
                names = val[0]["name"];
                genreArtst = val[0]['classifications'][0]['segment']['name'];
                for (let i = 1; i < val.length; i++){
                    if(val[i]["name"] != "Undefined"){
                        names += " | " + val[i]["name"];
                        //genreArtst += val[0]['classifications'][0]['segment']['name'];
                    }
                }
            }
        }
        //console.log("Names:"+names);
        detail.name = names;
        //detail.genreArtst = genreArtst;

        // Venue - 2
        if ("_embedded" in events && "venues" in events["_embedded"] && 'name' in events["_embedded"]["venues"][0] && events["_embedded"]["venues"][0]["name"] != "Undefined")
            detail.venue = events["_embedded"]["venues"][0]["name"];
        else
            detail.venue = "";

        //genre - 3
        detail.genre = genre;

        // price range - 4
        amt = ""
        if (min_price != 0) {
            amt += min_price.toString()
            if (max_price != 0)
                amt += "-" + max_price.toString() //+ " " + currency
            else
                amt += " " + currency
        } else if (max_price != 0)
            amt += max_price.toString() //+ " " + currency
        detail.price = amt;

        // Ticket Status - 5
        if ('dates' in events && 'status' in events["dates"] && 'code' in events["dates"]["status"] && events["dates"]["status"]["code"] != "Undefined")
            detail.status = events["dates"]["status"]["code"];
        else
            detail.status = "";

        // Buy Ticket At - 6
        if ('url' in events && events["url"] != "Undefined")
            detail.buyurl = events["url"];
        else
            detail.buyurl = "";

        // Seat Map - 7
        if ('seatmap' in events && 'staticUrl' in events["seatmap"] && events["seatmap"]["staticUrl"] != "Undefined")
            detail.seatmap = events["seatmap"]["staticUrl"];
        else
            detail.seatmap = "";

        // Event Name - 8
        if ('name' in events && events['name'] != "Undefined")
            detail.evename = events['name'];
        else
            detail.evename = "";

        // Event id - 9
        detail.eveId = events['id'];

        detail.isFavorite = "false"
        console.log("Event detailssssss");
        console.log(detail);
        res.json(detail);
        //return jsonify(detail)
    }).catch(error => {
        console.error(error);
    });
})

const spotifyApi = new SpotifyWebApi({
    clientId: '<client id>',
    clientSecret: '<client secret>',
});
  
async function getArtistDetails(artistName){
    console.log("Inside getArtistDetails");
    const data1 = await spotifyApi.clientCredentialsGrant();
    spotifyApi.setAccessToken(data1.body.access_token);
    const data = await spotifyApi.searchArtists(artistName);
    const refinedData = data.body.artists.items;
    console.log(refinedData);
    resp = {};
    if((refinedData[0].name.toLowerCase()).localeCompare(artistName.toLowerCase())){
        resp.name = refinedData[0].name;
        resp.foll = refinedData[0].followers.total;
        resp.popularity = refinedData[0].popularity;
        resp.spoturl = refinedData[0].external_urls.spotify;
        resp.img = refinedData[0].images[2].url;
        resp.id = refinedData[0].id;
    }
    console.log(resp);
    return resp;
}

async function getArtistAlbums(artistId) {
    console.log("Inside getArtistAlbums");
    const data1 = await spotifyApi.clientCredentialsGrant();
    spotifyApi.setAccessToken(data1.body.access_token);
    const data = await spotifyApi.getArtistAlbums(artistId, { limit: 3 });
    const refinedData = data.body.items;
    albumsArray = []
    for(let i = 0; i< refinedData.length; i++){
        albumsArray.push(refinedData[i].images[0].url);
    }
    console.log(albumsArray);
    return albumsArray;
}


app.get('/spotify_details', async function (request, res) {
    const receivedString = request.query.artistName;
    const receivedArray = receivedString.split("|");
    console.log("array: "+receivedArray);
    let data1, albumData = [];
    for (let artistName of receivedArray) {
        //console.log(artistName);
        data1 = await getArtistDetails(artistName);
        let data2 = await getArtistAlbums(data1.id);
        data1.albums = data2;
        data1.isActive=false;
        albumData.push(data1);
    }
    albumData[0].isActive = true;
    console.log(albumData);
    res.send(albumData);
});

app.get('/venue_details', async function(request, res){
    keyword = request.query.keyword;
    apiUrl = "https://app.ticketmaster.com/discovery/v2/venues?apikey="+api_key+"&keyword="+keyword;
    console.log(apiUrl);
    await axios.get(apiUrl).then(response => {
        events = response.data;

    if (!("_embedded" in events)) {
        res.json({ "error": "No events found" });
    }
    else{
    	events = events["_embedded"]["venues"][0]
    }
    details = {}

    //  Name
    if(!('name' in events))
        details.name=""
    else
        details.name=events['name']

    //  address
    if(!('address' in events) || (!('line1' in events['address'])) || !('city' in events) || !('state' in events) || !('name' in events['city']) || !('name' in events['state']))
        details.address=""
    else
        details.address=events['address']['line1'] + ", " + events['city']['name']+", "+events['state']['name']
    
    //  city
    // if(!('city' in events) || !('state' in events) || !('name' in events['city']) || !('name' in events['state']))
    //     details.city=""
    // else
    //     details.city=events['city']['name']+", "+events['state']['name']
    
    //  phone no
    if(!('boxOfficeInfo' in events) || !('phoneNumberDetail' in events['boxOfficeInfo']))
        details.phno = "";
    else
        details.phno=events['boxOfficeInfo']['phoneNumberDetail'];
    
    //  open hours
    if(!('boxOfficeInfo' in events) || !('openHoursDetail' in events['boxOfficeInfo']))
        details.openhrs=""
    else
        details.openhrs=events['boxOfficeInfo']['openHoursDetail']

    //  general rule
    if(!('generalInfo' in events) || !('generalRule' in events['generalInfo']))
        details.genrule=""
    else
        details.genrule=events['generalInfo']['generalRule']

    //  child rule
    if(!('generalInfo' in events) || !('childRule' in events['generalInfo']))
        details.childrule=""
    else
        details.childrule=events['generalInfo']['childRule']

    // address for gmap
    addgmap = "";
    if(!('address' in events) || !('line1' in events['address']))
        addgmap += ""
    else
        addgmap +=events['address']['line1']
    
    // city
    if(!('city' in events) || !('state' in events)|| !('name' in events['city']) || !('stateCode' in events['state']))
        addgmap+=""
    else
    addgmap+=","+events['city']['name']+","+events['state']['stateCode']
    
    // postal code
    if(!('postalCode' in events))
        addgmap+=""
    else
        addgmap+=","+events['postalCode']
    details.addgmap = addgmap;

    console.log(details);
    res.json(details);
    });
})

var server = app.listen(8081, function () {
    var host = server.address().address
    var port = server.address().port

    console.log("Example app listening at http//%s%s", host, port)
})

// app.get('*', function(req, res) {
//     res.sendFile("index.html",{root});
// })
// app.listen(process.env.PORT || port,() => console.log(`server listening on port ${port}`) );
