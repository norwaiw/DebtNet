import SwiftUI

struct AddPaymentView: View {
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var themeManager: ThemeManager
    
    @Environment(\.dismiss) private var dismiss
    
    let debt: Debt
    
    @State private var paymentText: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var paymentAmount: Double {
        Double(paymentText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Сумма платежа")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    HStack {
                        TextField("0", text: $paymentText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(ThemedTextFieldStyle())
                        
                        Text("₽")
                            .foregroundColor(themeManager.secondaryTextColor)
                            .padding(.trailing, 12)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationBarItems(
                leading: Button("Отмена") {
                    dismiss()
                },
                trailing: Button("Готово") {
                    addPayment()
                }
                .disabled(!isValid)
                .foregroundColor(isValid ? themeManager.accentColor : themeManager.disabledButtonColor)
            )
            .navigationBarTitle("Новый платеж", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private var isValid: Bool {
        paymentAmount > 0 && paymentAmount <= debt.remainingAmount
    }
    
    private func addPayment() {
        guard isValid else {
            alertMessage = "Введите корректную сумму, не превышающую остаток долга"
            showAlert = true
            return
        }
        debtStore.addPayment(amount: paymentAmount, to: debt)
        dismiss()
    }
}

#Preview {
    AddPaymentView(debt: Debt(debtorName: "Тест", amount: 1000, description: "", dateCreated: Date(), category: .personal, type: .owedToMe))
        .environmentObject(DebtStore())
        .environmentObject(ThemeManager())
}
