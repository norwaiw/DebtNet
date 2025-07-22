import SwiftUI

struct DebtListView: View {
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingAddDebt = false
    @State private var selectedFilter: FilterOption = .all
    @State private var showingDeleteAlert = false
    @State private var debtToDelete: Debt?
    @State private var archiveOffset: CGFloat = 0
    @State private var showingArchive = false
    @State private var dragOffset: CGFloat = 0
    @State private var showingNotificationSettings = false
    
    enum FilterOption: String, CaseIterable {
        case all = "Все"
        case owedToMe = "Мне должны"
        case iOwe = "Я должен"
    }
    
    var filteredDebts: [Debt] {
        switch selectedFilter {
        case .all:
            return debtStore.activeDebts.sorted { $0.dateCreated > $1.dateCreated }
        case .owedToMe:
            return debtStore.activeDebts.filter { $0.type == .owedToMe }.sorted { $0.dateCreated > $1.dateCreated }
        case .iOwe:
            return debtStore.activeDebts.filter { $0.type == .iOwe }.sorted { $0.dateCreated > $1.dateCreated }
        }
    }
    
    var archivedDebts: [Debt] {
        return debtStore.paidDebts.sorted { $0.dateCreated > $1.dateCreated }
    }
    
    var upcomingDebtsCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: now) ?? now
        
        return debtStore.activeDebts.filter { debt in
            guard let dueDate = debt.dueDate else { return false }
            return dueDate > now && dueDate <= nextWeek
        }.count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    mainContentView
                    archiveSection
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddDebt) {
            AddDebtView()
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
                .environmentObject(themeManager)
        }
        .alert("Удалить долг", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                if let debt = debtToDelete {
                    debtStore.deleteDebt(debt)
                }
                debtToDelete = nil
            }
        } message: {
            if let debt = debtToDelete {
                Text("Вы уверены, что хотите удалить долг от \(debt.debtorName) на сумму \(debt.formattedAmount)?")
            }
        }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 20) {
            headerView
            filterButtonsView
            summaryCardsView
            archiveIndicatorView
            debtListView
            Spacer()
        }
        .offset(y: dragOffset * 0.3)
    }
    
    private var headerView: some View {
        HStack {
            Text("История долгов")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryTextColor)
            
            Spacer()
            
            // Notification button
            Button(action: {
                showingNotificationSettings = true
            }) {
                ZStack {
                    Image(systemName: notificationManager.isNotificationEnabled ? "bell.fill" : "bell.slash")
                        .foregroundColor(notificationManager.isNotificationEnabled ? .blue : .gray)
                        .font(.title3)
                    
                    // Badge for pending notifications
                    if notificationManager.isNotificationEnabled && upcomingDebtsCount > 0 {
                        Text("\(upcomingDebtsCount)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(Circle().fill(Color.red))
                            .offset(x: 8, y: -8)
                    }
                }
            }
            .padding(.trailing, 8)
            
            Button(action: {
                showingAddDebt = true
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.gray)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.red))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
    
    private var filterButtonsView: some View {
        HStack(spacing: 12) {
            ForEach(FilterOption.allCases, id: \.self) { option in
                Button(action: {
                    selectedFilter = option
                }) {
                    Text(option.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedFilter == option ? .white : themeManager.secondaryTextColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedFilter == option ? Color.red : themeManager.cardBackgroundColor)
                                .shadow(color: themeManager.shadowColor, radius: 1, x: 0, y: 1)
                        )
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var summaryCardsView: some View {
        HStack(spacing: 16) {
            owedToMeCard
            iOweCard
        }
        .padding(.horizontal)
    }
    
    private var owedToMeCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Мне должны")
                .font(.system(size: 14))
                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.7) : themeManager.secondaryTextColor)
            
            // Display amount with interest as the main amount (without the "С %" line)
            Text("\(Int(debtStore.totalOwedToMeWithInterest)) ₽")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.green)
            
            // Add spacing to match the other card height
            Text(" ")
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.owedToMeCardBackground)
                .shadow(color: themeManager.shadowColor, radius: 2, x: 0, y: 1)
        )
    }
    
    private var iOweCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Я должен")
                .font(.system(size: 14))
                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.7) : themeManager.secondaryTextColor)
            
            Text("\(Int(debtStore.totalIOwe)) ₽")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.red)
            
            // Add spacing to match the other card height
            Text(" ")
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.iOweCardBackground)
                .shadow(color: themeManager.shadowColor, radius: 2, x: 0, y: 1)
        )
    }
    
    @ViewBuilder
    private var archiveIndicatorView: some View {
        if !archivedDebts.isEmpty {
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("Архив (\(archivedDebts.count))")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.secondaryTextColor)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.secondaryTextColor)
                        .rotationEffect(.degrees(showingArchive ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: showingArchive)
                }
                Spacer()
            }
            .padding(.horizontal)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingArchive = true
                }
            }
        }
    }
    
    private var debtListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredDebts) { debt in
                    DebtHistoryRowView(debt: debt)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                debtToDelete = debt
                                showingDeleteAlert = true
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                            .tint(.red)
                            
                            Button {
                                debtStore.togglePaidStatus(debt)
                            } label: {
                                Label("Оплачено", systemImage: "checkmark")
                            }
                            .tint(.green)
                        }
                }
            }
            .padding(.horizontal)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 && !archivedDebts.isEmpty {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height > 100 && !archivedDebts.isEmpty {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingArchive = true
                        }
                    }
                    dragOffset = 0
                }
        )
    }
    
    @ViewBuilder
    private var archiveSection: some View {
        if showingArchive && !archivedDebts.isEmpty {
            VStack(spacing: 16) {
                archiveHeaderView
                archiveListView
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeManager.cardBackgroundColor)
                    .shadow(color: themeManager.shadowColor, radius: 3, x: 0, y: 2)
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private var archiveHeaderView: some View {
        HStack {
            Text("Архив погашенных долгов")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryTextColor)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingArchive = false
                }
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(themeManager.secondaryTextColor)
                    .font(.title3)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var archiveListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(archivedDebts) { debt in
                    ArchivedDebtRowView(debt: debt)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                debtToDelete = debt
                                showingDeleteAlert = true
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                            .tint(.red)
                            
                            Button {
                                debtStore.togglePaidStatus(debt)
                            } label: {
                                Label("Вернуть", systemImage: "arrow.uturn.left")
                            }
                            .tint(.orange)
                        }
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 400)
    }
}

