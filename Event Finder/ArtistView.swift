//
//  ArtistView.swift
//  Event Finder
//
//  Created by Somya Shastri on 4/30/23.
//

import SwiftUI
import Kingfisher

struct Artist: Hashable {
    var img: String
    var name: String
    var foll: Int
    var spoturl: String
    var popularity: Int
    var albums: [String]
}

struct ArtistView: View {
    var artData: [Artist]
    var eveName: String
    
    var body: some View {
        if(artData.count == 0 ){
            VStack {
                Spacer()
                Text("No music related artist details to show")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.all)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
        } else{
        ScrollView{
                ForEach(artData, id: \.self) { datum in
                    VStack(alignment: .leading){
                        HStack{
                            KFImage(URL(string: datum.img)!)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                            VStack{
                                Text(datum.name).font(.system(size: 23))
                                HStack{
                                    Text(followers(foll: datum.foll)).bold()
                                    Text("Followers").font(.system(size: 14))
                                }
                                .padding(.top, 5)
                                .bold()
                                HStack{
                                    Link(destination: URL(string: datum.spoturl)!){
                                        Image("spotify_logo")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                    Text("Spotify")
                                        .foregroundColor(.green)
                                }
                            }
                            VStack{
                                Text("Popularity")
                                ZStack{
                                    Circle()
                                        .stroke(Color.orange.opacity(0.3),
                                                style: StrokeStyle(lineWidth:14))
                                        .frame(width: 50, height: 50)
                                    Circle()
                                        .trim(from: 0, to: Double(datum.popularity)/100)
                                        .stroke(Color.orange,
                                                style: StrokeStyle(lineWidth:14))
                                        .rotationEffect(.init(degrees: -90))
                                        .frame(width: 50, height: 50)
                                    
                                    Text(String(datum.popularity))
                                        .foregroundColor(Color.white)
                                    
                                }
                                .padding(20)
                            }
                        }
                        Text("Popular Albums").font(.system(size: 20)).bold()
                        HStack{
                            KFImage(URL(string: datum.albums[0])!)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .padding(10)
                            KFImage(URL(string: datum.albums[1])!)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .padding(10)
                            KFImage(URL(string: datum.albums[2])!)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .padding(10)
                        }
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
                .padding(.vertical, 18)
            }.padding(.top, 5.0)
            }
        
    }
}

func followers(foll: Int) -> String{
    if(foll > 1000000) {
        return String(foll/1000000) + "M"
    } else if( foll > 1000){
        return String(foll/1000) + "K"
    }
    else {
        return String(foll)
    }
}

struct ArtistView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistView(artData: [Artist](), eveName: "")
    }
}
