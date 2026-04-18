import SwiftUI
import MapKit

struct RoutingView: View {
    @Environment(\.openURL) private var openURL
    
    /// to display file importer
    @State private var fileImporterPresented:Bool = false
    
    /// route loaded by user
    @State private var route:Route? = nil
    
    /// to display aler
    @State private var hasError = false
    
    /// error presented in alert if any
    @State private var error:Error? = nil
    
    /// playback rate expressed in ms (everytime a new point is sent to simulator)
    @State private var playbackRate:Double = Double(DEFAULT_POINT_RATE)
    
    /// current index
    @State private var currentPointIndex:Int = 0
    
    /// true if point are sent to simulator
    @State private var isPlaying:Bool = false
    
    /// true if playback is looping
    @State private var isLooping:Bool = false
    
    /// timer used for playback, run as soon as a route is provided, it's isPlaying that decide if something is sent to simulator
    @State private var playbackTimer:Timer? = nil
    
    var body: some View {
        VStack{
            //header
            HStack {
                Button("button.pickRoute.text", systemImage: "folder") {
                    self.fileImporterPresented = true
                }
                Spacer()
                Button {
                    if let url = URL(string:  "https://geojson.org"){
                        openURL(url)
                    }
                } label: {
                    Image(systemName: "questionmark.text.page")
                }
            }
            
            //if any route is selected
            if let route = route {
                //file summary
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
                        }.buttonStyle(.borderless)
                    }
                }.cornerRadius(5)
                
                //map
                Map {
                    MapPolyline(route.asPolyline).stroke(.blue, lineWidth: 5)
                    if(self.currentPointIndex>0){
                        MapPolyline(MKPolyline(points: route.geometry.points(), count: self.currentPointIndex)).stroke(.green, lineWidth: 5)
                    }
                }.mapStyle(.standard)
                 .cornerRadius(5)
                
                //playback control
                GroupBox {
                    HStack{
                        Button {
                            self.currentPointIndex = 0
                        } label: {
                            Image(systemName: "arrow.left.to.line")
                        }.buttonStyle(.borderless)
                        
                        Button {
                            self.isPlaying = !self.isPlaying
                        } label: {
                            Image(systemName: self.isPlaying ?  "pause" : "play")
                        }.buttonStyle(.borderless)
                        
                        Button {
                            self.isLooping = !self.isLooping
                        } label: {
                            Image(systemName: self.isLooping ?  "repeat.circle.fill" : "repeat.circle")
                        }.buttonStyle(.borderless)
                     
                        Divider().frame(width:2, height: 30)
                        
                        VStack{
                            HStack{
                                Text("text.pointSender.text").font(.footnote)
                                Text("text.currentPointRate.text \(String(self.playbackRate))").font(.footnote).bold()
                                Spacer()
                            }
                            
                            Slider(value: self.$playbackRate, in:  Double(MIN_POINT_RATE)...Double(MAX_POINT_RATE), step:Double(POINT_RATE_STEP)) {
                            } minimumValueLabel: {
                                Text("text.pointMinRate.text \(String(MIN_POINT_RATE))")
                            } maximumValueLabel: {
                                Text("text.pointMaxRate.text \(String(MAX_POINT_RATE))")
                            }
                            
                        }
                    }
                } label: {
                  Label("groupBox.routePlayer.text", systemImage: "figure.run")
                }
                 .cornerRadius(5)
                
                //progress summary
                GroupBox {
                    Gauge(value: Float(self.currentPointIndex), in: 0...Float(route.geometry.pointCount)) {
                        HStack{
                            Text("text.progress.text")
                            Text("text.pointProgress.text \(String(self.currentPointIndex)) \(String(route.geometry.pointCount))").bold()
                        }
                    }.gaugeStyle(.accessoryLinearCapacity).tint(.green)
                } label: {
                  Label("groupBox.routeProgress.text", systemImage: "flag.pattern.checkered")
                }
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
                    self.startTimer()
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
        // when playback rate change
        .onChange(of: self.playbackRate) { oldValue, newValue in
            //restart timer to adjust frequency, without re-initing index
            self.stopTimer()
            self.startTimer()
        }
        .padding()
    }
    
    /// to display an error in alert
    private func declareError(err:Error){
        self.hasError = true
        self.error = err
    }
    
    /// unload current GeoJson
    private func clearGeoJson() {
        self.route = nil
        self.currentPointIndex = 0
        self.stopTimer()
    }
    
    /// call every time timer steps
    private func run(timer:Timer)->Void {
        if let route = self.route {
            if(self.isPlaying && self.currentPointIndex < route.geometry.pointCount){
                sendToSimulator(location: Location(address: "", coordinates: route.geometry.points()[self.currentPointIndex].coordinate))
                self.currentPointIndex = (self.currentPointIndex + 1) % route.geometry.pointCount
                
                //when reaching end, keep playing only if looping
                if(self.currentPointIndex == 0){
                    self.isPlaying = self.isLooping
                }
            }
        }
    }
    
    /// start timer
    private func startTimer() {
        //stop any pending timer before
        if let timer = self.playbackTimer {
            timer.invalidate()
        }
        self.playbackTimer = Timer.scheduledTimer(withTimeInterval: self.playbackRate/1000, repeats: true, block: run)
    }
    
    /// stop timer
    private func stopTimer() {
        self.playbackTimer?.invalidate()
    }
}

#Preview {
    RoutingView()
}
