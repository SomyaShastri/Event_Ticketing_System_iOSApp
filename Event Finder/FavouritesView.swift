//
//  FavouritesView.swift
//  Event Finder
//
//  Created by Somya Shastri on 5/3/23.
//

import SwiftUI
import Foundation

struct FavouritesView: View {
    @State private var fav_events = [[String: String]]()
    var body: some View {
        NavigationView{
            if fav_events.isEmpty{
                Text("No favorites found")
                    .foregroundColor(.red)
                    .font(.system(size: 15))
            } else {
                List{
                    ForEach(fav_events, id: \.self) { event in
                        HStack{
                            Text(event["date"] ?? "").font(.system(size: 12))
                            Text(event["name"] ?? "").font(.system(size: 12)).lineLimit(2)
                            Text(event["genre"] ?? "").font(.system(size: 12))
                            Text(event["venue"] ?? "").font(.system(size: 12))
                        }
                    }
                    .onDelete{ indexSet in
                        fav_events.remove(atOffsets: indexSet)
                        UserDefaults.standard.set(fav_events,forKey: "fav_events")
                    }
                }
            }
        }.navigationTitle("Favorites")
            .onAppear{
                if let fav_events = UserDefaults.standard.array(forKey: "fav_events") as? [[String: String]]{
                    self.fav_events = fav_events
                }
            }
    }
}
