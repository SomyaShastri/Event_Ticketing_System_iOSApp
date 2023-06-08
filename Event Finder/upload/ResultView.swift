//
//  ResultView.swift
//  Event Finder
//
//  Created by Somya Shastri on 4/30/23.
//

import Foundation
import SwiftUI
import Alamofire
import MapKit

struct ResultView: View {
    var eveid: String
    @State var eventData = [String:String]()
    @State var artistData = [Artist]()
    @State var venueData = [String:String]()
    @State var locations = CLLocationCoordinate2D()
    @State var isLoading = true
    
    var body: some View {
        if isLoading {
            ProgressView()
            Text("Please wait...").foregroundColor(.gray)
                .onAppear {
                    eventsCall(eveid: eveid) { eventData in
                        self.eventData = eventData
                        artistCall(eventData: eventData) { spotifyData in
                            print(spotifyData)
                            self.artistData = spotifyData
                            venueCall(locName: eventData["venue"]!) { venueData in
                                self.venueData = venueData
                                getLocationCall(add: venueData["addgmap"]!){ loc in
                                    locations = loc
                                    isLoading = false
                                }
                            }
                        }
                    }
                    
//                    let exist_eve_check = fav_events.contains{ event in
//                        event["id"] == eveid
//                    }
//                    check_fav = exist_eve_check
//                    self.button_app()
                }
        } else {
            TabView {
                EventView(eventData: eventData)
                    .tabItem {
                        Label("Events", systemImage: "text.bubble.fill")
                    }
                ArtistView(artData: artistData, eveName: eventData["evename"] ?? "")
                    .tabItem {
                        Label("Artist/Team", systemImage: "guitars.fill")
                    }
                VenueView(venueData: venueData, eveName: eventData["evename"] ?? "", loctn: locations)
                    .tabItem {
                        Label("Venue", systemImage: "location.fill")
                    }
            }
        }
    }
}



func eventsCall(eveid: String, completion: @escaping ([String:String]) -> Void) {
    var eventData = [String: String]()
    let apiUrl: String = "https://eco-byte-377504.wl.r.appspot.com/event_details?eveid=" + eveid;
    print(apiUrl)
    
    AF.request(apiUrl, method: .get).responseJSON{ response in
        if response.response?.statusCode == 200 {
            if let data = response.data {
                do {
                    eventData = try (JSONSerialization.jsonObject(with: data, options: []) as? [String: String] ?? [:])
                    print(eventData)
                    completion(eventData)
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
        } else {
            print("Error making request")
        }
    }
}

func artistCall(eventData: [String:String], completion: @escaping ([Artist]) -> Void) {
    let artistname: String = eventData["name"]!
    let categ: String = eventData["genre"]!
    print(artistname)
    var spotifyData = [[String:Any]]()
    print(categ)
    if (categ.contains("Music")) {
        let apiUrl2 = "https://eco-byte-377504.wl.r.appspot.com/spotify_details?artistName=" + artistname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(apiUrl2);
        AF.request(apiUrl2, method: .get).responseJSON{ response2 in
            if response2.response?.statusCode == 200 {
                if let data = response2.data {
                    do {
                        var spotData: [Artist] = []
                        spotifyData = try (JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] ?? [])
                        let len = spotifyData.count
                        for i in 0...len-1{
                            let newArt = Artist(img:spotifyData[i]["img"] as! String, name: spotifyData[i]["name"] as! String, foll:spotifyData[i]["foll"] as! Int, spoturl: spotifyData[i]["spoturl"] as! String, popularity: spotifyData[i]["popularity"] as! Int, albums: spotifyData[i]["albums"] as! [String])
                            spotData.append(newArt)
                        }
                        print(spotifyData)
                        print(spotData)
                        completion(spotData)
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    else {
        print("returning empty")
        completion([])
    }
}

func venueCall(locName: String, completion: @escaping ([String:String]) -> Void) {
    let apiUrl3 = "https://eco-byte-377504.wl.r.appspot.com/venue_details?keyword=" + locName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!;
    AF.request(apiUrl3, method: .get).responseJSON{ response in
        if response.response?.statusCode == 200 {
            if let data = response.data {
                do {
                    let venueData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] ?? [:]
                    print(venueData)
                    completion(venueData)
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
        }
    }
}

func getLocationCall(add: String, completion: @escaping (CLLocationCoordinate2D) -> Void) {
    let apiKey = "AIzaSyDLee5uk4GKhBcLN8J9kD_AjMY_Kir7RBs"
    let apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?address=" + add.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! + "&key=" + apiKey
    print(apiUrl)
    AF.request(apiUrl, method: .get).responseJSON{ response in
        if response.response?.statusCode == 200 {
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    if let results = json["results"] as? [[String: Any]], let location = results.first?["geometry"] as? [String: Any], let coordinates = location["location"] as? [String: Double] {
                        let lat = coordinates["lat"] ?? 0.0
                        let lng = coordinates["lng"] ?? 0.0
                        print(String(lat))
                        print(String(lng))
                        completion(CLLocationCoordinate2D(latitude: lat, longitude: lng))
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
        } else {
            print("Error making request")
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(eveid: "")
    }
}
