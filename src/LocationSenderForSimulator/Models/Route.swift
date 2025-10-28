import MapKit

/// a route
public struct Route {
    /// originated file path
    public private(set) var filePath:String
    
    /// read geojson
    public private(set) var geoJson:MKGeoJSONObject
    
    /// relevant geometry in geojson
    public private(set) var geometry:MKMultiPoint
}
