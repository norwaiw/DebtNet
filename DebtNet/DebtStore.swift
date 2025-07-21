import Foundation
import SwiftUI

class DebtStore: ObservableObject {
    @Published var debts: [Debt] = []
    
    private let saveKey = "SavedDebts"
    
    init() {
        loadDebts()
        // Clear all existing data including sample data
        clearAllData()
    }
    
    func addDebt(_ debt: Debt) {
        debts.append(debt)
        saveDebts()
    }
    
    func updateDebt(_ debt: Debt) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            debts[index] = debt
            saveDebts()
        }
    }
    
    func deleteDebt(_ debt: Debt) {
        debts.removeAll { $0.id == debt.id }
        saveDebts()
    }
    
    func clearAllData() {
        debts.removeAll()
        saveDebts()
    }
    
    func markAsPaid(_ debt: Debt) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            debts[index].isPaid = true
            saveDebts()
        }
    }
    
    // MARK: - Statistics
    var totalOwedToMe: Double {
        debts.filter { !$0.isPaid && $0.type == .owedToMe }.reduce(0) { $0 + $1.amount }
    }
    
    var totalIOwe: Double {
        debts.filter { !$0.isPaid && $0.type == .iOwe }.reduce(0) { $0 + $1.amount }
    }
    
    var totalDebtAmount: Double {
        debts.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    var totalPaidAmount: Double {
        debts.filter { $0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    var overdueDebts: [Debt] {
        debts.filter { $0.isOverdue }
    }
    
    var activeDebts: [Debt] {
        debts.filter { !$0.isPaid }
    }
    
    var paidDebts: [Debt] {
        debts.filter { $0.isPaid }
    }
    
    var debtsOwedToMe: [Debt] {
        debts.filter { $0.type == .owedToMe }
    }
    
    var debtsIOwe: [Debt] {
        debts.filter { $0.type == .iOwe }
    }
    
    func debtsByCategory() -> [Debt.DebtCategory: [Debt]] {
        Dictionary(grouping: debts) { $0.category }
    }
    
    // MARK: - Sample Data
    private func addSampleData() {
        let sampleDebts = [
            Debt(
                debtorName: "Иван Петров",
                amount: 5000,
                description: "За ужин в ресторане",
                dateCreated: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
                dueDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()),
                category: .friend,
                type: .owedToMe
            ),
            Debt(
                debtorName: "Мария Сидорова",
                amount: 15000,
                description: "Займ на ремонт",
                dateCreated: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()),
                category: .personal,
                type: .iOwe
            ),
            Debt(
                debtorName: "Алексей Козлов",
                amount: 3000,
                description: "Билеты на концерт",
                dateCreated: Date(),
                dueDate: nil,
                category: .friend,
                type: .owedToMe
            )
        ]
        
        for debt in sampleDebts {
            debts.append(debt)
        }
        saveDebts()
    }
    
    // MARK: - Persistence
    private func saveDebts() {
        if let encoded = try? JSONEncoder().encode(debts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadDebts() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Debt].self, from: data) {
            debts = decoded
        }
    }
}