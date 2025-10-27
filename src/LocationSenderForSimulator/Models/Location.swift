import MapKit

/// represents a location (coordinated+address)
public struct Location: Equatable {
    ///address of the location
    public var address: String
    
    ///coordinates of the location
    public var coordinates: CLLocationCoordinate2D
    
    // checks equity
    public static func == (lhs: Location, rhs: Location) -> Bool {
           lhs.address == rhs.address
        && lhs.coordinates.latitude == rhs.coordinates.latitude
        && lhs.coordinates.longitude == rhs.coordinates.longitude
    }
}
