//
//  Reminder.swift
//  Reminders
//
//

import CoreData

@objc(ReminderEntity)
class ReminderEntity:NSManagedObject {
    @NSManaged var content: String!
    @NSManaged var date: Date!
    @NSManaged var title: String!
    @NSManaged var id: NSNumber!
}


