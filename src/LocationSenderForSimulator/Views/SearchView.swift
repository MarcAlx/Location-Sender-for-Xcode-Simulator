import MapKit
import SwiftUI
import Foundation

struct SearchView: View {
    //address tapped by user
    @State private var address: String = ""
    
    //location selected by user
    @State private var selectedLocation:Location? = nil
    
    //where camera look at
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    //current
    @State private var currentSpan = MKCoordinateSpan(latitudeDelta: 0.030, longitudeDelta: 0.030)
    
    var body: some View {
        VStack {
            HStack{
                TextField("search for a location", text: $address).onSubmit {
                    //on enter search
                    self.geocode(address: self.address)
                }
                Button {
                    self.geocode(address: self.address)
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
            //map reader to ease conversion to UI click to coordinated
            MapReader { proxy in
                Map(position: $cameraPosition, interactionModes: [.all]) {
                    //place location on map
                    if let selectedLocation {
                        Marker(selectedLocation.address, systemImage: "mappin", coordinate: selectedLocation.coordinates)
                    }
                }
                //watch for camera change to preserve zoom level
                .onMapCameraChange(frequency: .onEnd) { context in
                    currentSpan = context.region.span
                }
                //when location change, update camera
                .onChange(of: selectedLocation) { _, newValue in
                    if let newValue {
                        withAnimation {
                            cameraPosition = .region(MKCoordinateRegion(
                                center: newValue.coordinates,
                                span: currentSpan
                            ))
                        }
                    }
                }
                .mapStyle(.standard)
                     .cornerRadius(10)
                     .onTapGesture { screenPosition in
                         //convert screen position to map coordinates
                         if let mapCoordinate = proxy.convert(screenPosition, from: .local)
                         {
                             self.reverseGeocode(location: mapCoordinate)
                         }
                     }
            }
            //summary area
            if let selectedLocation {
                GroupBox {
                    HStack{
                        Text("Searched/clicked location: \(selectedLocation.address)")
                        Spacer()
                        Button("Send to simulator", systemImage: "paperplane") {
                            print(runShell(command: "xcrun simctl location booted set \(selectedLocation.coordinates.latitude),\(selectedLocation.coordinates.longitude)"))
                        }
                    }
                } label: {
                  Label("Location on map", systemImage: "mappin.and.ellipse")
                }
            }
        }.padding()
    }
    
    ///
    /// converts a string (representing an address) to its map location (result set in self.selectedLocation)
    ///
    private func geocode(address:String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: geocodeHandler)
    }
    
    ///
    /// converts a location to its textual representation (address) (result set in self.selectedLocation)
    ///
    private func reverseGeocode(location:CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), completionHandler: geocodeHandler)
    }
    
    ///
    /// called on geocode / reverse geocode result, takes results and set it to self.selectedLocation
    ///
    private func geocodeHandler(placemarks:Optional<Array<CLPlacemark>>, error:Optional<any Error>) -> Void {
        if error != nil {
            print("Failed to retrieve location")
            return
        }
        
        var location: CLPlacemark?
        
        if let placemarks = placemarks, placemarks.count > 0 {
            location = placemarks.first
        }
        
        if let location = location {
            self.selectedLocation = Location(address: inlineAddress(from: location), coordinates:location.location!.coordinate)
        }
        else
        {
            print("No Matching Location Found")
        }
    }
    
}

#Preview {
    SearchView()
}
