import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Summary Cards
                    SummaryCardsView()
                    
                    // Category Statistics
                    CategoryStatisticsView()
                    
                    // Recent Activity
                    RecentActivityView()
                    
                    // Overdue Debts Alert
                    if !debtStore.overdueDebts.isEmpty {
                        OverdueDebtsView()
                    }
                }
                .padding()
            }
            .navigationTitle("Статистика")
        }
    }
}

struct SummaryCardsView: View {
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Общий долг",
                    value: debtStore.totalDebtAmount,
                    color: .red,
                    icon: "minus.circle.fill"
                )
                
                StatCard(
                    title: "Погашено",
                    value: debtStore.totalPaidAmount,
                    color: .green,
                    icon: "checkmark.circle.fill"
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Активных долгов",
                    value: Double(debtStore.activeDebts.count),
                    color: .blue,
                    icon: "list.bullet.circle.fill",
                    isCount: true
                )
                
                StatCard(
                    title: "Просрочено",
                    value: Double(debtStore.overdueDebts.count),
                    color: .orange,
                    icon: "exclamationmark.triangle.fill",
                    isCount: true
                )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: Double
    let color: Color
    let icon: String
    let isCount: Bool
    
    init(title: String, value: Double, color: Color, icon: String, isCount: Bool = false) {
        self.title = title
        self.value = value
        self.color = color
        self.icon = icon
        self.isCount = isCount
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            Text(formattedValue)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var formattedValue: String {
        if isCount {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.2f ₽", value)
        }
    }
}

struct CategoryStatisticsView: View {
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("По категориям")
                .font(.headline)
                .padding(.horizontal)
            
            let categoryGroups = debtStore.debtsByCategory()
            
            ForEach(Debt.DebtCategory.allCases, id: \.self) { category in
                if let debts = categoryGroups[category], !debts.isEmpty {
                    CategoryRow(category: category, debts: debts)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryRow: View {
    let category: Debt.DebtCategory
    let debts: [Debt]
    
    private var totalAmount: Double {
        debts.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    private var activeCount: Int {
        debts.filter { !$0.isPaid }.count
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(activeCount) активных")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.2f ₽", totalAmount))
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct RecentActivityView: View {
    @EnvironmentObject var debtStore: DebtStore
    
    private var recentDebts: [Debt] {
        debtStore.debts
            .sorted { $0.dateCreated > $1.dateCreated }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Недавняя активность")
                .font(.headline)
                .padding(.horizontal)
            
            if recentDebts.isEmpty {
                Text("Нет недавней активности")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(recentDebts) { debt in
                    RecentActivityRow(debt: debt)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecentActivityRow: View {
    let debt: Debt
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(debt.debtorName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(debt.dateCreated, formatter: recentDateFormatter)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack {
                if debt.isPaid {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                Text(debt.formattedAmount)
                    .font(.subheadline)
                    .foregroundColor(debt.isPaid ? .green : .primary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct OverdueDebtsView: View {
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Просроченные долги")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            .padding(.horizontal)
            
            ForEach(debtStore.overdueDebts) { debt in
                OverdueDebtRow(debt: debt)
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

struct OverdueDebtRow: View {
    let debt: Debt
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(debt.debtorName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let dueDate = debt.dueDate {
                    Text("Просрочен с \(dueDate, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(debt.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                
                Button("Погасить") {
                    withAnimation {
                        debtStore.markAsPaid(debt)
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

private let recentDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    StatisticsView()
        .environmentObject(DebtStore())
}