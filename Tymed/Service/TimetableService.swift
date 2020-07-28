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
    
    func timetable() -> Timetable {
        let timetable = Timetable(context: context)
        timetable.id = UUID()
        
        return timetable
    }
    
    func deleteTimetable(_ timetable: Timetable) {
        
        if let tasks = timetable.tasks {
            for task in tasks {
                deleteTask(task as! Task)
            }
        }
        
        if let subjects = timetable.subjects {
            for subject in subjects {
                deleteSubject(subject as! Subject)
            }
        }
        
        context.delete(timetable)
        
        save()
    }
    
    /// Returns all timetables
    func fetchTimetables() -> [Timetable]? {
        let req = NSFetchRequest<NSManagedObject>(entityName: "Timetable")
        
        do {
            let res = try context.fetch(req) as! [Timetable]
            
            return res
        }catch {
            return nil
        }
    }
    
    func defaultTimetable() -> Timetable? {
        return fetchTimetables()?[0]
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
    
    func deleteSubject(_ subject: Subject) {
        if let lessons = subject.lessons {
            for lesson in lessons {
                deleteLesson(lesson as! Lesson)
            }
        }
        
        context.delete(subject)
        
        save()
    }
    
    //MARK: addSubject(_: ...)
    func addSubject(_ name: String, _ color: String, _ createdAt: Date? = nil, _ id: UUID? = nil) -> Subject{
        
        let subject = self.subject()
        
        subject.name = name
        subject.color = color
        subject.createdAt = createdAt ?? Date()
        subject.id = id ?? UUID()
        subject.timetable = defaultTimetable()
        
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
    
    func dateFor(_ time: Time) -> Date {
        return dateFor(hour: time.hour, minute: time.minute)
    }
    
    func lessons() -> [Lesson]? {
        return fetchLessons()
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
    
    
    /// Returns if the lesson is right now
    /// - Parameter lesson: Lesson to analyse
    /// - Returns: Returns if the time of the lesson is right now
    func lessonIsNow(_ lesson: Lesson) -> Bool {
        let now = Time.now
        let today = Day.current
        
        return lesson.day == today && lesson.startTime <= now && now <= lesson.endTime
    }
    
    func getNextLessons(in lessons: [Lesson]?) -> [Lesson]? {
        
        // If there aren't any lessons -> return nil
        guard var les = lessons else {
            return nil
        }
        
        let now = Time.now
        
        // Sort the lessons by day/time
        les.sort { (l1, l2) -> Bool in
            if l1.day == l2.day {
                if l1.startTime == l2.startTime {
                    return l1.endTime < l2.endTime
                }
                return l1.startTime < l2.startTime
            }
            return l1.day < l2.day
        }
        
        // Repeat as often as many items there are in the next lessons list
        for _ in 0..<les.count {
            guard let first = les.first else {
                break
            }
            // If the day is on a previous day or today but already passed or is right now
            // -> Remove form index 0 and append to the end of the list
            if  first.day < Day.current ||
                (first.day == Day.current && first.endTime < now) ||
                (lessonIsNow(first)) {
                les.remove(at: 0)
                les.append(first)
            }
        }
        
        // Reduce the lessons to the first few with the same lesson and startTime
        les = les.reduce([]) { (res, lesson) -> [Lesson] in
            if let first = res.first {
                if first.day == lesson.day && first.startTime == lesson.startTime {
                    var r = res
                    r.append(lesson)
                    return r
                }
            }else {
                return [lesson]
            }
            return res
        }
        
        return les
    }
    
    func getNextLessons() -> [Lesson]? {
        return getNextLessons(in: self.lessons())
    }
    
    //MARK: getTasks(predicate: )
    private func getTasks(_ predicate: NSPredicate) -> [Task] {

        do {
           let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
           
           fetchRequest.predicate = predicate
           
           let results = try context.fetch(fetchRequest)
           
           return results
        } catch {
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
    
    func getAllTasks() -> [Task] {
        let predicate = NSPredicate(format: "archived == false")
        return getTasks(predicate)
    }
    
    func getTasksWithCompleteState(state: Bool) -> [Task] {
        let predicate = NSPredicate(format: "completed == %@ and archived == false", NSNumber(value: state))
        return getTasks(predicate)
    }
    
    func getCompletedTasks() -> [Task] {
        let predicate = NSPredicate(format: "completed == %@ and archived == false", NSNumber(value: true))
        
        return getTasks(predicate).sorted()
    }
    
    func getExpiredTasks() -> [Task] {
        let predicate = NSPredicate(format: "due <= %@ AND completed == NO and archived == false", Date() as NSDate)
        
        return getTasks(predicate).sorted()
    }
    
    func getOpenTasks() -> [Task] {
        let predicate = NSPredicate(format: "completed == %@ and archived == false", NSNumber(value: false))
        
        return getTasks(predicate).sorted()
    }
    
    func getArchivedTasks() -> [Task] {
        let predicate = NSPredicate(format: "archived == %@", NSNumber(value: true))
        
        return getTasks(predicate).sorted()
    }
    
    func getPlannedTasks() -> [Task] {
        let predicate = NSPredicate(format: "due != nil and archived == false")
        
        return getTasks(predicate).sorted()
    }
    
    
    //MARK: getTasks(lesson: )
    func getTasks(for lesson: Lesson) -> [Task] {
        return getTasks(NSPredicate(format: "lesson == %@ and archived == false", lesson))
    }

    //MARK: getTasks(date: )
    private func getTasks(date: Date, dateOperation: String) -> [Task] {
        return getTasks(NSPredicate(format: "due \(dateOperation) %@", date as NSDate))
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
    
    func getTasks(between date1: Date, and date2: Date) -> [Task] {
        return getTasks(NSPredicate(format: "due >= %@ AND due <= %@ and archived == false", date1 as NSDate, date2 as NSDate))
    }
    
    func getTasksOfToday() -> [Task] {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        
        var components = DateComponents()
        components.day = 1
        components.second = -1

        guard let endOfToday = Calendar.current.date(byAdding: components, to: startOfToday) else { return [] }
        
        return getTasks(between: startOfToday, and: endOfToday).sorted()
    }
    
    //MARK: deleteTask(_: )
    func deleteTask(_ task: Task) {
        context.delete(task)
        
        NotificationService.current.removeAllNotifications(of: task)
        
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
