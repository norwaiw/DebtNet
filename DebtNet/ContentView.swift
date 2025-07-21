import SwiftUI

struct ContentView: View {
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        TabView {
            DebtListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Долги")
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Статистика")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(DebtStore())
}