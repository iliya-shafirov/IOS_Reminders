//
//  TableReminders.swift
//  Reminders
//
//  Created by Elena Shafirova on 10.05.2021.
//

import UIKit
import CoreData

var reminderData = [ReminderEntity]()
class TableController: UITableViewController {
    
    var firstLoad = true
    
    override func viewDidLoad() {
        if (firstLoad) {
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderEntity")
            do {
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let reminder = result as! ReminderEntity
                    reminderData.append(reminder)
                }
            }
            catch {
                print("Fetch Failed")
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminderCell = tableView.dequeueReusableCell(withIdentifier: "reminderId", for: indexPath) as! ReminderTableCell

        let thisTableElem:ReminderEntity!
        
        thisTableElem = reminderData[indexPath.row]
        reminderCell.Content.text = thisTableElem.title
        let date = thisTableElem.date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        reminderCell.Date.text = formatter.string(from: date!)
        
        return reminderCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderData.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editReminder", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "editReminder") {
            let indexPath = tableView.indexPathForSelectedRow!
            let reminderCurrent = segue.destination as? ReminderController
            let selectedReminder : ReminderEntity!
            selectedReminder = reminderData[indexPath.row]
            reminderCurrent?.selectedReminder = selectedReminder
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let selectedReminder = reminderData[indexPath.row]
            reminderData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [selectedReminder.id.stringValue])
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderEntity")
            do {
                let results = try? context.fetch(request)
                let resultData = results as! [ReminderEntity]
                for result in resultData
                {
                    let reminder = result
                    if (reminder == selectedReminder) {
                        context.delete(result)
                    }
                }
                do {
                    try context.save()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
            
            
        }
        
    }
}
