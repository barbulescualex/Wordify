//
//  ViewController.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: View Components
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.text = "Wordify"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        label.textColor = UIColor.offWhite
        return label
    }()
    
    private lazy var refreshButton : UIButton = {
        let button = UIButton()
        button.setTitle("refresh", for: .normal)
        button.setTitleColor(UIColor.offWhite, for: .normal)
        button.setTitleColor(UIColor.highlight, for: .highlighted)
        button.alpha = 0
        button.addTarget(self, action: #selector(refreshPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var wordSearchView : WordSearchView = {
        let view = WordSearchView(size: 10)
        view.alpha = 0
        return view
    }()
    
    //MARK: Init
    required init(){
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        animateIn()
    }
    
    //MARK: Setup
    fileprivate func setup(){
        view.backgroundColor = UIColor.highlight
        
        //add subviews
        view.addSubview(titleLabel)
        view.addSubview(refreshButton)
        view.addSubview(wordSearchView)
        
        //add constraints
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
    
    /// fades views in on viewDidLoad
    fileprivate func animateIn(){
        UIView.animate(withDuration: 0.1, animations: {
            self.titleLabel.alpha = 1
            self.refreshButton.alpha = 1
        }) { (_) in
            self.reloadWordSearch(first: true)
        }
    }
    
    /// pops word search view and either populates chars for the first time or reloads them
    fileprivate func reloadWordSearch(first: Bool){
        UIView.animate(withDuration: 0.2, animations: {
            self.wordSearchView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.wordSearchView.alpha = 1
        }, completion: { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.wordSearchView.transform = CGAffineTransform.identity
            }, completion: { (_) in
                if first {
                    self.wordSearchView.populateChars()
                } else {
                    self.wordSearchView.reloadChars()
                }
            })
        })
    }
    
    /// handler for refresh button, reloads the words search
    @objc fileprivate func refreshPressed(_ sender: UIButton?){
        reloadWordSearch(first: false)
    }

}