struct DebtHistoryRowView: View {
    let debt: Debt
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingStatusChangeAlert = false
    @State private var swipeOffset: CGFloat = 0
    @State private var showingDeleteButton = false
    @State private var showingDetail = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    // Split the complex view into smaller computed properties
    private var deleteButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                swipeOffset = 0
                showingDeleteButton = false
            }
            // Add a small delay before showing the alert
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                debtStore.deleteDebt(debt)
            }
        }) {
            VStack {
                Image(systemName: "trash.fill")
                    .font(.system(size: 20, weight: .bold))
                Text("Удалить")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(width: 80, height: 60)
            .background(Color.red)
            .cornerRadius(12)
        }
        .padding(.trailing, 16)
    }
    
    private var debtIcon: some View {
        Circle()
            .fill(debt.type == .owedToMe ? Color.green : Color.red)
            .frame(width: 40, height: 40)
            .overlay(
                Image(systemName: debt.type == .owedToMe ? "arrow.down" : "arrow.up")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
            )
    }
    
    private var debtInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(debt.debtorName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.primaryTextColor)
            
            Text(debt.description)
                .font(.system(size: 14))
                .foregroundColor(themeManager.secondaryTextColor)
                .lineLimit(1)
            
            Text(dateFormatter.string(from: debt.dateCreated))
                .font(.system(size: 12))
                .foregroundColor(themeManager.secondaryTextColor)
        }
    }
    
    private var amountSection: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(debt.amountWithSign)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(debt.type == .owedToMe ? .green : .red)
            
            if debt.interestRate > 0 {
                Text(debt.amountWithInterestAndSign)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor((debt.type == .owedToMe ? Color.green : Color.red).opacity(0.8))
                
                Text("\(String(format: "%.1f", debt.interestRate))%")
                    .font(.system(size: 10))
                    .foregroundColor(themeManager.secondaryTextColor)
            } else {
                Text("RUB")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            // Quick status toggle button
            Button(action: {
                showingStatusChangeAlert = true
            }) {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                    .font(.system(size: 20))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var mainContent: some View {
        HStack(spacing: 16) {
            debtIcon
            debtInfo
            Spacer()
            amountSection
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackgroundColor)
                .shadow(color: themeManager.shadowColor, radius: 2, x: 0, y: 1)
        )
        .offset(x: swipeOffset)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .gesture(swipeGesture)
    }
    
    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Only allow swiping left (negative translation)
                if value.translation.width < 0 {
                    withAnimation(.easeOut(duration: 0.1)) {
                        swipeOffset = max(value.translation.width, -100)
                        showingDeleteButton = swipeOffset < -50
                    }
                }
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if value.translation.width < -80 {
                        // If swiped far enough, show delete button
                        swipeOffset = -100
                        showingDeleteButton = true
                    } else {
                        // Snap back to original position
                        swipeOffset = 0
                        showingDeleteButton = false
                    }
                }
            }
    }
    
    var body: some View {
        ZStack {
            // Background delete action
            HStack {
                Spacer()
                if showingDeleteButton {
                    deleteButton
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            mainContent
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                debtStore.deleteDebt(debt)
            } label: {
                Label("Удалить", systemImage: "trash")
            }
            .tint(.red)
            
            Button {
                debtStore.togglePaidStatus(debt)
            } label: {
                Label("Оплачено", systemImage: "checkmark")
            }
            .tint(.green)
        }
        .alert("Отметить долг как погашенный?", isPresented: $showingStatusChangeAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Погасить", role: .destructive) {
                debtStore.togglePaidStatus(debt)
            }
        } message: {
            Text("Вы уверены, что долг от \(debt.debtorName) на сумму \(debt.formattedAmount) погашен?")
        }
        .sheet(isPresented: $showingDetail) {
            DebtDetailView(debt: debt)
                .environmentObject(themeManager)
        }
    }
}

