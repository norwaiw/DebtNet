import SwiftUI

struct AddDebtView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var debtStore: DebtStore
    
    @State private var debtorName = ""
    @State private var amount = ""
    @State private var description = ""
    @State private var category: Debt.DebtCategory = .personal
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о должнике")) {
                    TextField("Имя должника", text: $debtorName)
                        .autocapitalization(.words)
                    
                    TextField("Описание долга", text: $description)
                        .autocapitalization(.sentences)
                }
                
                Section(header: Text("Сумма и категория")) {
                    HStack {
                        TextField("Сумма", text: $amount)
                            .keyboardType(.decimalPad)
                        Text("₽")
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Категория", selection: $category) {
                        ForEach(Debt.DebtCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Срок погашения")) {
                    Toggle("Установить срок погашения", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Дата погашения", selection: $dueDate, displayedComponents: .date)
                    }
                }
                
                Section {
                    Button("Добавить долг") {
                        addDebt()
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Новый долг")
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Готово") {
                    addDebt()
                }
                .disabled(!isFormValid)
            )
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private var isFormValid: Bool {
        !debtorName.isEmpty && !amount.isEmpty && Double(amount) != nil && Double(amount)! > 0
    }
    
    private func addDebt() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Введите корректную сумму долга"
            showingAlert = true
            return
        }
        
        guard !debtorName.isEmpty else {
            alertMessage = "Введите имя должника"
            showingAlert = true
            return
        }
        
        let newDebt = Debt(
            debtorName: debtorName.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amountValue,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            dateCreated: Date(),
            dueDate: hasDueDate ? dueDate : nil,
            category: category
        )
        
        debtStore.addDebt(newDebt)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddDebtView()
        .environmentObject(DebtStore())
}