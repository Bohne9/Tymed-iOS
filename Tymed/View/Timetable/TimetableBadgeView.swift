//
//  TimetableBadgeView.swift
//  Tymed
//
//  Created by Jonah Schueller on 28.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI

enum TimetableBadgeViewSize {
    case small
    case normal
    case large
    
    internal var fontSize: CGFloat {
        switch self {
        case .small:
            return 9
        case .normal:
            return 12
        case .large:
            return 14
        }
    }
        
    internal var fontWeight: Font.Weight {
        switch self {
        case .small:
            return .semibold
        case .normal:
            return .semibold
        case .large:
            return .semibold
        }
    }
}

struct TimetableBadgeView: View {
    
    @ObservedObject
    var timetable: Timetable
    
    var size = TimetableBadgeViewSize.normal
    
    var color = UIColor.appColor
    
    var body: some View {
        HStack {
            if size != .small {
                RoundedRectangle(cornerRadius: (size == .normal ? 4.0 : 8.0) / 2)
                    .frame(width: size == .normal ? 4.0 : 8.0, height: size == .normal ? 14 : 18)
                    .foregroundColor(Color(UIColor(timetable) ?? color))
            }else {
//                Spacer()
            }
                
            Text(timetable.name)
                .font(.system(size: size.fontSize, weight: size.fontWeight))
                .foregroundColor(.white)
            
//            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(color))
        .cornerRadius(size.fontSize + 4)
//        .padding(5)
    }
}