struct ArchivedDebtRowView: View {
    let debt: Debt
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingStatusChangeAlert = false
    @State private var swipeOffset: CGFloat = 0
    @State private var showingDeleteButton = false
    @State private var showingDetail = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    // Split the complex view into smaller computed properties
    private var deleteButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                swipeOffset = 0
                showingDeleteButton = false
            }
            // Add a small delay before deleting
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                debtStore.deleteDebt(debt)
            }
        }) {
            VStack {
                Image(systemName: "trash.fill")
                    .font(.system(size: 20, weight: .bold))
                Text("Удалить")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(width: 80, height: 60)
            .background(Color.red)
            .cornerRadius(12)
        }
        .padding(.trailing, 16)
    }
    
    private var archivedIcon: some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 40, height: 40)
            .overlay(
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
            )
    }
    
    private var archivedDebtInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(debt.debtorName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.secondaryTextColor)
                    .strikethrough(true)
                
                Text("ПОГАШЕН")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.2))
                    )
            }
            
            Text(debt.description)
                .font(.system(size: 14))
                .foregroundColor(themeManager.secondaryTextColor)
                .lineLimit(1)
            
            Text(dateFormatter.string(from: debt.dateCreated))
                .font(.system(size: 12))
                .foregroundColor(themeManager.secondaryTextColor)
        }
    }
    
    private var archivedAmountSection: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(debt.amountWithSign)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(themeManager.secondaryTextColor)
                .strikethrough(true)
            
            if debt.interestRate > 0 {
                Text(debt.amountWithInterestAndSign)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.secondaryTextColor.opacity(0.8))
                    .strikethrough(true)
                
                Text("\(String(format: "%.1f", debt.interestRate))%")
                    .font(.system(size: 10))
                    .foregroundColor(themeManager.secondaryTextColor)
            } else {
                Text("RUB")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            // Quick status toggle button
            Button(action: {
                showingStatusChangeAlert = true
            }) {
                Image(systemName: "arrow.uturn.left.circle")
                    .foregroundColor(.orange)
                    .font(.system(size: 20))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var archivedMainContent: some View {
        HStack(spacing: 16) {
            archivedIcon
            archivedDebtInfo
            Spacer()
            archivedAmountSection
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardSecondaryBackgroundColor)
                .shadow(color: themeManager.shadowColor, radius: 1, x: 0, y: 1)
        )
        .opacity(0.7)
        .offset(x: swipeOffset)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .gesture(archivedSwipeGesture)
    }
    
    private var archivedSwipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Only allow swiping left (negative translation)
                if value.translation.width < 0 {
                    withAnimation(.easeOut(duration: 0.1)) {
                        swipeOffset = max(value.translation.width, -100)
                        showingDeleteButton = swipeOffset < -50
                    }
                }
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if value.translation.width < -80 {
                        // If swiped far enough, show delete button
                        swipeOffset = -100
                        showingDeleteButton = true
                    } else {
                        // Snap back to original position
                        swipeOffset = 0
                        showingDeleteButton = false
                    }
                }
            }
    }
    
    var body: some View {
        ZStack {
            // Background delete action
            HStack {
                Spacer()
                if showingDeleteButton {
                    deleteButton
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            archivedMainContent
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                debtStore.deleteDebt(debt)
            } label: {
                Label("Удалить", systemImage: "trash")
            }
            .tint(.red)
            
            Button {
                debtStore.togglePaidStatus(debt)
            } label: {
                Label("Вернуть", systemImage: "arrow.uturn.left")
            }
            .tint(.orange)
        }
        .alert("Вернуть долг в активное состояние?", isPresented: $showingStatusChangeAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Вернуть", role: .none) {
                debtStore.togglePaidStatus(debt)
            }
        } message: {
            Text("Долг от \(debt.debtorName) на сумму \(debt.formattedAmount) будет возвращён в активное состояние")
        }
        .sheet(isPresented: $showingDetail) {
            DebtDetailView(debt: debt)
                .environmentObject(themeManager)
        }
    }
}

#Preview {
    DebtListView()
        .environmentObject(DebtStore())
        .environmentObject(ThemeManager())
}