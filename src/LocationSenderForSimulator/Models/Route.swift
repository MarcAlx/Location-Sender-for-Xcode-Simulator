import MapKit

/// a route
public struct Route {
    /// originated file path
    public private(set) var filePath:String
    
    /// read geojson
    public private(set) var geoJson:MKGeoJSONObject
    
    /// relevant geometry in geojson
    public private(set) var geometry:MKMultiPoint
    
    /// cast geometry as polyline
    public var asPolyline:MKPolyline {
        return MKPolyline(points: geometry.points(), count: geometry.pointCount)
    }
}
