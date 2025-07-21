import SwiftUI

@main
struct DebtNetApp: App {
    @StateObject private var debtStore = DebtStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(debtStore)
        }
    }
}