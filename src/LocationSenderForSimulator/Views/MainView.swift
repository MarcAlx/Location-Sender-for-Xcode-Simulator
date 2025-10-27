import MapKit
import SwiftUI
import Foundation

struct MainView: View {
    var body: some View {
        TabView {
            Tab("Search", systemImage: "magnifyingglass") {
                SearchView()
            }
        }
    }
}

#Preview {
    MainView()
}
