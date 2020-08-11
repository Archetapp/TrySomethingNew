//
//  ContentView.swift
//  TrySomethingNew
//
//  Created by Jared on 7/7/20.
//  Copyright © 2020 Archetapp. All rights reserved.
//

import SwiftUI
import MapKit
import Combine
import YelpAPI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    

    @State var interest : String = ""
    @State var radius : Float = 10
    @EnvironmentObject var locationManager : LocationManager
    @State var bottomViewOffset : CGFloat = 400
    @State var isPresented : Bool = false
    @State var searched : Bool = false
    @State var typeOfDistance : Int = 0
    @State var reload : Bool = false
    @State var currentReloadDegrees : Double = 0
    @State var loading = false
    @State var lastSearch = ""
    init() {
        UITableView.appearance().separatorColor = .clear
    }
    
    var body: some View {
        NavigationView {
            GeometryReader {
                
                geometry in
                ZStack(alignment: .bottom) {
                    VStack {
                        TextField("Search Interest...", text: self.$interest, onEditingChanged: {
                            changed in
                            if changed {
                                self.searched = false
                            }
                        }, onCommit: {
                            self.searchNearbyLocations()
                        }).padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 10))
                        ScrollView {
                            ZStack {
                                Text("Loading...").bold().opacity(self.loading ? 1.0 : 0).animation(.spring())
                                LocationView(currentItem: self.locationManager.mapItem ?? LocationIdentifiable(id: UUID(), locationName: "", locationImage: "", locationReviews: [ratingIdentifiable(rating: 0, review: "")], locationAddress: "", locationLatitude: 0, locationLongitude: 0, website: "")).padding(20).listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0  )).offset(x: self.searched ? 0 : -500, y: 0).rotationEffect(Angle(degrees: self.searched ? 0 : -20)).animation(.spring())
                            }
                        }
                    }
                    ZStack(alignment: .bottomTrailing) {
                         Button(action: self.loadNewData, label: {
                            Image(systemName: "arrow.counterclockwise.circle.fill").resizable()
                                .accentColor(self.colorScheme == .dark ? Color.white : Color.black).frame(width: 50, height: 50, alignment: .center)
                                .background(self.colorScheme == .dark ? Color.black : Color.white)
                                .cornerRadius(25)
                                .shadow(radius: 10)
                                .rotationEffect(Angle(degrees: self.reload ? self.currentReloadDegrees : self.currentReloadDegrees))
                                .offset(x: self.isPresented ? 200 : 0, y: 0)
                                .animation(Animation.spring())

                        })
                    }.frame(minWidth: 0, maxWidth: .infinity, alignment: .bottomTrailing).padding(30)
                    
                    ZStack(alignment: .bottom) {

                        Button(action: self.edit, label: {
                            Image(systemName: "arrow.up.circle.fill").resizable()
                                .background((self.colorScheme == .dark ? Color.white : Color.black).frame(width: 30, height: 30, alignment: .center))
                                .accentColor(self.colorScheme == .dark ? Color.black : Color.white).frame(width: 50, height: 50, alignment: .center)
                                .cornerRadius(25)
                                .shadow(radius: 10)
                                .rotationEffect(Angle(degrees: self.isPresented ? 180 : 0))
                                .animation(Animation.spring())

                        }).offset(x: 0, y: self.isPresented ? -260 : 0).animation(Animation.spring())

                        VStack {
                            Text(self.radius.clean).bold().font(.largeTitle).frame(width: 300,alignment: .center).padding(20)
                            Slider(value: self.$radius, in: 10...100, step: 1).padding(.horizontal, 20).accentColor(self.colorScheme == .dark ? Color.white : Color.black)
                            Picker(selection: self.$typeOfDistance, label: Text("")) {
                                Text("MI").tag(0)
                                Text("KM").tag(1)
                                }.pickerStyle(SegmentedPickerStyle()).frame(width: 200, alignment: .center).padding(20)
                        }.background(self.colorScheme == .dark ? Color.black : Color.white).cornerRadius(10).padding(20).shadow(radius: 10).offset(x: 0, y: self.bottomViewOffset).animation(Animation.spring())
                    }.padding(.bottom, 30).navigationBarTitle("What To Do.")
                }
            }
        }
    }
    
    func edit() {
        self.isPresented.toggle()
        self.bottomViewOffset = self.isPresented ? 0 : 400
    }
    
    func searchNearbyLocations() {
        //if lastSearch == interest {
            self.searched = false
            self.loading = true
            self.locationManager.grabNearbyLocations(keyword: interest, completion: {
                completed in
                if completed == true {
                    self.searched = true
                    self.loading = false
                    self.lastSearch = self.interest
                }
            })
//        } else {
//
//        }
    }
    
    func loadNewData() {
        self.reload.toggle()
        self.currentReloadDegrees -= 360
        self.searchNearbyLocations()
    }
}

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LocationIdentifiable : Identifiable {
    var id = UUID()
    var locationName : String
    var locationImage : String
    var locationReviews : [ratingIdentifiable]
    var locationAddress : String
    var locationLatitude : Double
    var locationLongitude : Double
    var website : String
}

