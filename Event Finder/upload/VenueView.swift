//
//  VenueView.swift
//  Event Finder
//
//  Created by Somya Shastri on 4/30/23.
//

import SwiftUI
import MapKit
import Alamofire

struct VenueView: View {
    var venueData: [String:String]
    var eveName: String
    var loctn: CLLocationCoordinate2D
    @State private var showingSheet = false
    @State private var location = CLLocationCoordinate2D()
    var body: some View{
        
        VStack(alignment: .center){
            Text(eveName).font(.title)
            if(venueData["name"] != nil) {
                Text("Name")
                    .bold()
                    .padding(.top, 5)
                Text(venueData["name"] ?? "").foregroundColor(.gray)
            }
            
            if(venueData["address"] != nil) {
                Text("Address").bold().padding(.top, 5)
                Text(venueData["address"] ?? "").foregroundColor(.gray)
            }
            
            if(venueData["phno"] != nil) {
                Text("Phone Number").bold().padding(.top, 5)
                Text(venueData["phno"] ?? "").foregroundColor(.gray)
            }
            
            if(venueData["openhrs"] != nil) {
                Text("Open Hours").bold().padding(.top, 5)
                ScrollView{
                    Text(venueData["openhrs"] ?? "").foregroundColor(.gray)
                }.frame(height: 70)
            }
            
            if(venueData["genrule"] != nil) {
                Text("General Rule").bold().padding(.top, 5)
                ScrollView{
                    Text(venueData["genrule"] ?? "").foregroundColor(.gray)
                }.frame(height: 70)
            }
            
            if(venueData["childrule"] != nil) {
                Text("Child rule").bold().padding(.top, 5)
                ScrollView{
                    Text(venueData["childrule"] ?? "").foregroundColor(.gray)
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 70, alignment: .center)
            
            }
            
            if venueData["addgmap"] != nil {
                Button("Show venue on maps")  {
                    showingSheet = true
                }
                .sheet(isPresented: $showingSheet, content: {
                    MapViewSheet(location: loctn)
                        .padding(10)
                })
                .padding(.all, 15.0)
                .background(Color.red)
                .foregroundColor(Color.white)
                .cornerRadius(10)
            }
        }
        .padding(.horizontal, 10)
    }
}

struct VenueView_Previews: PreviewProvider {
    static var previews: some View {
        VenueView(venueData: [String:String](), eveName: "", loctn: CLLocationCoordinate2D())
    }
}

struct MapViewSheet: View {
    let location: CLLocationCoordinate2D
    
    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))), annotationItems: [LocationAnnotation(coordinate: location)]) { annotation in
            MapMarker(coordinate: annotation.coordinate, tint: .red)
        }
    }
}

struct LocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
