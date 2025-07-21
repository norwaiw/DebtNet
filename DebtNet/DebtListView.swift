import SwiftUI

struct DebtListView: View {
    @EnvironmentObject var debtStore: DebtStore
    @State private var showingAddDebt = false
    @State private var selectedFilter: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "Все"
        case owedToMe = "Мне должны"
        case iOwe = "Я должен"
    }
    
    var filteredDebts: [Debt] {
        switch selectedFilter {
        case .all:
            return debtStore.debts.sorted { $0.dateCreated > $1.dateCreated }
        case .owedToMe:
            return debtStore.debtsOwedToMe.sorted { $0.dateCreated > $1.dateCreated }
        case .iOwe:
            return debtStore.debtsIOwe.sorted { $0.dateCreated > $1.dateCreated }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("История долгов")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAddDebt = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.red)
                                .font(.title2)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Color.red))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Filter Buttons
                    HStack(spacing: 12) {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Button(action: {
                                selectedFilter = option
                            }) {
                                Text(option.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedFilter == option ? .white : .gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedFilter == option ? Color.red : Color.gray.opacity(0.3))
                                    )
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Summary Cards
                    HStack(spacing: 16) {
                        // Мне должны (Green)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Мне должны")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("\(Int(debtStore.totalOwedToMe)) ₽")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.15))
                        )
                        
                        // Я должен (Red)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Я должен")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("\(Int(debtStore.totalIOwe)) ₽")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.15))
                        )
                    }
                    .padding(.horizontal)
                    
                    // Debt List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredDebts) { debt in
                                DebtHistoryRowView(debt: debt)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddDebt) {
            AddDebtView()
                .preferredColorScheme(.dark)
        }
    }
}

struct DebtHistoryRowView: View {
    let debt: Debt
    @EnvironmentObject var debtStore: DebtStore
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .fill(debt.type == .owedToMe ? Color.green : Color.red)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: debt.type == .owedToMe ? "arrow.down" : "arrow.up")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.debtorName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(debt.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Text(dateFormatter.string(from: debt.dateCreated))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(debt.amountWithSign)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(debt.type == .owedToMe ? .green : .red)
                
                Text("RUB")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    DebtListView()
        .environmentObject(DebtStore())
        .preferredColorScheme(.dark)
}