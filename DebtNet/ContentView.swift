import SwiftUI

struct ContentView: View {
    @EnvironmentObject var debtStore: DebtStore
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content
                Group {
                    switch selectedTab {
                    case 0:
                        DebtListView()
                    case 1:
                        StatisticsView()
                    case 2:
                        SettingsView()
                    default:
                        DebtListView()
                    }
                }
                
                // Custom Bottom Navigation
                HStack {
                    // Debts
                    Button(action: {
                        selectedTab = 0
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 20))
                                .foregroundColor(selectedTab == 0 ? .blue : .gray)
                            
                            Text("Debts")
                                .font(.system(size: 12))
                                .foregroundColor(selectedTab == 0 ? .blue : .gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Statistics
                    Button(action: {
                        selectedTab = 1
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                                .foregroundColor(selectedTab == 1 ? .blue : .gray)
                            
                            Text("Statistics")
                                .font(.system(size: 12))
                                .foregroundColor(selectedTab == 1 ? .blue : .gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Settings
                    Button(action: {
                        selectedTab = 2
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(selectedTab == 2 ? .blue : .gray)
                            
                            Text("Settings")
                                .font(.system(size: 12))
                                .foregroundColor(selectedTab == 2 ? .blue : .gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.black)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.gray.opacity(0.3)),
                    alignment: .top
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Настройки")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                Text("Настройки приложения")
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DebtStore())
}