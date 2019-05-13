//
//  ViewController.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.text = "Wordify"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var refreshButton : UIButton = {
        let button = UIButton()
        button.setTitle("refresh", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.highlight, for: .highlighted)
        button.alpha = 0
        button.addTarget(self, action: #selector(refreshPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    required init(){
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateIn()
    }
    
    fileprivate func setup(){
        view.backgroundColor = UIColor.offWhite
        
        view.addSubview(titleLabel)
        view.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            
            refreshButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            refreshButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5)
        ])
    }
    
    fileprivate func animateIn(){
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.titleLabel.alpha = 1
            self?.refreshButton.alpha = 1
        }
    }
    
    @objc func refreshPressed(_ sender: UIButton?){
        
    }

}

