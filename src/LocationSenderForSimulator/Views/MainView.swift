import MapKit
import SwiftUI
import Foundation

struct MainView: View {
    var body: some View {
        TabView {
            Tab("tab.search", systemImage: "magnifyingglass") {
                SearchView()
            }
        }.toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    if let url = URL(string:  "https://github.com/MarcAlx/Location-Sender-for-Xcode-Simulator"){
                        EnvironmentValues().openURL(url) 
                    }
                }) {
                    Label("button.info", systemImage: "info.circle")
                }
            }
        }
    }
}

#Preview {
    MainView()
}
