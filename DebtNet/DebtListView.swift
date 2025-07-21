import SwiftUI

struct DebtListView: View {
    @EnvironmentObject var debtStore: DebtStore
    @State private var showingAddDebt = false
    @State private var selectedFilter: FilterOption = .all
    @State private var showingDeleteAlert = false
    @State private var debtToDelete: Debt?
    @State private var archiveOffset: CGFloat = 0
    @State private var showingArchive = false
    @State private var dragOffset: CGFloat = 0
    
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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    mainContentView
                    archiveSection
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddDebt) {
            AddDebtView()
                .preferredColorScheme(.dark)
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
    }
    
    private var filterButtonsView: some View {
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
    }
    
    private var summaryCardsView: some View {
        HStack(spacing: 16) {
            owedToMeCard
            iOweCard
        }
        .padding(.horizontal)
    }
    
    private var owedToMeCard: some View {
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
    }
    
    private var iOweCard: some View {
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
    
    @ViewBuilder
    private var archiveIndicatorView: some View {
        if !archivedDebts.isEmpty {
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("Архив (\(archivedDebts.count))")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(showingArchive ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: showingArchive)
                }
                Spacer()
            }
            .padding(.horizontal)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingArchive.toggle()
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
                    if value.translation.y > 0 && !archivedDebts.isEmpty {
                        dragOffset = value.translation.y
                    }
                }
                .onEnded { value in
                    if value.translation.y > 100 && !archivedDebts.isEmpty {
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
                    .fill(Color.gray.opacity(0.1))
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private var archiveHeaderView: some View {
        HStack {
            Text("Архив погашенных долгов")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingArchive = false
                }
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
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
    @State private var showingStatusChangeAlert = false
    
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
            
            // Amount and status button
            VStack(alignment: .trailing, spacing: 8) {
                Text(debt.amountWithSign)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(debt.type == .owedToMe ? .green : .red)
                
                Text("RUB")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
        .alert("Отметить долг как погашенный?", isPresented: $showingStatusChangeAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Погасить", role: .destructive) {
                debtStore.togglePaidStatus(debt)
            }
        } message: {
            Text("Вы уверены, что долг от \(debt.debtorName) на сумму \(debt.formattedAmount) погашен?")
        }
    }
}

struct ArchivedDebtRowView: View {
    let debt: Debt
    @EnvironmentObject var debtStore: DebtStore
    @State private var showingStatusChangeAlert = false
    
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
                .fill(Color.gray)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(debt.debtorName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
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
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Text(dateFormatter.string(from: debt.dateCreated))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount and status button
            VStack(alignment: .trailing, spacing: 8) {
                Text(debt.amountWithSign)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.gray)
                    .strikethrough(true)
                
                Text("RUB")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
        .opacity(0.7)
        .alert("Вернуть долг в активное состояние?", isPresented: $showingStatusChangeAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Вернуть", role: .none) {
                debtStore.togglePaidStatus(debt)
            }
        } message: {
            Text("Долг от \(debt.debtorName) на сумму \(debt.formattedAmount) будет возвращён в активное состояние")
        }
    }
}

#Preview {
    DebtListView()
        .environmentObject(DebtStore())
        .preferredColorScheme(.dark)
}