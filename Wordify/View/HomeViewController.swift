//
//  HomeViewController.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-17.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    private var player = AVAudioPlayer()
    private var audioFile = AVAudioFile()
    
    private var sliderFeedbackGenerator : UIImpactFeedbackGenerator?
    
    private var gridSize = 10 {
        didSet{
            gridSizeLabel.text = "\(gridSize)x\(gridSize) Grid"
            sliderFeedbackGenerator?.impactOccurred()
            
            let emojiIndex = gridSize - 10
            emojiView.text = emojis[emojiIndex]
        }
    }
    
    private var emojis = ["👶","😎","💪","🔥","😈","💀"]
    
    private var titleStackConstraints = [NSLayoutConstraint]()
    
    private var titleStack : UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        let string = "wordify"
        for char in string {
            let cell = CharCell(char: char)
            stack.addArrangedSubview(cell)
        }
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        let attributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 25), NSAttributedString.Key.foregroundColor : UIColor.offWhite]
        button.backgroundColor = UIColor.pink
        button.setAttributedTitle(NSAttributedString(string: "play", attributes: attributes), for: .normal)
        button.addTarget(self, action: #selector(play(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.alpha = 0
        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 25, bottom: 7, right: 25)
        return button
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 5
        slider.tintColor = UIColor.darkPink
        slider.thumbTintColor = UIColor.green
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.alpha = 0
        return slider
    }()
    
    private var gridSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "10x10 Grid"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var emojiView: UILabel = {
        let label = UILabel()
        label.text = "👶"
        label.font = UIFont.systemFont(ofSize: 80)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = .white
//        label.layer.cornerRadius = 15
//        label.clipsToBounds = true
        label.alpha = 0
        return label
    }()
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        setup()
        setupPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateInTitle(index: 0)
    }
    
    
    fileprivate func setup(){
        view.backgroundColor = UIColor.offWhite
        
        view.addSubview(titleStack)
        view.addSubview(playButton)
        view.addSubview(slider)
        view.addSubview(gridSizeLabel)
        view.addSubview(emojiView)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            slider.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            slider.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            slider.widthAnchor.constraint(equalToConstant: 250),
            slider.heightAnchor.constraint(equalToConstant: 25),
            
            gridSizeLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            gridSizeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 10),
            
            emojiView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emojiView.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -10)
        ])
        
        titleStackConstraints = [
            titleStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            titleStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleStack.widthAnchor.constraint(equalToConstant: 250),
            titleStack.heightAnchor.constraint(equalToConstant: 40),
        ]
        
        NSLayoutConstraint.activate(titleStackConstraints)
        
        sliderFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        sliderFeedbackGenerator?.prepare()
    }
    
    fileprivate func setupPlayer(){
        guard let url = Bundle.main.url(forResource: "buddy", withExtension: "mp3") else {return}
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print(error)
        }
        player.prepareToPlay()
        player.numberOfLoops = -1
        player.play()
    }
    
    fileprivate func animateIn(){
        NSLayoutConstraint.deactivate(titleStackConstraints)
        
        titleStackConstraints = [
            titleStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleStack.widthAnchor.constraint(equalToConstant: 175),
            titleStack.heightAnchor.constraint(equalToConstant: 25),
        ]
         NSLayoutConstraint.activate(self.titleStackConstraints)
        
        UIView.animate(withDuration: 0.4, animations:  {
           self.view.layoutIfNeeded()
        }){ _ in
            UIView.animate(withDuration: 0.4, animations: {
                self.playButton.alpha = 1
                self.slider.alpha = 1
                self.gridSizeLabel.alpha = 1
                self.emojiView.alpha = 1
            })
        }
    }
    
    fileprivate func animateInTitle(index: Int){
        if !titleStack.arrangedSubviews.indices.contains(index) {
            animateIn()
            return
        }
        guard let cell = titleStack.arrangedSubviews[index] as? CharCell else {
            return
        }
        print("animating index: ", index)
        cell.addHighlight()
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.25) {
            DispatchQueue.main.sync {
                self.animateInTitle(index: index+1)
            }
        }
    }
    
    @objc func play(_ sender: UIButton){
        
    }
    
    @objc func sliderChanged(_ sender: UISlider){
        let rounded = ceil(sender.value)
        let size = Int(rounded) + 10
        sender.value = rounded
        if gridSize != size {
            gridSize = size
        }

    }

}
