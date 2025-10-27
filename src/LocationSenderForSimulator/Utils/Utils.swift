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
