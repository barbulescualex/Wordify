//
//  WordCell.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

///CollectionViewCell for the WordSelectorView
class WordCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    //MARK: Vars
    
    ///Word held by the cell
    public var word : Word? {
        didSet{
            label.text = word?.string
        }
    }
    
    ///Flag to check if the cell is in focus
    private var inFocus = false
    
    //MARK: View Components
    
    ///Label to display word string
    private var label : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    //MARK: Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Setup
    private func setup(){
        //properties
        layer.cornerRadius = 10
        
        //subvies and constraints
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        //pan gesture recognizer to initiate reveal
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        
        addGestureRecognizer(pan)
    }
    
    ///MARK: Functions
    
    ///animate if cell is swiped
    private func animate(){
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.label.textColor = UIColor.pink.withAlphaComponent(0.5)
        }){ _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform.identity
                self.label.textColor = UIColor.gray
            })
        }
    }
    
    ///Set cell in focus
    public func setInFocus(){
        if inFocus { return }
        inFocus = true
        label.font = UIFont.systemFont(ofSize: 22)
    }
    
    ///Remove focus from cell
    public func removeFocus(){
        if !inFocus { return }
        inFocus = false
        label.font = UIFont.systemFont(ofSize: 17)
    }
    
    //MARK: Event Handlers
    
    ///Detect swipe on cell
    @objc func panned(_ sender: UIPanGestureRecognizer){
        if sender.state == .began {
            sender.cancel()
            animate()
            word?.show() //reveal word in WordSearchView
        }
    }
}
