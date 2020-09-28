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
            return 8
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
    
    var body: some View {
        HStack {
            if size != .small {
                RoundedRectangle(cornerRadius: (size == .normal ? 5.0 : 8.0) / 2)
                    .frame(width: size == .normal ? 5.0 : 8.0, height: size == .normal ? 10 : 14)
                    .foregroundColor(Color(UIColor(timetable) ?? .appColor))
            }else {
                Spacer()
            }
                
            Text(timetable.name)
                .font(.system(size: size.fontSize, weight: size.fontWeight))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(5)
        .background(Color.appColor)
        .cornerRadius(size.fontSize + 4)
    }
}
