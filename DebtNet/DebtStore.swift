import Foundation
import SwiftUI

class DebtStore: ObservableObject {
    @Published var debts: [Debt] = []
    
    private let saveKey = "SavedDebts"
    
    init() {
        loadDebts()
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
    
    func markAsPaid(_ debt: Debt) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            debts[index].isPaid = true
            saveDebts()
        }
    }
    
    // MARK: - Statistics
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
    
    func debtsByCategory() -> [Debt.DebtCategory: [Debt]] {
        Dictionary(grouping: debts) { $0.category }
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