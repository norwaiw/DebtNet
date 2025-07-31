import SwiftUI

struct DebtDetailView: View {
    let debt: Debt
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditDebt = false
    @State private var showingDeleteAlert = false
    @State private var showingStatusChangeAlert = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        amountSection
                        detailsSection
                        datesSection
                        actionsSection
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Удалить долг", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                debtStore.deleteDebt(debt)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Вы уверены, что хотите удалить долг от \(debt.debtorName) на сумму \(debt.formattedAmount)?")
        }
        .alert(debt.isPaid ? "Вернуть долг в активное состояние?" : "Отметить долг как погашенный?", isPresented: $showingStatusChangeAlert) {
            Button("Отмена", role: .cancel) { }
            Button(debt.isPaid ? "Вернуть" : "Погасить") {
                debtStore.togglePaidStatus(debt)
            }
        } message: {
            Text(debt.isPaid ? 
                 "Долг от \(debt.debtorName) на сумму \(debt.formattedAmount) будет возвращён в активное состояние" :
                 "Вы уверены, что долг от \(debt.debtorName) на сумму \(debt.formattedAmount) погашен?")
        }
        .sheet(isPresented: $showingEditDebt) {
            EditDebtView(debt: debt)
                .environmentObject(debtStore)
                .environmentObject(themeManager)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(themeManager.primaryTextColor)
                        .font(.title2)
                }
                
                Spacer()
                
                Text("Детали долга")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.primaryTextColor)
                
                Spacer()
                
                Button(action: {
                    showingEditDebt = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(Color(.systemGray))
                        .font(.title2)
                }
            }
            
            // Status indicator
            if debt.isPaid {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("ПОГАШЕН")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.opacity(0.2))
                )
            }
        }
    }
    
    private var amountSection: some View {
        VStack(spacing: 16) {
            // Large amount display
            VStack(spacing: 8) {
                Text(debt.amountWithSign)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(debt.type == .owedToMe ? .green : .red)
                
                Text("RUB")
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            
            // Type indicator
            HStack {
                Circle()
                    .fill(debt.type == .owedToMe ? Color.green : Color.red)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: debt.type == .owedToMe ? "arrow.down" : "arrow.up")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .bold))
                    )
                
                Text(debt.type.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.primaryTextColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackgroundColor)
                .shadow(color: themeManager.shadowColor, radius: 3, x: 0, y: 2)
        )
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Информация")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryTextColor)
            
            VStack(spacing: 12) {
                DetailRow(title: "Должник", value: debt.debtorName)
                DetailRow(title: "Описание", value: debt.description.isEmpty ? "Не указано" : debt.description)
                DetailRow(title: "Категория", value: debt.category.rawValue)
                
                if debt.isOverdue && !debt.isPaid {
                    HStack {
                        Text("Статус")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.secondaryTextColor)
                        
                        Spacer()
                        
                        Text("ПРОСРОЧЕН")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.2))
                            )
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
    
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Даты")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryTextColor)
            
            VStack(spacing: 12) {
                DetailRow(
                    title: "Дата создания",
                    value: "\(dateFormatter.string(from: debt.dateCreated)) в \(timeFormatter.string(from: debt.dateCreated))"
                )
                
                if let dueDate = debt.dueDate {
                    DetailRow(
                        title: "Срок возврата",
                        value: dateFormatter.string(from: dueDate),
                        valueColor: debt.isOverdue && !debt.isPaid ? .red : nil
                    )
                } else {
                    DetailRow(title: "Срок возврата", value: "Не установлен")
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
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Mark as paid/unpaid button
            Button(action: {
                showingStatusChangeAlert = true
            }) {
                HStack {
                    Image(systemName: debt.isPaid ? "arrow.uturn.left.circle" : "checkmark.circle")
                        .font(.system(size: 20))
                    
                    Text(debt.isPaid ? "Вернуть в активные" : "Отметить как погашенный")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(debt.isPaid ? Color.orange : Color.green)
                )
            }
            
            // Delete button
            Button(action: {
                showingDeleteAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                    
                    Text("Удалить долг")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red)
                )
            }
        }
    }
}

struct DetailRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let value: String
    var valueColor: Color?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(themeManager.secondaryTextColor)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(valueColor ?? themeManager.primaryTextColor)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    DebtDetailView(debt: Debt(
        debtorName: "Sample User",
        amount: 1000,
        description: "Sample description",
        dateCreated: Date(),
        dueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
        category: .personal,
        type: .owedToMe
    ))
    .environmentObject(DebtStore())
    .environmentObject(ThemeManager())
}