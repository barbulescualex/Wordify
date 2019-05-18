//
//  HomeViewController.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-17.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    fileprivate func setup(){
        view.backgroundColor = UIColor.offWhite
    }

}
