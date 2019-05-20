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
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup(){
        
        layer.cornerRadius = 10

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        
        addGestureRecognizer(pan)
    }
    
    @objc func panned(_ sender: UIPanGestureRecognizer){
        if sender.state == .began {
            sender.cancel()
            animate()
            word?.show()
        }
    }
    
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
    
    public func setInFocus(){
        label.font = UIFont.systemFont(ofSize: 22)
    }
    
    public func removeFocus(){
        label.font = UIFont.systemFont(ofSize: 17)
    }
    
    deinit {
        print("Deinit")
    }
}
