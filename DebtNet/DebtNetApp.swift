import SwiftUI

@main
struct DebtNetApp: App {
    @StateObject private var debtStore = DebtStore()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(debtStore)
                .environmentObject(themeManager)
        }
    }
}