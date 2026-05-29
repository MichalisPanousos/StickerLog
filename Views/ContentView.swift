import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Inventory", systemImage: "square.grid.2x2") {
                Text("Inventory")
            }
            Tab("Events", systemImage: "bag") {
                Text("Events")
            }
        }
    }
}