struct ratingIdentifiable : Identifiable {
    var id = UUID()
    var rating : Int
    var review : String
}

class LocationManager: NSObject, ObservableObject {
    static let geoCoder = CLGeocoder()
    @Published var location : CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }
    
    var client : YLPClient?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
        self.client = YLPClient.init(apiKey: "{INSERT YELP API ACCESS KEY}") //_K0IgOn39g2OI_9sOF5LpKYJMXXyw8hGQYnQob4QOtXkv2UxGyhhrSNm4PSTacBh_Tj8Y1-SCaUQK5Ny6Ih5Ou6iIWgainLSwg2KLBPb8-PJf4c9r1U3dWqR4-oFX3Yx
    }

    
    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }


    @Published var mapItem : LocationIdentifiable? {
        willSet {
            objectWillChange.send()
        }
    }
    @Published var mapItems : [LocationIdentifiable] = [] {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var nearbyLocationsInArea : [LocationIdentifiable] = [] {
        willSet {
            objectWillChange.send()
            
        }
    }
    
    

    let searchRequest = MKLocalSearch.Request()
    var city = ""
    var state = ""
    
    //This is used for the explore page to grab local locations based on a keyword.
    func grabNearbyLocations(keyword : String, completion : @escaping(_ completed : Bool) -> ()) {
        self.client?.search(with: YLPCoordinate(latitude: self.location?.coordinate.latitude ?? 0, longitude: self.location?.coordinate.longitude ?? 0), term: keyword, limit: 10, offset: 0, sort: .distance, completionHandler: { (search, error) in
            if error != nil {
                print(error!)
            } else {
                let number = Int.random(in: 0 ..< (search?.businesses.count ?? 0))
                let result = search?.businesses.shuffled()[number]
                self.client?.reviewsForBusiness(withId: result?.identifier ?? "", completionHandler: { (reviews, error) in
                    if error != nil {
                        print(error!)
                    } else {
                        var reviewTemp = [ratingIdentifiable]()
                        for review in reviews!.reviews {
                            reviewTemp.append(ratingIdentifiable(id: UUID(), rating: Int(review.rating), review: review.excerpt))
                        }
                        DispatchQueue.main.async {
                            self.mapItem = LocationIdentifiable(id: UUID(),
                            locationName: result?.name ?? "",
                            locationImage: result?.imageURL?.absoluteString ?? "",
                            locationReviews: reviewTemp,
                            locationAddress: result?.location.address.first ?? "",
                            locationLatitude: result?.location.coordinate?.latitude ?? 0,
                            locationLongitude: result?.location.coordinate?.longitude ?? 0,
                            website: result?.url.absoluteString ?? "http://www.google.com")
                            completion(true)
                        }
                    }
                })
            }
        })
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }

        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    let objectWillChange = PassthroughSubject<Void, Never>()
    var publisher: AnyPublisher<Void, Never>! = nil
    private let locationManager = CLLocationManager()
}


extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    //Anytime the user changes location, we update that.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location = locations.last
         LocationManager.geoCoder.reverseGeocodeLocation(location!) { placemarks, _ in
            if let place = placemarks?.first {
                 self.city = place.locality ?? "Error"
                 self.state = place.administrativeArea ?? ""
                self.location = location ?? CLLocation(latitude: 0, longitude: 0)
            }
        }
    }
}


extension String {
    func removeSpecialChars() -> String {
        let okayChars : Set<Character> =
            Set("1234567890")
        return String(self.filter {okayChars.contains($0) })
    }
}
