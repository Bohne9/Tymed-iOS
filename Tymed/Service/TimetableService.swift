//
//  TimetableService.swift
//  Tymed
//
//  Created by Jonah Schueller on 02.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation
import CoreData

//MARK: Day
enum Day: Int {
    
    static var current: Day {
        return Day(rawValue: Calendar.current.component(.weekday, from: Date())) ?? Day.monday
    }
    
    static func <(_ d1: Day, _ d2: Day) -> Bool {
        let v1 = d1.rawValue + (d1 == .sunday ? 7 : 0)
        let v2 = d2.rawValue + (d2 == .sunday ? 7 : 0)
        return v1 < v2
    }
    
    static func ==(_ d1: Day, _ d2: Day) -> Bool {
        return d1.rawValue == d2.rawValue
    }
    
    static func <=(_ d1: Day, _ d2: Day) -> Bool {
        return d1 < d2 || d1 == d2
    }
    
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
    
    func shortString() -> String {
        return Calendar.current.shortWeekdaySymbols[rawValue - 1]
    }
    
    func rotatingNext() -> Day {
        if self == .saturday {
            return .sunday
        }
        return Day(rawValue: rawValue + 1)!
    }
    
    func isToday() -> Bool {
        return Calendar.current.component(.weekday, from: Date()) == self.rawValue
    }
}

//MARK: TimetableService
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
    
    //MARK: Lesson factory
    func lesson() -> Lesson {
        let lesson = Lesson(context: context)
        lesson.id = UUID()
        
        return lesson
    }
    
    //MARK: addLesson(...)
    func addLesson(subject: Subject, day: Day, start: Date, end: Date, note: String? = nil) -> Lesson? {
        
        let lesson = self.lesson()
        
        lesson.subject = subject
        
        lesson.dayOfWeek = Int32(day.rawValue)
        lesson.startTime = Time(from: start)
        lesson.endTime = Time(from: end)
        
        lesson.note = note
        
        save()
        
        return lesson
    }
    
    //MARK: deleteLesson(_: )
    func deleteLesson(_ lesson: Lesson) {
        context.delete(lesson)
        
        save()
    }
    
    //MARK: Task factory
    /// Creates a new instance of Task and attaches an UUID
    func task() -> Task {
        let task = Task(context: context)
        task.id = UUID()
        
        return task
    }
    
    //MARK: addTask(...)
    func addTask(_ title: String, _ text: String = "", _ due: Date, _ lesson: Lesson? = nil, _ priority: Int = 0) -> Task? {
        let task = self.task()
        
        task.title = title
        task.completed = false
        task.text = text
        task.due = due
        task.lesson = lesson
        task.priority = Int32(priority)
        
        save()
        
        return task
    }
    
    //MARK: save()
    func save() {
        do {
            try context.save()
        } catch {
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
            print ("fetch lessons failed", error)
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
            print ("fetch lessons failed", error)
            return []
        }
        
    }
    
    //MARK: getLessons(day: )
    /// Fetches the lesson of the current timetable that match a given day (.weekday)
    /// - Parameter day: Day of week of the lessons
    /// - Returns: Array containing the lessons (of the current timetable) that match the day of week
    func getLessons(within day: Day) -> [Lesson] {
        
        do {
            let fetchRequest: NSFetchRequest<Lesson> = Lesson.fetchRequest()
            
            let weekday = day.rawValue
            
            fetchRequest.predicate = NSPredicate(format: "dayOfWeek == %@", NSNumber(value: weekday))
            
            let fetchedResults = try context.fetch(fetchRequest)
                
            return fetchedResults
        }
        catch {
            print ("fetch lessons failed", error)
            return []
        }
        
    }
    
    func sortLessonsByWeekDay(_ lessons: [Lesson]) -> [Day: [Lesson]] {
        var week = [Day: [Lesson]]()
        
        lessons.forEach({ (lesson) in
            if ((week[lesson.day]) != nil) {
                week[lesson.day]?.append(lesson)
            }else {
                week[lesson.day] = [lesson]
            }
        })
        
        // Sort each day slot by time
        week.forEach { (arg0) in
            let (key, value) = arg0
            week[key] = value.sorted(by: { (l1, l2) -> Bool in
                if l1.startTime != l2.startTime {
                    return l1.startTime < l2.startTime
                }
                return l1.endTime < l2.endTime
            })
        }
        
        return week
    }
    
    //MARK: getTasks(predicate: )
    private func getTasks(_ predicate: String, args: CVarArg...) -> [Task] {

        do {
           let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
           
           fetchRequest.predicate = NSPredicate(format: predicate, args)
           
           let results = try context.fetch(fetchRequest)
           
           return results
        }catch {
           print("fetch tasks failed", error)
           return []
        }
    }
    
    func getTasks() -> [Task] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "Task")
        
        do {
            
            let res = try context.fetch(req) as! [Task]
            
            return res
            
        } catch {
            return []
        }
    }
    
    //MARK: getTasks(lesson: )
    func getTasks(for lesson: Lesson) -> [Task] {
        return getTasks("lesson == %@", args: lesson)
    }

    //MARK: getTasks(date: )
    private func getTasks(date: Date, dateOperation: String) -> [Task] {
        return getTasks("due \(dateOperation) %@", args: date as NSDate)
    }

    func getTasks(before date: Date) -> [Task] {
        return getTasks(date: date, dateOperation: "<=")
    }

    func getTasks(after date: Date) -> [Task] {
        return getTasks(date: date, dateOperation: ">=")
    }

    func getTasks(at date: Date) -> [Task] {
        return getTasks(date: date, dateOperation: "==")
    }
    
    //MARK: deleteTask(_: )
    func deleteTask(_ task: Task) {
        context.delete(task)
        
        save()
    }

    //MARK: getTasksOrderedByDate(limit: )
    /// Fetches all tasks from core data sorted by their due date
    /// - Parameter limit: Max number of items starting from the first
    func getTasksOrderedByDate(limit: Int = 5) -> [Task] {
        do {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            
            let sort = NSSortDescriptor(key: #keyPath(Task.due), ascending: true)
            
            fetchRequest.sortDescriptors = [sort]
            
            fetchRequest.fetchLimit = limit
       
            let results = try context.fetch(fetchRequest)
            
            return results
            
        }catch {
            print("fetch tasks failed", error)
            return []
        }
    }
    
    
    func dateOfNext(lesson: Lesson) -> Date? {
        
        let start = lesson.startTime
        let day = lesson.day
        
        var comp = DateComponents()
        comp.weekday = day.rawValue
        comp.hour = start.hour
        comp.minute = start.minute
        
        return Calendar.current.nextDate(after: Date(), matching: comp, matchingPolicy: .strict)
    }
}
