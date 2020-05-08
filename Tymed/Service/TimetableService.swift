//
//  TimetableService.swift
//  Tymed
//
//  Created by Jonah Schueller on 02.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation
import CoreData

extension Date {
    
    func stringify(with format: String) -> String{
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    
    func stringifyTime(with format: DateFormatter.Style) -> String{
        
        let formatter = DateFormatter()
        
        formatter.timeStyle = format
        
        return formatter.string(from: self)
    }
    
    func stringify(with style: DateFormatter.Style) -> String{
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = style
        
        return formatter.string(from: self)
    }
    
    func timeToString() -> String {
        return stringifyTime(with: .short)
    }
    
    func dayToString() -> String {
        return stringify(with: "EEEE")
    }
    
    func dayToStringShort() -> String {
        return stringify(with: "E")
    }
}

enum Day: Int{
    
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    
    case saturday = 7
    case sunday = 1
    
    func date() -> Date? {
        return TimetableService.shared.dateFor(day: self)
    }
}

class TimetableService {
    
    static let shared = TimetableService()
    
    private let context = AppDelegate.persistentContainer
    
    internal init() {
        
    }
    
    
    //MARK: Subject fetching
    func fetchSubjects() -> [Subject]? {
    
        let req = NSFetchRequest<NSManagedObject>(entityName: "Subject")
        
        do {
            
            let res = try context.fetch(req) as! [Subject]
            
            return res
            
        } catch {
            return nil
        }
    }
    
    func fetchSubjects(_ completion: (([Subject]?, Error?) -> Void)?) {
    
        let req = NSFetchRequest<NSManagedObject>(entityName: "Subject")
        
        do {
            
            let res = try context.fetch(req) as! [Subject]
            
            completion?(res, nil)
            
        } catch {
            completion?(nil, error)
        }
        
    }
    
    
    //MARK: Subject factory
    func subject() -> Subject {
        let subject = Subject(context: context)
        subject.id = UUID()
        
        return subject
    }
    
    //MARK: addSubject(_: ...)
    func addSubject(_ name: String, _ color: String, _ createdAt: Date? = nil, _ id: UUID? = nil) -> Subject{
        
        let subject = self.subject()
        
        subject.name = name
        subject.color = color
        subject.createdAt = createdAt ?? Date()
        subject.id = id ?? UUID()
        
        save()
        
        return subject
    }
    
    //MARK: Lesson fetching
    func fetchLessons() -> [Lesson]? {
        
        let req = NSFetchRequest<NSManagedObject>(entityName: "Lesson")
        
        do {
            
            let res = try context.fetch(req) as! [Lesson]
            
            return res
            
        } catch {
            return nil
        }
    }
    
    func fetchLessons(_ completion: (([Lesson]?, Error?) -> Void)?) {
        
        let req = NSFetchRequest<NSManagedObject>(entityName: "Lesson")
        
        do {
            
            let res = try context.fetch(req) as! [Lesson]
            
            completion?(res, nil)
            
        } catch {
            completion?(nil, error)
        }
        
    }
    
    
    func lesson() -> Lesson {
        let lesson = Lesson(context: context)
        lesson.id = UUID()
        
        return lesson
    }
    
    
    func addLesson(subject: Subject, day: Day, start: Date, end: Date, note: String?) -> Lesson {
        
        let lesson = self.lesson()
        
        lesson.subject = subject
        
        let dayDate = day.date()
        
        lesson.dayOfWeek = dayDate
        lesson.startTime = start
        lesson.endTime = end
        lesson.note = note
        
        save()
        
        return lesson
    }
    
    func deleteLesson(_ lesson: Lesson) {
        context.delete(lesson)
        
        save()
    }
    
    //MARK: save
    func save() {
        do {
            try context.save()
        }catch {
            print(error)
        }
    }
    
    //MARK: Date
    func dateFor(day: Day) -> Date? {
        
        var dateComponents = DateComponents()
        dateComponents.weekday = day.rawValue
        
        let cal = Calendar.current
        
        return cal.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .strict)
        
    }
    
    func dateFor(hour: Int, minute: Int) -> Date {
        
        var dateComponents = DateComponents()
        
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return Calendar.current.date(from: dateComponents)!
    }
    
    func getLessons(within date: Date) -> [Lesson] {
        
        do {
            let fetchRequest : NSFetchRequest<Lesson> = Lesson.fetchRequest()
            
            let comp = Calendar.current.dateComponents([.hour, .minute, .weekday], from: date)
            let d = Calendar.current.date(from: comp)!
            
            fetchRequest.predicate = NSPredicate(format: "startTime <= %@ AND %@ <= endTime", d as NSDate, d as NSDate)
            let fetchedResults = try context.fetch(fetchRequest)
            
            return fetchedResults
        }
        catch {
            print ("fetch task failed", error)
            return []
        }
        
    }
    
//    func getLessons(of subject: Subject) -> [Lesson] {
//
//        do {
//            let fetchRequest : NSFetchRequest<Lesson> = Lesson.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "startDate <= %@ AND %@ <= endDate ", date as NSDate)
//            let fetchedResults = try context.fetch(fetchRequest)
//
//            return fetchedResults
//        }
//        catch {
//            print ("fetch task failed", error)
//            return []
//        }
//
//    }
}
