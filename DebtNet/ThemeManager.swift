import SwiftUI
import Foundation

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    var backgroundColor: Color {
        isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(red: 0.98, green: 0.98, blue: 0.96)
    }
    
    var primaryTextColor: Color {
        isDarkMode ? .white : .black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? .gray : .gray
    }
    
    var navigationBarColor: Color {
        isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(red: 0.98, green: 0.98, blue: 0.96)
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
}