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
    //MARK: Vars
    
    ///Loops background soundtrack
    private var player = AVAudioPlayer()
    
    ///Flag to distinguish if the viewDidAppear animation should occur coming back from the GameViewController
    private var firstLoad = true
    
    ///Gives tactile feedback for the slider
    private var sliderFeedbackGenerator : UIImpactFeedbackGenerator?
    
    ///Holds value for how big the grid should be in the GameViewController
    private var gridSize = 10 {
        didSet{
            //update gride size label
            gridSizeLabel.text = "\(gridSize)x\(gridSize) Grid"
            sliderFeedbackGenerator?.impactOccurred()
            
            //update emoji view
            let emojiIndex = gridSize - 10
            emojiView.text = emojis[emojiIndex]
        }
    }
    
    ///The emoji options based on the grid  size
    private var emojis = ["👶","😎","💪","🔥","😈","💀"]
    
    ///Reference to the constraints for the title stack
    private var titleStackConstraints = [NSLayoutConstraint]()
    
    //MARK: View Components
    
    ///Holds char cells spelling out the app's name
    private var titleStack : UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        let string = "wordify"
        for char in string {
            let cell = CharCell(char: char)
            cell.fontSize = 40
            stack.addArrangedSubview(cell)
        }
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    ///Button to start the game
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
        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 50, bottom: 10, right: 50)
        return button
    }()
    
    ///Grid size slider
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
    
    ///Grid size label
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
    
    ///Emoji view
    private var emojiView: UILabel = {
        let label = UILabel()
        label.text = "👶"
        label.font = UIFont.systemFont(ofSize: 80)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    //MARK: Init
    required init() {
        super.init(nibName: nil, bundle: nil)
        setup()
        setupPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented in HomeViewController")
    }
    
    //MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        animateInTitle(index: 0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //reset alphas for re-animation upon view did appear
        playButton.alpha = 0
        slider.alpha = 0
        gridSizeLabel.alpha = 0
        emojiView.alpha = 0
        titleStack.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstLoad { //app just loaded up, already executed splash screen animation
            firstLoad = false
        } else { //fade everyhing back in
            viewDidAppearAnimation()
        }
    }
    
    //MARK: Setup
    
    ///Sets up the view with constraints
    private func setup(){
        //properties
        view.backgroundColor = UIColor.offWhite
        
        //add subviews
        view.addSubview(titleStack)
        view.addSubview(playButton)
        view.addSubview(slider)
        view.addSubview(gridSizeLabel)
        view.addSubview(emojiView)
        
        //constraints
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
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
            titleStack.widthAnchor.constraint(equalToConstant: 320),
            titleStack.heightAnchor.constraint(equalToConstant: 80),
        ]
        
        NSLayoutConstraint.activate(titleStackConstraints)
        
        //prepare slider feedback generator
        sliderFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        sliderFeedbackGenerator?.prepare()
    }
    
    ///Initiates the audio player with soundtrack and starts it on infinite loop
    private func setupPlayer(){
        guard let url = Bundle.main.url(forResource: "buddy", withExtension: "mp3") else {return}
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print(error)
        }
        player.prepareToPlay()
        player.volume = 0.4
        player.numberOfLoops = -1
        player.play()
    }
    
    //MARK: Animations
    
    ///Animates title stack char cells as selected recursively, first animation to occur on viewDidLoad
    private func animateInTitle(index: Int){
        if !titleStack.arrangedSubviews.indices.contains(index) {
            animateIn() //base case, splash screen animation complete
            return
        }
        guard let cell = titleStack.arrangedSubviews[index] as? CharCell else {
            return
        }
        cell.addHighlight()
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.25) {
            DispatchQueue.main.sync {
                self.animateInTitle(index: index+1)
            }
        }
    }
    
    ///Moves titlestack up to top and fades rest of content in
    private func animateIn(){
        //update title stack sizing and position
        NSLayoutConstraint.deactivate(titleStackConstraints)
        
        titleStackConstraints = [
            titleStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleStack.widthAnchor.constraint(equalToConstant: 245),
            titleStack.heightAnchor.constraint(equalToConstant: 35),
        ]
        NSLayoutConstraint.activate(titleStackConstraints)
        
        for view in self.titleStack.arrangedSubviews {
            guard let cell = view as? CharCell else {continue}
            cell.fontSize = 30
        }
        
        UIView.animate(withDuration: 0.4, animations:  {
            self.view.layoutIfNeeded()
        }){ _ in
            //fade everything else in
            UIView.animate(withDuration: 0.4, animations: {
                self.playButton.alpha = 1
                self.slider.alpha = 1
                self.gridSizeLabel.alpha = 1
                self.emojiView.alpha = 1
            })
        }
    }
    
    ///fades screen content in if coming back from GameViewController
    private func viewDidAppearAnimation(){
        UIView.animate(withDuration: 0.4, animations: {
            self.playButton.alpha = 1
            self.slider.alpha = 1
            self.gridSizeLabel.alpha = 1
            self.emojiView.alpha = 1
            self.titleStack.alpha = 1
        })
    }
    
    //MARK: Event Handlers
    
    ///Starts the game
    @objc func play(_ sender: UIButton){
        UIView.animate(withDuration: 0.3, animations: {
            sender.backgroundColor = UIColor.green
        }) { _ in
            let gameVC = GameViewController(size: self.gridSize)
            gameVC.soundDelegate = self
            self.present(gameVC, animated: true, completion: {
                sender.backgroundColor = UIColor.pink
            })
        }
    }
    
    ///Detects slider changes and updates the grid size value
    @objc func sliderChanged(_ sender: UISlider){
        let rounded = ceil(sender.value)
        let size = Int(rounded) + 10
        sender.value = rounded
        if gridSize != size {
            gridSize = size
        }
    }

}

extension HomeViewController : GameViewControllerSoundDelegate {
    func stopPlaying() {
        //stop playing and reset, another sound track is occuring
        player.stop()
        player.prepareToPlay()
        player.currentTime = 0
    }
    
    func startPlaying() {
        //start playing soundtrack
        player.play()
    }

}
