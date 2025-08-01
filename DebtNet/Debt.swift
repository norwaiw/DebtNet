import Foundation

struct Debt: Identifiable, Codable {
    var id = UUID()
    var debtorName: String
    var amount: Double
    var description: String
    let dateCreated: Date
    var dueDate: Date?
    var isPaid: Bool = false
    var category: DebtCategory
    var type: DebtType
    var interestRate: Double = 0.0  // Процентная ставка (в процентах)
    
    enum DebtCategory: String, CaseIterable, Codable {
        case personal = "Личный"
        case business = "Деловой"
        case family = "Семейный"
        case friend = "Дружеский"
        case other = "Другое"
    }
    
    enum DebtType: String, CaseIterable, Codable {
        case owedToMe = "Мне должны"    // Someone owes me money
        case iOwe = "Я должен"          // I owe someone money
    }
    
    var formattedAmount: String {
        return String(format: "%.0f ₽", amount)
    }
    
    // Сумма с процентами
    var amountWithInterest: Double {
        return amount * (1 + interestRate / 100)
    }
    
    var formattedAmountWithInterest: String {
        return String(format: "%.0f ₽", amountWithInterest)
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isPaid && Date() > dueDate
    }
    
    var amountWithSign: String {
        let sign = type == .owedToMe ? "" : "-"
        return "\(sign)\(String(format: "%.0f", amount)) ₽"
    }
    
    var amountWithInterestAndSign: String {
        let sign = type == .owedToMe ? "" : "-"
        return "\(sign)\(String(format: "%.0f", amountWithInterest)) ₽"
    }
}
