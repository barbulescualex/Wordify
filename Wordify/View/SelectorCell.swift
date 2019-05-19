//
//  SelectorCell.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

class SelectorCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    public var word : Word? {
        didSet{
            label.text = word?.string
        }
    }
    
    let label : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func tapped(){
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }){ _ in
            UIView.animate(withDuration: 0.05, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }
    
    fileprivate func setup(){
        backgroundColor = UIColor.offWhite
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
