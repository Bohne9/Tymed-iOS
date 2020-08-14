//
//  Tymed_Widgets.swift
//  Tymed-Widgets
//
//  Created by Jonah Schueller on 13.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> TimetableEntry {
        
        let lessons = TimetableService.shared.getLessons(within: .current)
        
        return TimetableEntry(date: Date(), lessons: lessons)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TimetableEntry) -> ()) {
        
        let lessons = TimetableService.shared.getLessons(within: .current)
        
        let entry = TimetableEntry(date: Date(), lessons: lessons)
        
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [TimetableEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for i in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
            
            
            guard let lessons = fetchLessons() else {
                continue
            }
            
            print("Entry \(i) - Lessons: \(lessons.count)")
            
            let entry = TimetableEntry(date: entryDate, lessons: lessons)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func fetchLessons() -> [Lesson]? {
        
        let req = NSFetchRequest<NSManagedObject>(entityName: "Lesson")
        
        do {
            
            let res = try CoreDataStack.shared.persistentContainer.viewContext.fetch(req) as! [Lesson]
            
            return res
            
        } catch {
            return nil
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct TimetableEntry: TimelineEntry {
    var date: Date
    let lessons: [Lesson]
}

struct Tymed_WidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Next lessons: \(entry.lessons.count)")
            ForEach(entry.lessons.prefix(3), id: \.self) {  lesson in
                HStack {
                    Text(lesson.subject?.name ?? "fdsa")
                        .font(.system(size: 12, weight: .semibold))
                }.padding()
                .background(Color(UIColor(lesson) ?? .clear))
                .cornerRadius(8)
            }
            
        }
    }
}

@main
struct Tymed_Widgets: Widget {
    let kind: String = "Tymed_Widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Tymed_WidgetsEntryView(entry: entry)
                .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
        }
        .configurationDisplayName("Timetable widget")
        .description("Overview of the timetable")
    }
}
