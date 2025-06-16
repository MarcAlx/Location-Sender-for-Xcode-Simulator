import MapKit
import SwiftUI
import Foundation

struct Location {
    public var address:String
    public var coordinates:CLLocationCoordinate2D
}

struct ContentView: View {
    //address tapped by user
    @State private var address: String = ""
    
    //location selected by user
    @State private var selectedLocation:Location? = nil
    
    var body: some View {
        VStack {
            HStack{
                TextField("search for a location", text: $address)
                Button {
                    self.geocode(address: self.address)
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
            //map reader to ease conversion to UI click to coordinated
            MapReader { proxy in
                Map(interactionModes: [.all]) {
                    //place location on map
                    if let selectedLocation {
                        Marker(selectedLocation.address, coordinate: selectedLocation.coordinates)
                    }
                }.mapStyle(.standard)
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
            HStack{
                if let selectedLocation {
                    Text("Searched/clicked location: \(selectedLocation.address)")
                    Spacer()
                    Button("Send to simulator", systemImage: "paperplane") {
                        print(shell("xcrun simctl location booted set \(selectedLocation.coordinates.latitude),\(selectedLocation.coordinates.longitude)"))
                    }
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
    
    ///
    /// converts a placem mark to a human readable address
    ///
    func inlineAddress(from placemark: CLPlacemark) -> String {
        let name = placemark.name ?? ""
        let street = placemark.thoroughfare ?? ""
        let city = placemark.locality ?? ""
        let state = placemark.administrativeArea ?? ""
        let postalCode = placemark.postalCode ?? ""
        let country = placemark.country ?? ""

        return "\(name)\(name != "" && street != "" ? ", " : " ")\(street)\(street != "" && postalCode != "" ? ", " : " ")\(postalCode)\(postalCode != "" && city != "" ? ", " : " ") \(city)\(city != "" && state != "" ? ", " : " ")\(state)\(state != "" && country != "" ? ", " : " ")\(country)"
    }
    
    ///
    /// run a shell command, requires that the app is not sandboxed
    ///
    private func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.standardInput = nil
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}

#Preview {
    ContentView()
}
