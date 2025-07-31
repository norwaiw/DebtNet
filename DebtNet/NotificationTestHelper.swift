import Foundation
import UserNotifications

class NotificationTestHelper {
    
    // Создать тестовые уведомления с короткими интервалами для демонстрации
    static func scheduleTestNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Тестовое уведомление"
        content.body = "Это тестовое уведомление системы напоминаний о долгах"
        content.sound = .default
        
        // Тестовое уведомление через 10 секунд
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка при создании тестового уведомления: \(error)")
            } else {
                print("Тестовое уведомление запланировано на 10 секунд")
            }
        }
    }
    
    // Создать тестовые уведомления для демонстрации разных типов
    static func scheduleTestDebtNotifications() {
        // Уведомление о должнике через 30 секунд
        let content1 = UNMutableNotificationContent()
        content1.title = "Напоминание о долге"
        content1.body = "Через неделю истекает срок долга."
        content1.sound = .default
        
        let trigger1 = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request1 = UNNotificationRequest(identifier: "test_debt_week", content: content1, trigger: trigger1)
        
        // Срочное уведомление через 60 секунд
        let content2 = UNMutableNotificationContent()
        content2.title = "Срочное напоминание о долге"
        content2.body = "Завтра истекает срок долга!"
        content2.sound = .default
        
        let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request2 = UNNotificationRequest(identifier: "test_debt_day", content: content2, trigger: trigger2)
        
        // Уведомление о дне платежа через 90 секунд
        let content3 = UNMutableNotificationContent()
        content3.title = "Сегодня день платежа!"
        content3.body = "Сегодня крайний день!"
        content3.sound = .default
        
        let trigger3 = UNTimeIntervalNotificationTrigger(timeInterval: 90, repeats: false)
        let request3 = UNNotificationRequest(identifier: "test_debt_due", content: content3, trigger: trigger3)
        
        UNUserNotificationCenter.current().add(request1) { _ in }
        UNUserNotificationCenter.current().add(request2) { _ in }
        UNUserNotificationCenter.current().add(request3) { _ in }
        
        print("Запланированы тестовые уведомления: через 30, 60 и 90 секунд")
    }
}