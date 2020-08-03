//
//  LessonAddView.swift
//  Tymed
//
//  Created by Jonah Schueller on 03.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

class LessonAddViewWrapper: UIViewController {
    
    lazy var contentView = UIHostingController(rootView: LessonAddView(dismiss: {
        self.dismiss(animated: true, completion: nil)
    }))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(contentView)
        view.addSubview(contentView.view)
        
        setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.constraintToSuperview()
    }
}


struct LessonAddView: View {
    
    var dismiss: () -> Void
    
    //MARK: Lesson Subject Title
    @State private var subjectTitle = ""
    
    //MARK: Lesson Time state
    
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    @State private var showDayPicker = false
    
    @State private var test = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if test {
                        Text("Hello Text")
                    }
                    
                    TextField("Subject Name", text: $subjectTitle)
                        .onTapGesture {
                            test.toggle()
                        }
                        .disableAutocorrection(true)
                }
            }.listStyle(InsetGroupedListStyle())
        }
    }
}

struct LessonAddView_Previews: PreviewProvider {
    static var previews: some View {
        LessonAddView {
            
        }.colorScheme(.dark)
    }
}
