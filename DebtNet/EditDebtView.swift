import SwiftUI

struct EditDebtView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var themeManager: ThemeManager
    
    let debt: Debt
    
    @State private var debtorName: String
    @State private var amount: String
    @State private var description: String
    @State private var category: Debt.DebtCategory
    @State private var debtType: Debt.DebtType
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var interestRate: String
    @State private var hasInterest: Bool
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(debt: Debt) {
        self.debt = debt
        _debtorName = State(initialValue: debt.debtorName)
        _amount = State(initialValue: String(format: "%.0f", debt.amount))
        _description = State(initialValue: debt.description)
        _category = State(initialValue: debt.category)
        _debtType = State(initialValue: debt.type)
        _hasDueDate = State(initialValue: debt.dueDate != nil)
        _dueDate = State(initialValue: debt.dueDate ?? Date())
        _interestRate = State(initialValue: debt.interestRate > 0 ? String(format: "%.1f", debt.interestRate) : "")
        _hasInterest = State(initialValue: debt.interestRate > 0)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            Button("Отмена") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .foregroundColor(themeManager.secondaryTextColor)
                            
                            Spacer()
                            
                            Text("Редактировать долг")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.primaryTextColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Spacer()
                            
                            Button("Сохранить") {
                                updateDebt()
                            }
                            .foregroundColor(isFormValid ? .gray : themeManager.secondaryTextColor)
                            .disabled(!isFormValid)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        VStack(spacing: 20) {
                            // Debt Type Selection
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Тип долга")
                                    .font(.headline)
                                    .foregroundColor(themeManager.primaryTextColor)
                                
                                HStack(spacing: 12) {
                                    ForEach(Debt.DebtType.allCases, id: \.self) { type in
                                        Button(action: {
                                            debtType = type
                                        }) {
                                            Text(type.rawValue)
                                                .font(.system(size: 16))
                                                .foregroundColor(debtType == type ? .white : themeManager.secondaryTextColor)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 25)
                                                        .fill(debtType == type ? 
                                                              (type == .owedToMe ? Color.green : Color.red) : 
                                                              themeManager.cardBackgroundColor)
                                                        .shadow(color: themeManager.shadowColor, radius: 1, x: 0, y: 1)
                                                )
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            
                            // Person Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text(debtType == .owedToMe ? "Имя должника" : "Кому должен")
                                    .font(.headline)
                                    .foregroundColor(themeManager.primaryTextColor)
                                
                                TextField(debtType == .owedToMe ? "Введите имя должника" : "Введите имя кредитора", text: $debtorName)
                                    .textFieldStyle(DarkTextFieldStyle())
                            }
                            .padding(.horizontal)
                            
                            // Amount
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Сумма")
                                    .font(.headline)
                                    .foregroundColor(themeManager.primaryTextColor)
                                
                                HStack {
                                    TextField("0", text: $amount)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(DarkTextFieldStyle())
                                    
                                    Text("₽")
                                        .foregroundColor(themeManager.secondaryTextColor)
                                        .padding(.trailing, 12)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Interest Rate
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Процентная ставка")
                                        .font(.headline)
                                        .foregroundColor(themeManager.primaryTextColor)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $hasInterest)
                                        .labelsHidden()
                                }
                                
                                if hasInterest {
                                    HStack {
                                        TextField("0", text: $interestRate)
                                            .keyboardType(.decimalPad)
                                            .textFieldStyle(DarkTextFieldStyle())
                                        
                                        Text("%")
                                            .foregroundColor(themeManager.secondaryTextColor)
                                            .padding(.trailing, 12)
                                    }
                                    
                                    if let amountValue = Double(amount), let rateValue = Double(interestRate), amountValue > 0, rateValue >= 0 {
                                        let totalAmount = amountValue * (1 + rateValue / 100)
                                        Text("Итого с процентами: \(String(format: "%.0f", totalAmount)) ₽")
                                            .font(.system(size: 14))
                                            .foregroundColor(.green)
                                            .padding(.top, 4)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Описание")
                                    .font(.headline)
                                    .foregroundColor(themeManager.primaryTextColor)
                                
                                TextField("За что долг?", text: $description)
                                    .textFieldStyle(DarkTextFieldStyle())
                            }
                            .padding(.horizontal)
                            
                            // Category
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Категория")
                                    .font(.headline)
                                    .foregroundColor(themeManager.primaryTextColor)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(Debt.DebtCategory.allCases, id: \.self) { cat in
                                            Button(action: {
                                                category = cat
                                            }) {
                                                Text(cat.rawValue)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(category == cat ? .white : themeManager.secondaryTextColor)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .fill(category == cat ? Color.gray.opacity(0.8) : themeManager.cardBackgroundColor)
                                                        .shadow(color: themeManager.shadowColor, radius: 1, x: 0, y: 1)
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Due Date
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Срок погашения")
                                        .font(.headline)
                                        .foregroundColor(themeManager.primaryTextColor)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $hasDueDate)
                                        .labelsHidden()
                                }
                                
                                if hasDueDate {
                                    DatePicker("Дата погашения", selection: $dueDate, displayedComponents: .date)
                                        .datePickerStyle(WheelDatePickerStyle())
                                        .labelsHidden()
                                        .colorScheme(themeManager.isDarkMode ? .dark : .light)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private var isFormValid: Bool {
        !debtorName.isEmpty && !amount.isEmpty && Double(amount) != nil && Double(amount)! > 0
    }
    
    private func updateDebt() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Введите корректную сумму долга"
            showingAlert = true
            return
        }
        
        guard !debtorName.isEmpty else {
            alertMessage = "Введите имя"
            showingAlert = true
            return
        }
        
        let interestRateValue = hasInterest ? (Double(interestRate) ?? 0.0) : 0.0
        
        var updatedDebt = debt
        updatedDebt.debtorName = debtorName.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDebt.amount = amountValue
        updatedDebt.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDebt.category = category
        updatedDebt.type = debtType
        updatedDebt.dueDate = hasDueDate ? dueDate : nil
        updatedDebt.interestRate = interestRateValue
        
        debtStore.updateDebt(updatedDebt)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    EditDebtView(debt: Debt(
        debtorName: "Фадей",
        amount: 10000,
        description: "ТОРЧИТ СУЧКА",
        dateCreated: Date(),
        dueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
        category: .personal,
        type: .owedToMe,
        interestRate: 5.0
    ))
    .environmentObject(DebtStore())
    .environmentObject(ThemeManager())
}