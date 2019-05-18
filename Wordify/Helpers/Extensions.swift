//
//  Extensions.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

//just some colors :)
extension UIColor {
    static let offWhite = UIColor(red: 245/255, green: 251/255, blue: 241/255, alpha: 1)
    static let pink = UIColor(red: 254/255, green: 185/255, blue: 200/255, alpha: 1)
    static let darkPink = UIColor(red: 246/255, green: 167/255, blue: 186/255, alpha: 1)
    static let green = UIColor(red: 210/255, green: 243/255, blue: 224/255, alpha: 1)
}

//easy extension to cancel a gesture
extension UIGestureRecognizer {
    func cancel() {
        isEnabled = false
        isEnabled = true
    }
}

extension UIViewController {
    func isLandscape() -> Bool {
        return (self.view.frame.height < self.view.frame.width)
    }
    
    func isPortrait() -> Bool {
        return (self.view.frame.height > self.view.frame.width)
    }
}
