import SwiftUI

struct DebtListView: View {
    @EnvironmentObject var debtStore: DebtStore
    @State private var showingAddDebt = false
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "Все"
        case active = "Активные"
        case paid = "Погашенные"
        case overdue = "Просроченные"
    }
    
    var filteredDebts: [Debt] {
        let filtered = debtStore.debts.filter { debt in
            switch selectedFilter {
            case .all:
                return true
            case .active:
                return !debt.isPaid
            case .paid:
                return debt.isPaid
            case .overdue:
                return debt.isOverdue
            }
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { debt in
                debt.debtorName.localizedCaseInsensitiveContains(searchText) ||
                debt.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Picker
                Picker("Фильтр", selection: $selectedFilter) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Search Bar
                SearchBar(text: $searchText)
                
                // Debt List
                List {
                    ForEach(filteredDebts) { debt in
                        DebtRowView(debt: debt)
                    }
                    .onDelete(perform: deleteDebts)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("DebtNet")
            .navigationBarItems(trailing: Button(action: {
                showingAddDebt = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddDebt) {
                AddDebtView()
            }
        }
    }
    
    func deleteDebts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                debtStore.deleteDebt(filteredDebts[index])
            }
        }
    }
}

struct DebtRowView: View {
    let debt: Debt
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.debtorName)
                    .font(.headline)
                    .foregroundColor(debt.isPaid ? .secondary : .primary)
                
                Text(debt.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(debt.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    
                    if debt.isOverdue {
                        Text("Просрочен")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(debt.formattedAmount)
                    .font(.headline)
                    .foregroundColor(debt.isPaid ? .green : (debt.isOverdue ? .red : .primary))
                
                if let dueDate = debt.dueDate {
                    Text("До: \(dueDate, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !debt.isPaid {
                    Button("Погасить") {
                        withAnimation {
                            debtStore.markAsPaid(debt)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(debt.isPaid ? 0.6 : 1.0)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Поиск должников...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

#Preview {
    DebtListView()
        .environmentObject(DebtStore())
}