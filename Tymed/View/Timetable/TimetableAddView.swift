//
//  TimetableAddView.swift
//  Tymed
//
//  Created by Jonah Schueller on 29.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

struct TimetableAddView: View {
    
    @Environment(\.presentationMode)
    var presentationMode
    
    @State
    private var timetableName: String = ""
    
    @State
    private var isNewDefault = false
    
    @State
    private var subjects: [Subject] = []
    
    var body: some View {
        NavigationView {
            List {
                
                Section(header: Text("Name")) {
                    TextField("Name", text: $timetableName)
                }
                
                Section {
                    HStack {
                        DetailCellDescriptor("Make default timetable", image: "circlebadge.fill", .systemGreen)
                        
                        Toggle("", isOn: $isNewDefault)
                            .labelsHidden()
                    }
                }
                
                //MARK: Subjects
                ForEach(subjects) { subject in
                    
                    Section {
                        VStack {
                            HStack(alignment: .top) {
                                
                                Text("Subject")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(.systemGray))
                                
                                Spacer()
                                
                                Button {
                                    subjects.removeAll { (sub) -> Bool in
                                        sub.id == subject.id
                                    }
                                } label: {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(Color(.systemGray))
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                
                            }.frame(height: 40)
                            .padding(.bottom)
                            
                            SubjectAddSection(subject: subject)
                        }
                    }
                    
                }
                
                //MARK: Add subject
                Section {
                    HStack {
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                addSubject("")
                            }
                        } label: {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(.systemBlue))
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Add subject")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                                                        
                        }

                        Spacer()
                        
                    }.padding(.vertical, 4)
                }
                
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Cancel")
            }), trailing: Button(action: {
                addTimetable()
            }, label: {
                Text("Add")
            }))
            .navigationTitle("Timetable")
        }
    }
    
    private func addTimetable() {
        let timetable = TimetableService.shared.timetable()
        
        timetable.name = timetableName
        
        
        if isNewDefault {
            TimetableService.shared.setDefaultTimetable(timetable)
        }else {
            timetable.isDefault = false
        }
        
        TimetableService.shared.save()
        
        presentationMode.wrappedValue.dismiss()
    }
 
    private func addSubject(_ name: String) {
        
        guard let subject = TimetableService.shared.subject(with: name) else {
            return
        }
        
        subjects.append(subject)
    }
}

//MARK: SubjectAddSection
struct SubjectAddSection: View {
    
    @ObservedObject
    var subject: Subject
    
    var body: some View {
        VStack {
            HStack {
                
                TextField("Name", text: $subject.name)
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Picker("", selection: $subject.color) {
                    ForEach(colors(), id: \.self) { color in
                        Rectangle()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color(UIColor(named: color)!))
                            .cornerRadius(5)
                    }
                }.labelsHidden()
                .pickerStyle(InlinePickerStyle())
                .frame(width: 30, height: 30)
                .padding(4)
                .clipped()
                .contentShape(RoundedRectangle(cornerRadius: 5))
            }
        }
    }
    
    private func colors() -> [String] {
        return ["red", "blue", "orange", "green", "dark"]
    }
}

struct TimetableAddView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableAddView()
    }
}
