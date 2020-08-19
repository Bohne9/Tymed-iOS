//
//  HomeTopBar.swift
//  Tymed
//
//  Created by Jonah Schueller on 27.04.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class HomeTopBar: UIStackView {

    
    var dash = UIButton()
    
    var tasks = UIButton()
    
    var week = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        spacing = 12
        
        axis = .horizontal
        
        alignment = .leading
        
        distribution = .fillProportionally
        
        addArrangedSubview(dash)
        
        dash.tag = 0
        
        tasks.tag = 1
        
        week.tag = 2
        
        addArrangedSubview(tasks)
        
        addArrangedSubview(week)
        
        configureButton(dash, "Start")
        
        configureButton(tasks, "Tasks")
        
        configureButton(week, "Week")
        
        updateButtons(dash)
    }
    
    private func configureButton(_ btn: UIButton, _ title: String) {
    
        btn.setTitle(NSLocalizedString(title, comment: ""), for: .normal)
        btn.setAttributedTitle(
            NSAttributedString(string: title,
                               attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .bold),
                                            NSAttributedString.Key.foregroundColor: UIColor.label]), for: .normal)
        
        btn.addTarget(self, action: #selector(updateButtons(_:)), for: .touchUpInside)
        
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    
    @objc func updateButtons(_ tappedBtn: UIButton) {
        highlightPage(tappedBtn.tag)
    }
    
    func highlightPage(_ page: Int) {
        let btns = [dash, tasks, week]
        
        for btn in btns {
            if btn.tag == page {
                btn.setAttributedTitle(NSAttributedString(string: btn.title(for: .normal) ?? "",
                             attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .bold),
                             NSAttributedString.Key.foregroundColor: UIColor.label]), for: .normal)
            }else {
                btn.setAttributedTitle(NSAttributedString(string: btn.title(for: .normal) ?? "",
                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .bold),
                    NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]), for: .normal)
            }
        }
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
