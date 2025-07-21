import Foundation

struct Debt: Identifiable, Codable {
    let id = UUID()
    var debtorName: String
    var amount: Double
    var description: String
    var dateCreated: Date
    var dueDate: Date?
    var isPaid: Bool = false
    var category: DebtCategory
    var type: DebtType
    
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
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isPaid && Date() > dueDate
    }
    
    var amountWithSign: String {
        let sign = type == .owedToMe ? "+" : "-"
        return "\(sign)\(String(format: "%.0f", amount))"
    }
}