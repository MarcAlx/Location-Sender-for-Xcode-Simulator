import MapKit

///
/// converts a placem mark to a human readable address
///
public func inlineAddress(from placemark: CLPlacemark) -> String {
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
public func runShell(command: String) -> String {
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

/// send location to simulator
public func sendToSimulator(location: Location){
    print(runShell(command: "xcrun simctl location booted set \(location.coordinates.latitude),\(location.coordinates.longitude)"))
}

/// tries to decode a route from a given geojson file
/// • may fails if geojson is inaccessible or invalid or if no multi point geometry found
public func decode(geoJsonFile:URL) throws -> Route {
    let fileUrl = geoJsonFile
    guard fileUrl.startAccessingSecurityScopedResource() else {
        throw GeoJsonRouteError.inacessibleFile
    }
    
    //read data
    let data: Data
    do {
        data = try Data(contentsOf: geoJsonFile)
    } catch {
        throw GeoJsonRouteError.inacessibleFile
    }
    
    //release file access
    defer { geoJsonFile.stopAccessingSecurityScopedResource() }
      
    //decode json
    let geoJsonObjects: [MKGeoJSONObject]
    do {
        geoJsonObjects = try MKGeoJSONDecoder().decode(data)
    } catch {
        throw GeoJsonRouteError.invalidGeoJson(errDesc: error.localizedDescription)
    }
    
    //check empty
    guard !geoJsonObjects.isEmpty else {
        throw GeoJsonRouteError.emptyGeoJson
    }
    
    //look for first valid geometry
    for obj in geoJsonObjects {
        if let geometry = tryGetValidGeometryFromObject(object: obj) {
            return Route(filePath: fileUrl.path(), geoJson: obj, geometry: geometry)
        }
    }
    throw GeoJsonRouteError.invalidGeometry
}

/// tries to get an MKMultiPoint from a MKGeoJSONObject
/// may return null if object doesn't hold any multi moint
public func tryGetValidGeometryFromObject(object: MKGeoJSONObject) -> MKMultiPoint? {
    switch object {
    //feature -> check geometry
    case let feature as MKGeoJSONFeature:
        //no geoemtry -> nil
        if(feature.geometry.isEmpty){
            return nil
        }
        //try to find first multipoint geometry
        for geom in feature.geometry {
            if let validGeom = tryGetValidGeometryFromObject(object: geom) {
                return validGeom
            }
        }
        //no valid geom -> nil
        return nil
    //multi points -> that's what we are looking for
    case let multiPoints as MKMultiPoint:
        return multiPoints
    //any other thing -> nil
    default:
        return nil
    }
}
