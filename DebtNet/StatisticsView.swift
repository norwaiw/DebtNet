import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var debtStore: DebtStore
    @State private var selectedFilter: DebtFilter = .all
    
    enum DebtFilter {
        case all
        case owedToMe
        case iOwe
        case active
        case overdue
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Статистика")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    LazyVStack(spacing: 20) {
                        // Summary Cards
                        SummaryCardsView(selectedFilter: $selectedFilter)
                        
                        // Filtered Debts List
                        if selectedFilter != .all {
                            FilteredDebtsView(filter: selectedFilter)
                        } else {
                            // Category Statistics
                            CategoryStatisticsView()
                            
                            // Recent Activity
                            RecentActivityView()
                            
                            // Overdue Debts Alert
                            if !debtStore.overdueDebts.isEmpty {
                                OverdueDebtsView()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct SummaryCardsView: View {
    @EnvironmentObject var debtStore: DebtStore
    @Binding var selectedFilter: StatisticsView.DebtFilter
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Мне должны",
                    value: debtStore.totalOwedToMeWithInterest,
                    color: .green,
                    icon: "arrow.down.circle.fill",
                    isActive: selectedFilter == .owedToMe
                ) {
                    selectedFilter = selectedFilter == .owedToMe ? .all : .owedToMe
                }
                
                StatCard(
                    title: "Я должен",
                    value: debtStore.totalIOwe,
                    color: .red,
                    icon: "arrow.up.circle.fill",
                    isActive: selectedFilter == .iOwe
                ) {
                    selectedFilter = selectedFilter == .iOwe ? .all : .iOwe
                }
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Активных долгов",
                    value: Double(debtStore.activeDebts.count),
                    color: .blue,
                    icon: "list.bullet.circle.fill",
                    isCount: true,
                    isActive: selectedFilter == .active
                ) {
                    selectedFilter = selectedFilter == .active ? .all : .active
                }
                
                StatCard(
                    title: "Просрочено",
                    value: Double(debtStore.overdueDebts.count),
                    color: .orange,
                    icon: "exclamationmark.triangle.fill",
                    isCount: true,
                    isActive: selectedFilter == .overdue
                ) {
                    selectedFilter = selectedFilter == .overdue ? .all : .overdue
                }
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
    let isActive: Bool
    let onTap: () -> Void
    
    init(title: String, value: Double, color: Color, icon: String, isCount: Bool = false, isActive: Bool = false, onTap: @escaping () -> Void) {
        self.title = title
        self.value = value
        self.color = color
        self.icon = icon
        self.isCount = isCount
        self.isActive = isActive
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(isActive ? .white : color)
                        .font(.title2)
                    Spacer()
                }
                
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                Text(formattedValue)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isActive ? .white : color)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 110, maxHeight: 110, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? color.opacity(0.8) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? color : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isActive ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isActive)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var formattedValue: String {
        if isCount {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.0f ₽", value)
        }
    }
}

struct FilteredDebtsView: View {
    @EnvironmentObject var debtStore: DebtStore
    let filter: StatisticsView.DebtFilter
    
    private var filteredDebts: [Debt] {
        switch filter {
        case .all:
            return debtStore.debts
        case .owedToMe:
            return debtStore.debts.filter { $0.type == .owedToMe && !$0.isPaid }
        case .iOwe:
            return debtStore.debts.filter { $0.type == .iOwe && !$0.isPaid }
        case .active:
            return debtStore.activeDebts
        case .overdue:
            return debtStore.overdueDebts
        }
    }
    
    private var headerTitle: String {
        switch filter {
        case .all:
            return "Все долги"
        case .owedToMe:
            return "Мне должны"
        case .iOwe:
            return "Я должен"
        case .active:
            return "Активные долги"
        case .overdue:
            return "Просроченные долги"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(headerTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(filteredDebts.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if filteredDebts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("Нет долгов в этой категории")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredDebts) { debt in
                        FilteredDebtRow(debt: debt)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct FilteredDebtRow: View {
    let debt: Debt
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.debtorName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(debt.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(debt.category.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    if debt.isOverdue {
                        Text("Просрочен")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    if let dueDate = debt.dueDate {
                        Text(dueDate, formatter: shortDateFormatter)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(debt.formattedAmount)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(debt.type == .owedToMe ? .green : .red)
                
                Text(debt.type.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                if !debt.isPaid {
                    Button("Погасить") {
                        withAnimation {
                            debtStore.markAsPaid(debt)
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                } else {
                    Text("Погашен")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

struct CategoryStatisticsView: View {
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("По категориям")
                .font(.headline)
                .foregroundColor(.white)
            
            let categoryGroups = debtStore.debtsByCategory()
            
            VStack(spacing: 12) {
                ForEach(Debt.DebtCategory.allCases, id: \.self) { category in
                    if let debts = categoryGroups[category], !debts.isEmpty {
                        CategoryRow(category: category, debts: debts)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
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
            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text("\(activeCount) активных")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(String(format: "%.0f ₽", totalAmount))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Недавняя активность")
                .font(.headline)
                .foregroundColor(.white)
            
            if recentDebts.isEmpty {
                Text("Нет недавней активности")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(recentDebts) { debt in
                        RecentActivityRow(debt: debt)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct RecentActivityRow: View {
    let debt: Debt
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.debtorName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(debt.dateCreated, formatter: recentDateFormatter)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack {
                if debt.isPaid {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                Text(debt.formattedAmount)
                    .font(.system(size: 16))
                    .foregroundColor(debt.isPaid ? .green : .white)
            }
        }
        .padding(.vertical, 4)
    }
}

struct OverdueDebtsView: View {
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Просроченные долги")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                ForEach(debtStore.overdueDebts) { debt in
                    OverdueDebtRow(debt: debt)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
        )
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
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.debtorName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                if let dueDate = debt.dueDate {
                    Text("Просрочен с \(dueDate, formatter: dateFormatter)")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(debt.formattedAmount)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.red)
                
                Button("Погасить") {
                    withAnimation {
                        debtStore.markAsPaid(debt)
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(.blue)
            }
        }
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

private let shortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

#Preview {
    StatisticsView()
        .environmentObject(DebtStore())
        .preferredColorScheme(.dark)
}