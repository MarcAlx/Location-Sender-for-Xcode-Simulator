import SwiftUI
import MapKit

struct RoutingView: View {
    /// to display file importer
    @State private var fileImporterPresented:Bool = false
    
    /// route loaded by user
    @State private var route:Route? = nil
    
    /// to display aler
    @State private var hasError = false
    
    /// error presented in alert if any
    @State private var error:Error? = nil
    
    var body: some View {
        VStack{
            HStack {
                Button("button.pickRoute.text", systemImage: "folder") {
                    self.fileImporterPresented = true
                }
                Spacer()
                Button {
                    if let url = URL(string:  "https://geojson.org"){
                        EnvironmentValues().openURL(url)
                    }
                } label: {
                    Image(systemName: "questionmark.text.page")
                }
            }
            if let route = route {
                GroupBox {
                    HStack {
                        HStack {
                            Text("text.geosjson.text")
                            Text(self.route!.filePath).bold()
                        }
                        Spacer()
                        Button {
                            self.clearGeoJson()
                        } label: {
                            Image(systemName: "xmark")
                        } .buttonStyle(.borderless)
                    }
                }.cornerRadius(5)
                Map {
                    MapPolyline(route.asPolyline).stroke(.blue, lineWidth: 5)
                }.mapStyle(.standard)
                 .cornerRadius(5)
            }
            else {
                Spacer()
                Text("text.noRoutePicked.text").italic()
                Spacer()
            }
        }.fileImporter(isPresented: self.$fileImporterPresented, allowedContentTypes:[.geoJSON, .json, .text, .plainText], onCompletion: { (res) in
            switch res {
            case .success(_):
                do {
                    self.route = try decode(geoJsonFile: try res.get())
                }
                catch{
                    self.declareError(err: error)
                }
            case .failure(let error):
                print(error)
            }
        })
        .alert(isPresented: self.$hasError) {
            if let err = error{
                Alert(title: Text("alert.error.title"),
                      message: Text(err.localizedDescription),
                      dismissButton: .default(Text("alter.error.okButton")))
            }
            else {
                Alert(title: Text("alert.error.title"),
                      message: Text("alert.error.unknownMessage"),
                      dismissButton: .default(Text("alter.error.okButton")))
            }
        }
        .padding(5)
    }
    
    /// to display an error in alert
    private func declareError(err:Error){
        self.hasError = true
        self.error = err
    }
    
    /// unload current GeoJson
    private func clearGeoJson() {
        self.route = nil
    }
}

#Preview {
    RoutingView()
}
