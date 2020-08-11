//
//  LocationView.swift
//  TrySomethingNew
//
//  Created by Jared on 7/7/20.
//  Copyright © 2020 Archetapp. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit
import Pages

struct LocationView : View {
    @Environment(\.colorScheme) var colorScheme
    var currentItem : LocationIdentifiable
    var body : some View {
        VStack {
            VStack {
                VStack {
                    LocationViewCell(currentItem: currentItem)
                    Spacer()
                Button(action: self.goToLocation, label: {
                    Text("Check It Out").frame(width: 250, height: 50, alignment: .center).foregroundColor(self.colorScheme == .dark ? Color(.black) : Color.white).background(Color.blue).cornerRadius(10).shadow(radius: 5)
                })
                }.padding(20)
            }.frame(height: 450, alignment: .center).background(self.colorScheme == .dark ? Color(red: 0.9, green: 0.9, blue: 0.9) : Color(red: 0.2, green: 0.2, blue: 0.2)).cornerRadius(10).shadow(color: self.colorScheme == .dark ? .blue : .gray, radius: 5)
            HStack(alignment: .center, spacing: 0) {
                Image("yelp").resizable().frame(width: 60, height: 30, alignment: .center).aspectRatio(contentMode: .fit)
            }.padding(.top, 20)
        }
    }
    
    func goToLocation() {
        openMapForPlace()
    }
    
    func openMapForPlace() {

        let latitude:CLLocationDegrees =  currentItem.locationLatitude
        let longitude:CLLocationDegrees =  currentItem.locationLongitude

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(currentItem.locationName)"
        mapItem.openInMaps(launchOptions: options)

    }
}

struct LocationViewCell : View {
    var currentItem : LocationIdentifiable
    @Environment(\.imageCache) var cache : ImageCache
    @Environment(\.colorScheme) var colorScheme
    
    @State var currentPage : Int = 0
    var body : some View {
        VStack {
            HStack {
                if currentItem.locationImage != "" {
                    AsyncImage(url: URL(string: currentItem.locationImage)!, cache: self.cache, placeholder: Color(red: 0.9, green: 0.9, blue: 0.9), configuration: {$0.resizable()}).aspectRatio(contentMode: .fill).frame(width: 100, height: 100, alignment: .center).cornerRadius(5).clipped()
                }
                VStack(alignment: .leading) {
                    Text(currentItem.locationName).bold().font(.headline).foregroundColor(self.colorScheme == .dark ? Color(.black) : Color.white)
                    Text(currentItem.locationAddress).font(.caption).foregroundColor(self.colorScheme == .dark ? Color(.black) : Color.white)
                    
                }
                Spacer()
            }
            ModelPages(self.currentItem.locationReviews, currentPage: $currentPage, navigationOrientation: .horizontal, transitionStyle: .scroll, bounce: true, wrap: false, hasControl: false, control: nil, controlAlignment: .center) { (i, review) in
                VStack {
                    Text(review.review).foregroundColor(self.colorScheme == .dark ? Color(.black) : Color.white)
                    Spacer()
                    RatingView(rating: .constant(review.rating))
                }.padding(.vertical, 10)
            }
        }
    }
}
