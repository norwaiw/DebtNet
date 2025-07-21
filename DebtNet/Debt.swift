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
    
    enum DebtCategory: String, CaseIterable, Codable {
        case personal = "Личный"
        case business = "Деловой"
        case family = "Семейный"
        case friend = "Дружеский"
        case other = "Другое"
    }
    
    var formattedAmount: String {
        return String(format: "%.2f ₽", amount)
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isPaid && Date() > dueDate
    }
}