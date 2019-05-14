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
    static let offWhite = UIColor(red: 248/250, green: 248/250, blue: 248/250, alpha: 1)
    static let highlight = UIColor(red: 150/250, green: 191/250, blue: 72/250, alpha: 1)
}

//easy extension to cancel a gesture
extension UIGestureRecognizer {
    func cancel() {
        isEnabled = false
        isEnabled = true
    }
}
