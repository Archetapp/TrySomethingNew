//
//  MapView.swift
//  TrySomethingNew
//
//  Created by Jared on 7/7/20.
//  Copyright © 2020 Archetapp. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI

struct MapView : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var currentLandmarks : [Landmark]
    var body : some View {
        ZStack {
            Color("DarkGray").edgesIgnoringSafeArea(.all)
            MapViewRepresentable(landmarks: self.$currentLandmarks).edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct Landmark {
    let id: String
    let name: String
    let location: CLLocationCoordinate2D
}




final class LandmarkAnnotation: NSObject, MKAnnotation {
    let id: String
    let title: String?
    let coordinate: CLLocationCoordinate2D

    init(landmark: Landmark) {
        self.id = landmark.id
        self.title = landmark.name
        self.coordinate = landmark.location
    }
}

struct MapViewRepresentable : UIViewRepresentable {
    @Binding var landmarks: [Landmark]
    typealias Context = UIViewRepresentableContext<Self>
    
    
    func makeUIView(context: UIViewRepresentableContext<MapViewRepresentable>) -> MKMapView {
        let mapView = MKMapView()
        return mapView
    }
    
    func makeCoordinator() -> MapViewCoordinator{
         MapViewCoordinator(self)
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.delegate = context.coordinator
        uiView.removeAnnotations(uiView.annotations)
        for landmark in self.landmarks {
            context.coordinator.currentLongitude = landmark.location.latitude
            context.coordinator.currentLatitude = landmark.location.longitude
            let newAnnotation = LandmarkAnnotation(landmark: landmark)
            uiView.addAnnotations([newAnnotation])
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
   
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
      var mapViewController: MapViewRepresentable
    var currentLatitude : CLLocationDegrees = 0
    var currentLongitude : CLLocationDegrees = 0
      init(_ control: MapViewRepresentable) {
          self.mapViewController = control
      }
        
      func mapView(_ mapView: MKMapView, viewFor
           annotation: MKAnnotation) -> MKAnnotationView?{
         //Custom View for Annotation
          let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customView")
          annotationView.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
        button.addTarget(self, action: #selector(openMapForPlace), for: .touchUpInside)
        annotationView.rightCalloutAccessoryView = button
          //Your custom image icon
          annotationView.image = UIImage(systemName: "mappin.circle.fill")
          return annotationView
       }
    
    @objc func openMapForPlace() {

        let regionDistance:CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2DMake(currentLatitude, currentLongitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Place Name"
        mapItem.openInMaps(launchOptions: options)
    }
}

