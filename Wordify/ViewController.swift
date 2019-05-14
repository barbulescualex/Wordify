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
        label.textColor = UIColor.offWhite
        return label
    }()
    
    lazy var refreshButton : UIButton = {
        let button = UIButton()
        button.setTitle("refresh", for: .normal)
        button.setTitleColor(UIColor.offWhite, for: .normal)
        button.setTitleColor(UIColor.highlight, for: .highlighted)
        button.alpha = 0
        button.addTarget(self, action: #selector(refreshPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var wordSearchView = WordSearchView(size: 10)
    
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
        view.backgroundColor = UIColor.highlight
        
        view.addSubview(titleLabel)
        view.addSubview(refreshButton)
        view.addSubview(wordSearchView)
        wordSearchView.alpha = 0
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            
            refreshButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            refreshButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            
            
            wordSearchView.widthAnchor.constraint(equalTo: wordSearchView.heightAnchor),
            wordSearchView.heightAnchor.constraint(equalTo: wordSearchView.widthAnchor),
            wordSearchView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            wordSearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wordSearchView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    
    fileprivate func animateIn(){
        UIView.animate(withDuration: 0.1, animations: {
            self.titleLabel.alpha = 1
            self.refreshButton.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.wordSearchView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self.wordSearchView.alpha = 1
            }, completion: { (_) in
                UIView.animate(withDuration: 0.05, animations: {
                    self.wordSearchView.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    self.wordSearchView.populateChars()
                })
            })
        }
    }
    
    @objc func refreshPressed(_ sender: UIButton?){
        wordSearchView.deleteChars()
    }

}

