import Foundation

/// any geojson related error
enum GeoJsonRouteError: LocalizedError {
    ///file can't be accessed
    case inacessibleFile
    
    ///geosjon is not valid
    case invalidGeoJson(errDesc:String)
    
    ///geometry is not a multi point
    case invalidGeometry
    
    ///geometry is empty
    case emptyGeoJson
    
    var errorDescription: String? {
        switch self {
        case .inacessibleFile:
            return NSLocalizedString("error.inaccessiblefile.description", comment: "")
        case .invalidGeoJson(let errDesc):
            return String(format: NSLocalizedString("error.invalidGeoJson.description %@", comment: ""), errDesc)
        case .emptyGeoJson:
            return NSLocalizedString("error.emptyGeoJson.description", comment: "")
        case .invalidGeometry:
            return NSLocalizedString("error.invalidGeometry.description", comment: "")
        }
    }
}
