//
//  EventView.swift
//  Event Finder
//
//  Created by Somya Shastri on 4/30/23.
//

import SwiftUI
import Kingfisher
import Foundation

struct EventView: View{
    @State private var fav_events = UserDefaults.standard.array(forKey: "fav_events") as? [[String:String]] ?? []
    @State var check_fav = false
    @State private var data_btn = "Save Event"
    @State private var change_clr = Color.blue
    @State private var showToast = false
    
    var eventData: [String:String]
    var body: some View{
        
        VStack {
            Text(eventData["evename"] ?? "")
                .font(.title)
                .bold()
            HStack{
                Text("Date")
                    .bold()
                Spacer()
                Text("Artist | Team")
                    .bold()
            }.padding(.top, 5)
            HStack{
                Text(eventData["date"] ?? "")
                Spacer()
                Text(eventData["name"] ?? "")
            }.foregroundColor(.gray)
            HStack{
                Text("Venue")
                    .bold()
                Spacer()
                Text("Genre")
                    .bold()
            }.padding(.top, 5)
            HStack{
                Text(eventData["venue"] ?? "")
                Spacer()
                Text(eventData["genre"] ?? "")
            }.foregroundColor(.gray)
            HStack{
                Text("Price Range")
                    .bold()
                Spacer()
                Text("Ticket Status")
                    .bold()
            }.padding(.top, 5)
            HStack{
                Text(eventData["price"] ?? "")
                Spacer()
                Text(eventData["status"]?.capitalized ?? "")
                    .frame(width: 100)
                    .background(getBackgroundColor())
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
                    .padding(3)
                
            }.foregroundColor(.gray)
            
            Button(action:{
                var fav_events = UserDefaults.standard.array(forKey: "fav_events") as? [[String:String]] ?? []
                
                let info_event:[String: String] = [
                    "id":eventData["eveId"]!,
                    "name":eventData["evename"]!,
                    "date": eventData["date"]!,
                    "genre": eventData["genre"]!,
                    "venue":eventData["venue"]!
                ]
                
                if check_fav{
                    fav_events.removeAll{$0["id"] == eventData["eveId"]!}
                    check_fav = false
                    withAnimation {
                        showToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    }
                    
                    self.button_app()
                } else {
                    fav_events.append(info_event)
                    check_fav = true
                    withAnimation {
                        showToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    }
                    self.button_app()
                }
                UserDefaults.standard.set(fav_events, forKey: "fav_events")
            }){
                Text(data_btn)
                    .frame(maxWidth:100)
                    .padding()
                    .foregroundColor(.white)
                    .background(change_clr)
                    .cornerRadius(15)
                    .font(.headline)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showToast = false
                    }
                }
            }
            
            if let seatmapURL = eventData["seatmap"], let url = URL(string: seatmapURL) {
                KFImage(url)
                    .resizable()
                    .frame(width: 230, height: 230)
            }
            
            if let buyURL = eventData["buyurl"], let url = URL(string: buyURL) {
                HStack{
                    Text("Buy Ticket At: ")
                        .bold()
                    Link("Ticketmaster", destination: url)
                }
                
                HStack{
                    Text("Share on: ")
                        .bold()
                    Link(destination: URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(buyURL)")!) {
                        Image("facebook_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    
                    if let eventName = eventData["evename"] {
                        var encodedEventName = eventName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                        let tweetURL = URL(string: "https://twitter.com/intent/tweet?text=Check%20\(encodedEventName)%20on%20Ticketmaster&url=\(buyURL)")
                        //UIApplication.shared.open(url)
                        //let tweetURL = "https://twitter.com/intent/tweet?text=\(eventName)&url=\(buyURL)"
                        
                        Link(destination: tweetURL!) {
                            Image("twitter_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                    }
                }
            }
        }
        .toast(isShowing: $showToast, text: check_fav ? Text("Added to favorites"): Text("Remove event favorites"))
        .padding(.horizontal, 15.0)
    }
    
    
    private func getBackgroundColor() -> Color {
        switch eventData["status"] {
        case "onsale":
            return Color.green
        case "offsale":
            return Color.red
        case "cancelled":
            return Color.black
        case "postponed":
            return Color.orange
        case "rescheduled":
            return Color.orange
        default:
            return Color.gray
        }
    }

    func button_app(){
        if check_fav{
            self.change_clr = Color.red
            self.data_btn = "Remove Favorite"
            
        } else {
            self.change_clr = Color.blue
            self.data_btn = "Save event"
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(eventData: [String:String]())
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
}

struct Toast<Presenting>: View where Presenting: View {

    // The binding that decides the appropriate drawing in the body.
    @Binding var isShowing: Bool
    // The view that will be "presenting" this toast
    let presenting: () -> Presenting
    // The text to show
    let text: Text

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.presenting()
                    .blur(radius: self.isShowing ? 1 : 0)

                VStack {
                    self.text
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
                
            }

        }

    }

}
