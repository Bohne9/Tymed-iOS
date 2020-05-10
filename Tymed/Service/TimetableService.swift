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
    
    func string() -> String {
        return Calendar.current.weekdaySymbols[rawValue - 1]
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
    
    
    func addLesson(subject: Subject, day: Day, start: Date, end: Date, note: String?) -> Lesson? {
        
        let lesson = self.lesson()
        
        lesson.subject = subject
        
        guard let dayDate = day.date() else {
            print("fvjos")
            return nil
        }
        
        let weekDay = Calendar.current.dateComponents([.day, .hour, .minute], from: dayDate)
        
        print("WeekDay: \(weekDay)")
        print(Calendar.current.date(byAdding: weekDay, to: start))
        
        lesson.dayOfWeek = Int32(day.rawValue)
        lesson.startTime = Time(from: start)
        lesson.endTime = Time(from: end)
        
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
    
    //MARK: dateFor(day: )
    /// Creates a Date containing the given Day type as .weekday
    /// - Parameter day: Day of week
    /// - Returns: Date containing the given Day type as .weekday
    func dateFor(day: Day) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.weekday = day.rawValue
        
        let cal = Calendar.current
        
        let date = DateComponents()
        
        return cal.nextDate(after: cal.date(from: date)!, matching: dateComponents, matchingPolicy: .strict)
        
    }
    
    func dateFor(hour: Int, minute: Int) -> Date {
        
        var dateComponents = DateComponents()
        
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return Calendar.current.date(from: dateComponents)!
    }
    
    //MARK: getLessons(date: )
    /// Fetches the lesson of the current timetable that match a given date (.weekday, .hour, .minute)
    /// - Parameter date: Date that is within the lessons
    /// - Returns: Array containing the lessons (of the current timetable) that match the date
    func getLessons(within date: Date) -> [Lesson] {
        
        do {
            let fetchRequest : NSFetchRequest<Lesson> = Lesson.fetchRequest()
            
            let weekday = Calendar.current.component(.weekday, from: date)
            
            let time = Time(from: date)
            
            fetchRequest.predicate = NSPredicate(format: "dayOfWeek == %@ AND start <= %@ AND %@ <= end", NSNumber(value: weekday), NSNumber(value: time.timeInterval), NSNumber(value: time.timeInterval))
            
            let fetchedResults = try context.fetch(fetchRequest)
                
            return fetchedResults
        }
        catch {
            print ("fetch task failed", error)
            return []
        }
        
    }
    
    //MARK: getLessons(time: )
    /// Fetches the lesson of the current timetable that match a given time (.hour, .minute)
    /// - Parameter time: Time that is within the lessons
    /// - Returns: Array containing the lessons (of the current timetable) that match the time
    func getLessons(within time: Time) -> [Lesson] {
        
        do {
            let fetchRequest : NSFetchRequest<Lesson> = Lesson.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "start <= %@ AND %@ <= end", NSNumber(value: time.timeInterval), NSNumber(value: time.timeInterval))
            
            let fetchedResults = try context.fetch(fetchRequest)
                
            return fetchedResults
        }
        catch {
            print ("fetch task failed", error)
            return []
        }
        
    }
    
    //MARK: getLessons(day: )
    /// Fetches the lesson of the current timetable that match a given day (.weekday)
    /// - Parameter day: Day of week of the lessons
    /// - Returns: Array containing the lessons (of the current timetable) that match the day of week
    func getLessons(within day: Day) -> [Lesson] {
        
        do {
            let fetchRequest : NSFetchRequest<Lesson> = Lesson.fetchRequest()
            
            let weekday = day.rawValue
            
            fetchRequest.predicate = NSPredicate(format: "dayOfWeek == %@", NSNumber(value: weekday))
            
            let fetchedResults = try context.fetch(fetchRequest)
                
            return fetchedResults
        }
        catch {
            print ("fetch task failed", error)
            return []
        }
        
        
    }
    
}
