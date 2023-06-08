//
//  ContentView.swift
//  Event Finder
//
//  Created by Somya Shastri on 4/13/23.
//

import SwiftUI
import Alamofire
import Kingfisher

struct ContentView: View {
    @State private var autoDetectLocation = false
    @State private var keyword = ""
    @State private var category = 0
    @State private var location = ""
    @State private var distance = "10"
    @State private var showList: Bool = false
    @State private var eventList: [[String: String]] = []
    @State private var showProgressResult: Bool = false
    @State private var options: [String] = []
    @State private var showingOptions = false
    @State var showOptionsProgress = true
    
    var body: some View {
        VStack {
            NavigationView{
                HStack{
                    Form {
                        LabeledContent("Keyword:") {
                            TextField("Required", text: $keyword)
                                .foregroundColor(.black)
                                .onSubmit{
                                    fetchOptions(keywords: keyword)
                                    showingOptions = true
                                    showOptionsProgress = true
                                }
                                .sheet(isPresented: $showingOptions, onDismiss: {
                                    showOptionsProgress = false
                                }) {
                                    if (showOptionsProgress){
                                        VStack(alignment: .center, spacing: 5){
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                            Text("Loading...")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                    } else {
                                        VStack {
                                            Text("Suggestions").font(.title).foregroundColor(.black)
                                            //                                        if(options.count == 0){
                                            //                                            Text("No results found")
                                            //                                        } else {
                                            
                                            List(options, id: \.self) { option in
                                                Text(option)
                                                    .foregroundColor(.black)
                                                    .onTapGesture {
                                                        keyword = option
                                                        showingOptions = false
                                                    }
                                            }
                                            //}
                                        }
                                    }
                                }
                        }
                        .foregroundColor(.gray)
                        
                        LabeledContent("Distance:") {
                            TextField("", text: $distance)//, formatter: NumberFormatter())
                                .foregroundColor(.black)
                        }
                        .foregroundColor(.gray)
                        Picker(selection: $category, label: Text("Category:")) {
                            Text("Default").tag(0).foregroundColor(.black)
                            Text("Music").tag(1).foregroundColor(.black)
                            Text("Sports").tag(2).foregroundColor(.black)
                            Text("Arts & Theatre").tag(3).foregroundColor(.black)
                            Text("Film").tag(4).foregroundColor(.black)
                            Text("Miscellaneous").tag(5).foregroundColor(.black)
                        }
                        .pickerStyle(.menu)
                        .foregroundColor(.gray)
                        
                        if(autoDetectLocation == false){
                            LabeledContent("Location:") {
                                TextField("Required", text: $location)
                                    .foregroundColor(.black)
                            }
                            .foregroundColor(.gray)
                        }
                        Toggle(isOn: $autoDetectLocation) {
                            Text("Auto-detect my location")
                                .foregroundColor(.gray)
                        }
                        
                        HStack(alignment: .center){
                            Button("Submit") {
                                showList = false
                            }
                            .onTapGesture(perform: {
                                //showList = true
                                showList = false
                                showProgressResult = true
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                    showProgressResult = false
//                                }
                                api1(category: category, keyword: keyword, distance: distance, location: location, autoDetectLocation: autoDetectLocation, completion:{eventsData in
                                    eventList = eventsData
                                    //showList = true
                                })
                            })
                            .padding(.all, 15.0)
                            .frame(width: 100)
                            .background((!keyword.isEmpty && (autoDetectLocation || !location.isEmpty)) ? Color.red : Color.gray)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                            Spacer()
                                .frame(width: 16.0)
                            Button("Clear") {
                                showList = false
                                keyword=""
                                distance="10"
                                category=0
                                location=""
                                autoDetectLocation=false
                            }
                            .padding(.all, 15.0)
                            .frame(width: 100)
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                            
                        }.padding(.vertical)
                            .frame(maxWidth:.infinity,alignment:.center)
                        
                        if(showProgressResult){
                            Section(header:Text("")){
                                Text("Results")
                                    .font(.title)
                                VStack(alignment: .center, spacing: 5){
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Text("Please wait...")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                    Spacer()
                                }
                                .id(UUID())
                                .frame(maxWidth: .infinity)
                                .onAppear{
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        showProgressResult = false
                                        showList = true
                                    }
                                }
                            }
                        }
                        
                        if showList {
                            Section(header:Text("")){
                                Text("Results")
                                    .font(.title)
                                

                                if eventList.count == 0 {
                                    Text("No results found")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.red)
                                        .multilineTextAlignment(.center)
                                    
                                } else {
                                    List($eventList, id: \.self) { item in
                                        NavigationLink(destination: ResultView(eveid: item["eveId"].wrappedValue!)){
                                            HStack{
                                                Text(item["date"].wrappedValue ?? "")
                                                    .foregroundColor(.gray)
                                                KFImage(URL(string: item["imgurl"].wrappedValue ?? ""))
                                                    .resizable()
                                                    .frame(width: 50, height:50)
                                                    .cornerRadius(10)
                                                Text(item["evename"].wrappedValue ?? "")
                                                    .bold()
                                                    .lineLimit(3)
                                                Text(item["venue"].wrappedValue  ?? "")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.navigationTitle("Event Search")
                    .navigationBarItems(trailing: NavigationLink(destination: FavouritesView()){
                        Image(systemName: "heart.circle")
                    })
            }
        }
    }
    
    func fetchOptions(keywords: String) {
       // let apiUrl = "https://eco-byte-377504.wl.r.appspot.com/autocomplete?keyword=" + keywords.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let apiUrl = "http://127.0.0.1:8081/autocomplete?keyword=" + keywords.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(apiUrl)
        AF.request(apiUrl, method: .get)
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    if let json = data as? [String: Any], let embedded = json["_embedded"] as? [String: Any], let data1 = embedded["attractions"] as? [[String: Any]] {
                        var lists: [String] = []
                        for d in data1 {
                            if let name = d["name"] as? String {
                                lists.append(name)
                            }
                        }
                        self.options = lists
                        sleep(1)
                        showOptionsProgress = false
                        print(options)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    showOptionsProgress = false
                }
            }
    }
}

struct OptionsResponse: Decodable {
    let options: [String]
}

func api1(category:Int, keyword: String, distance: String, location:String, autoDetectLocation:Bool, completion: @escaping ([[String: String]]) -> Void)  {
    var segmentId = ""
    switch category {
    case 1:
        segmentId = "KZFzniwnSyZfZ7v7nJ"
        break
    case 2:
        segmentId = "KZFzniwnSyZfZ7v7nE"
        break
    case 3:
        segmentId = "KZFzniwnSyZfZ7v7na"
        break
    case 4:
        segmentId = "KZFzniwnSyZfZ7v7nn"
        break
    case 5:
        segmentId = "KZFzniwnSyZfZ7v7n1"
        break
    default:
        segmentId = ""
    }
    
    //let hostname: String = "https://eco-byte-377504.wl.r.appspot.com/all_events?keyword="
    let hostname: String = "http://127.0.0.1:8081/all_events?keyword="
    let keyword2: String = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let apiPath: String = keyword2 + "&radius=" + distance + "&segmentId=" + segmentId
    if autoDetectLocation {
        getIpInfo { locString in
            print(locString)
            let locArray = locString.components(separatedBy: ",")
            let locationPath: String = "&latitude=" + locArray[0] + "&longitude=" + locArray[1]
            let apiUrl = hostname + apiPath + locationPath
            meth1(apiUrl: apiUrl, completion:{ eventsData in
                print(eventsData)
                completion(eventsData)
            })
        }
    } else {
        getLocation(locationTextBox: location, completion: {locString in
            print(locString)
            let locArray = locString.components(separatedBy: ",")
            let locationPath: String = "&latitude=" + locArray[0] + "&longitude=" + locArray[1]
            let apiUrl = hostname + apiPath + locationPath
            meth1(apiUrl: apiUrl, completion: { eventsData in
                print("count:" + String(eventsData.count))
                completion(eventsData)
            })
        })
    }
    
}

func meth1(apiUrl: String, completion: @escaping ([[String: String]]) -> Void){
    print(apiUrl)
    var eventsData: [[String: String]] = []
    AF.request(apiUrl, method: .get)
        .responseJSON {
            response in
            switch response.result {
            case .success(let data):
                eventsData = data as? [[String:String]] ?? []
                print(eventsData.count)
            case .failure(let error):
                print(error.localizedDescription)
            }
            completion(eventsData)
        }
}

func getIpInfo(completion: @escaping (String) -> Void) {
    let apiUrl = "https://ipinfo.io/?token=<token>"
    AF.request(apiUrl, method: .get).responseJSON { response in
        var locString = ""
        switch response.result {
        case .success(let json):
            if let jsonDictionary = json as? [String: Any],
               let loc = jsonDictionary["loc"] as? String {
                locString = loc
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
        completion(locString)
    }
}

func  getLocation(locationTextBox: String, completion: @escaping (String) -> Void) {
    let apiKey = "<key here>";
    var apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?address="
    apiUrl += locationTextBox.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    apiUrl += "&key=" + apiKey;
    
    AF.request(apiUrl, method: .get).responseJSON { response in
        var locString = ""
        switch response.result {
        case .success(let json):
            if let jsonDictionary = json as? [String: Any],
               let results = jsonDictionary["results"] as? [[String: Any]],
               let geometry = results[0]["geometry"] as? [String: Any],
               let loc = geometry["location"] as? [String: Double] {
                locString = "\(loc["lat"]!),\(loc["lng"]!)"
                print(locString)
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
        completion(locString)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
