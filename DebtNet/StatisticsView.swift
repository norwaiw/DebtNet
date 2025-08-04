import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var themeManager: ThemeManager
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
            themeManager.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Статистика")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.primaryTextColor)
                        
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
            // Делаем карточки полной ширины и расположенные вертикально
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
    @EnvironmentObject var themeManager: ThemeManager
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
            HStack(spacing: 16) {
                // Левая часть с иконкой и текстом
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundColor(isActive ? .white : color)
                        .font(.title2)
                        .frame(width: 24, height: 24)
                    
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isActive ? .white : (themeManager.isDarkMode ? .white : themeManager.primaryTextColor))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Правая часть с суммой
                Text(formattedValue)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isActive ? .white : color)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? color.opacity(0.8) : themeManager.cardBackgroundColor)
                    .shadow(color: themeManager.shadowColor, radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? color : themeManager.borderColor, lineWidth: isActive ? 2 : 1)
            )
            .scaleEffect(isActive ? 0.98 : 1.0)
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
    @EnvironmentObject var themeManager: ThemeManager
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
                    .foregroundColor(themeManager.primaryTextColor)
                
                Spacer()
                
                Text("\(filteredDebts.count)")
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            if filteredDebts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.largeTitle)
                        .foregroundColor(themeManager.secondaryTextColor)
                    
                    Text("Нет долгов в этой категории")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryTextColor)
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
                .fill(themeManager.cardBackgroundColor)
                .shadow(color: themeManager.shadowColor, radius: 2, x: 0, y: 1)
        )
    }
}

struct FilteredDebtRow: View {
    let debt: Debt
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.debtorName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.primaryTextColor)
                
                Text(debt.description)
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.secondaryTextColor)
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
                            .foregroundColor(themeManager.secondaryTextColor)
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
                    .foregroundColor(themeManager.secondaryTextColor)
                
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
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("По категориям")
                .font(.headline)
                .foregroundColor(themeManager.primaryTextColor)
            
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
                .fill(themeManager.cardBackgroundColor)
                .shadow(color: themeManager.shadowColor, radius: 2, x: 0, y: 1)
        )
    }
}

struct CategoryRow: View {
    @EnvironmentObject var themeManager: ThemeManager
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
                    .foregroundColor(themeManager.primaryTextColor)
                
                Text("\(activeCount) активных")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            Spacer()
            
            Text(String(format: "%.0f ₽", totalAmount))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeManager.primaryTextColor)
        }
        .padding(.vertical, 8)
    }
}

struct RecentActivityView: View {
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var themeManager: ThemeManager
    
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
                .foregroundColor(themeManager.primaryTextColor)
            
            if recentDebts.isEmpty {
                Text("Нет недавней активности")
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryTextColor)
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
                .fill(themeManager.cardBackgroundColor)
                .shadow(color: themeManager.shadowColor, radius: 2, x: 0, y: 1)
        )
    }
}

struct RecentActivityRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let debt: Debt
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.debtorName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.primaryTextColor)
                
                Text(debt.dateCreated, formatter: recentDateFormatter)
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            Spacer()
            
            HStack {
                if debt.isPaid {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                Text(debt.formattedAmount)
                    .font(.system(size: 16))
                    .foregroundColor(debt.isPaid ? .green : themeManager.primaryTextColor)
            }
        }
        .padding(.vertical, 4)
    }
}

struct OverdueDebtsView: View {
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var themeManager: ThemeManager
    
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
                .fill(themeManager.overdueCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.overdueCardBorder, lineWidth: 1)
        )
    }
}

struct OverdueDebtRow: View {
    let debt: Debt
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.debtorName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.primaryTextColor)
                
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
        .environmentObject(ThemeManager())
}