//
//  EndGameView.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-19.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

protocol EndGameViewDelegate : AnyObject {
    func closeView(_ sender: EndGameView)
}

public class EndGameView : UIView, UIGestureRecognizerDelegate {
    //MARK: Vars
    weak var delegate : EndGameViewDelegate?
    
    //MARK: View Components
    private let backgroundView : UIView = { //transparent overlay
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let viewArea : UIView =  { //display area
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: Init
    public required init() {
        super.init(frame: .zero)
        setupView()
        populateViewArea()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    //MARK: Lifecycle Functions
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        showAnimate()
    }
    
    //MARK: Setup
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
        //for pop up look
        layer.zPosition = 100
        clipsToBounds = true
        
        addSubview(backgroundView)
        addSubview(viewArea)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            viewArea.topAnchor.constraint(equalTo: topAnchor, constant: 200),
            viewArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -200),
            viewArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            viewArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30)
        ])
        
        //tap gesture for background view to close itself
        let tap = UITapGestureRecognizer(target: self, action: #selector(outsidePressed(_:)))
        tap.delegate = self
        backgroundView.addGestureRecognizer(tap)
    }
    
    fileprivate func populateViewArea(){
        //title label
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.text = "Congratulations!"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        //content
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.layer.cornerRadius = 10
        content.clipsToBounds = true
        content.backgroundColor = UIColor.offWhite
        
        //content label
        let contentLabel = UILabel()
        contentLabel.font = UIFont.systemFont(ofSize: 20)
        contentLabel.textColor = .gray
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.text = "Thanks for playing, I'm looking forward to being part of the team! 👋🏻☺️"
        
        viewArea.addSubview(label)
        viewArea.addSubview(content)
        content.addSubview(contentLabel)
        
        //constraints
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewArea.centerXAnchor),
            label.topAnchor.constraint(equalTo: viewArea.topAnchor, constant: 5),
            label.heightAnchor.constraint(equalToConstant: 35),
            
            content.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 7.5),
            content.trailingAnchor.constraint(equalTo: viewArea.trailingAnchor, constant: -7.5),
            content.leadingAnchor.constraint(equalTo: viewArea.leadingAnchor, constant: 7.5),
            content.bottomAnchor.constraint(equalTo: viewArea.bottomAnchor, constant: -7.5),
        
            contentLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 5),
            contentLabel.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -5),
            contentLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 5),
            contentLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -5),
        ])
    }
    
    //MARK: Animations
    fileprivate func showAnimate(){
        viewArea.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        viewArea.alpha = 0.0
        UIView.animate(withDuration: 0.125, animations: {
            self.viewArea.alpha = 1.0
            self.viewArea.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.backgroundView.backgroundColor = UIColor.pink.withAlphaComponent(0.8)
        }, completion: { _ in
            UIView.animate(withDuration: 0.075){
                self.viewArea.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        })
    }
    
    fileprivate func leaveAnimate(){
        UIView.animate(withDuration: 0.1, animations: {
            self.viewArea.frame = CGRect(x: 0, y: 2000, width: self.viewArea.frame.size.width, height: self.viewArea.frame.size.height)
            self.backgroundView.backgroundColor = .clear
        }) { _ in
            self.delegate?.closeView(self)
        }
    }
    
    //MARK: Event Handlers
    @objc func outsidePressed(_ sender: UIGestureRecognizer){
        leaveAnimate()
    }
}
