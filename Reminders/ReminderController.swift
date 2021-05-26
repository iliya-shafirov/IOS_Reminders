//
//  ViewController.swift
//  Reminders
//
//  Created by Elena Shafirova on 10.05.2021.
//

import UIKit
import CoreData
import UserNotifications


class ReminderController: UIViewController {
    
    
    @IBOutlet weak var contentTextField: UITextField!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var Date: UIDatePicker!
    
    var selectedReminder:ReminderEntity? = nil
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if (selectedReminder != nil) {
            titleTextField.text = selectedReminder?.title
            contentTextField.text = selectedReminder?.content
            Date.date = (selectedReminder?.date)!
        }
    }
    
    
    
    @IBAction func saveAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        if (selectedReminder == nil) {
            let entity = NSEntityDescription.entity(forEntityName: "ReminderEntity", in: context)
            let newReminder = ReminderEntity(entity: entity!, insertInto: context)
            newReminder.content = contentTextField.text
            newReminder.title = titleTextField.text
            newReminder.date = Date.date
            newReminder.id = reminderData.count as NSNumber
            let content = UNMutableNotificationContent()
            content.title = titleTextField.text!
            content.body = contentTextField.text!
            content.sound = .default
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
                if success {
                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newReminder.date), repeats: false)
                    let request = UNNotificationRequest(identifier: newReminder.id.stringValue, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        if error != nil {
                            print("something went wrong")
                        }
                    })
                    do {
                        try context.save()
                        reminderData.append(newReminder)
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    catch {
                        print("context save error")
                    }
                }
                else if error != nil {
                    print("error occurred")
                }
            })
        } else {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderEntity")
            do {
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let reminder = result as! ReminderEntity
                    if (reminder == selectedReminder) {
                        reminder.content = contentTextField.text!
                        reminder.title = titleTextField.text!
                        reminder.date = Date.date
                        
                        let content = UNMutableNotificationContent()
                        content.title = reminder.title
                        content.body = reminder.content
                        content.sound = .default
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.stringValue])
                        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.date), repeats: false)
                        let request = UNNotificationRequest(identifier: reminder.id.stringValue, content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                            if error != nil {
                                print("something went wrong")
                            }
                        })
                        try context.save()
                        navigationController?.popViewController(animated: true)
                    }
                }
            }
            catch {
                print("Fetch Failed")
            }
        }
        
    }
    
}









