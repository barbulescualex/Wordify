//
//  ViewController.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit
import AVFoundation

protocol GameViewControllerDelegate: AnyObject {
    func stopPlaying()
    func startPlaying()
}

class GameViewController: UIViewController {
    //MARK: Vars
    private var player = AVAudioPlayer()
    var wordSearchViewWidthAnchor : NSLayoutConstraint?
    var wordSelectorViewConstraints = [NSLayoutConstraint]()
    var wordsFoundViewConstraints = [NSLayoutConstraint]()
    
    var wordsFound = 0 {
        didSet{
            wordCountLabel.text = "\(wordsFound)/\(words.count)"
            if (wordsFound == words.count) {
                endGame()
            }
        }
    }
    
    var size = 10
    
    var words = [Word](){
        didSet{
            wordCountLabel.text = "\(wordsFound)/\(words.count)"
            wordSelectorView.words = words
        }
    }
    
    weak var delegate : GameViewControllerDelegate?

    //MARK: View Components
    private var wordCountLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var refreshButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "refresh")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.gray
        button.alpha = 0
        button.addTarget(self, action: #selector(refreshPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var homeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "home")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.gray
        button.alpha = 0
        button.addTarget(self, action: #selector(homePressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var wordSearchView : WordSearchView = {
        let view = WordSearchView(size: self.size)
        view.alpha = 0
        view.delegate = self
        return view
    }()
    
    private var wordSelectorView : WordSelectorView = {
        let view = WordSelectorView()
        view.alpha = 0
        return view
    }()
    
    //MARK: Init
    required init(size: Int){
        self.size = size
        super.init(nibName: nil, bundle: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        setupPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    //MARK: Setup
    fileprivate func setup(){
         NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        view.backgroundColor = UIColor.green
        
        //add subviews
        view.addSubview(homeButton)
        view.addSubview(wordCountLabel)
        view.addSubview(refreshButton)
        view.addSubview(wordSelectorView)
        view.addSubview(wordSearchView)
    }
    
    fileprivate func setupConstraints(){
        NSLayoutConstraint.activate([
            homeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            homeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            homeButton.heightAnchor.constraint(equalToConstant: 30),
            homeButton.widthAnchor.constraint(equalToConstant: 30),
            
            refreshButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            refreshButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            refreshButton.heightAnchor.constraint(equalToConstant: 30),
            refreshButton.widthAnchor.constraint(equalToConstant: 30),
            
            wordSearchView.heightAnchor.constraint(equalTo: wordSearchView.widthAnchor),
            wordSearchView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            wordSearchView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
        
        updateConstraints()
    }
    
    fileprivate func updateConstraints(){
        //clear previous
        wordSearchViewWidthAnchor?.isActive = false
        NSLayoutConstraint.deactivate(wordSelectorViewConstraints)
        NSLayoutConstraint.deactivate(wordsFoundViewConstraints)
        
        //update new
        if (view.frame.height > view.frame.width) { //portrait
            //activate new
            wordSearchViewWidthAnchor = wordSearchView.widthAnchor.constraint(equalToConstant: self.view.frame.width)
            wordSearchViewWidthAnchor?.isActive = true
            
            wordSelectorViewConstraints = [wordSelectorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                           wordSelectorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                                           wordSelectorView.heightAnchor.constraint(equalToConstant: 60),
                                           wordSelectorView.topAnchor.constraint(equalTo: wordSearchView.bottomAnchor)]
            
            NSLayoutConstraint.activate(wordSelectorViewConstraints)
            
            wordsFoundViewConstraints = [wordCountLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                                         wordCountLabel.bottomAnchor.constraint(equalTo: wordSearchView.safeAreaLayoutGuide.topAnchor, constant: -30),
                                         ]
            
            NSLayoutConstraint.activate(wordsFoundViewConstraints)
            
            wordSelectorView.updateScrollDirection(direction: .horizontal)
        } else { //lanscape
            //padding
            var bottomPadding = view.safeAreaInsets.bottom
            if (bottomPadding == 0) {
                bottomPadding = 10 //add some anyways for the aesthetics
            }
            
            //activate new
            wordSearchViewWidthAnchor = wordSearchView.widthAnchor.constraint(equalToConstant: self.view.frame.height - bottomPadding*2)
            wordSearchViewWidthAnchor?.isActive = true
            
            wordSelectorViewConstraints = [wordSelectorView.leadingAnchor.constraint(equalTo: wordSearchView.trailingAnchor, constant: 10),
                                           wordSelectorView.widthAnchor.constraint(equalToConstant: 90),
                                           wordSelectorView.heightAnchor.constraint(equalTo: wordSearchView.heightAnchor),
                                           wordSelectorView.centerYAnchor.constraint(equalTo: wordSearchView.centerYAnchor)
                                          ]
            
            NSLayoutConstraint.activate(wordSelectorViewConstraints)
            
            wordsFoundViewConstraints = [wordCountLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                                         wordCountLabel.trailingAnchor.constraint(equalTo: wordSearchView.safeAreaLayoutGuide.leadingAnchor, constant: -30),
            ]
            
            NSLayoutConstraint.activate(wordsFoundViewConstraints)
            
            wordSelectorView.updateScrollDirection(direction: .vertical)
        }
    }
    
    fileprivate func setupPlayer(){
        guard let url = Bundle.main.url(forResource: "hey", withExtension: "mp3") else {return}
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print(error)
        }
        player.prepareToPlay()
        player.numberOfLoops = -1
    }
    
    //MARK: Animations
    /// fades views in on viewDidLoad
    fileprivate func animateIn(){
        UIView.animate(withDuration: 0.1, animations: {
            self.homeButton.alpha = 1
            self.refreshButton.alpha = 1
        }) { (_) in
            self.reloadWordSearch(first: true)
        }
    }
    
    /// pops word search view and either populates chars for the first time or reloads them
    fileprivate func reloadWordSearch(first: Bool){
        UIView.animate(withDuration: 0.2, animations: {
            self.wordSearchView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            if first {
                self.wordSearchView.alpha = 1
            }
        }, completion: { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.wordSearchView.transform = CGAffineTransform.identity
                if first {
                    self.wordSelectorView.alpha = 1
                    self.wordCountLabel.alpha = 1
                }
            }, completion: { (_) in
                if first {
                    self.wordSearchView.populateChars()
                } else {
                    self.wordSearchView.reloadChars()
                    self.wordsFound = 0
                }
            })
        })
    }
    
    //MARK: Event Handlers
    /// handler for refresh button, reloads the words search
    @objc fileprivate func refreshPressed(_ sender: UIButton?){
        reloadWordSearch(first: false)
    }
    
    @objc fileprivate func homePressed(_ sender: UIButton?){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func orientationChanged(){
        updateConstraints()
    }
    
    fileprivate func endGame(){
        delegate?.stopPlaying()
        player.play()
        let endView = EndGameView()
        endView.delegate = self
        view.addSubview(endView)
        NSLayoutConstraint.activate([
            endView.topAnchor.constraint(equalTo: view.topAnchor),
            endView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            endView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            endView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    //MARK: Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension GameViewController: WordSearchViewDelegate {
    func foundWord(word: Word) {
        wordsFound += 1
        wordSelectorView.removeWordFromSelection(word: word)
    }
    
    func updateWords(words: [Word]) {
        self.words = words
    }
}

extension GameViewController: EndGameViewDelegate {
    func closeView(_ sender: EndGameView) {
        player.stop()
        player.currentTime = 0
        delegate?.startPlaying()
        player.prepareToPlay()
        sender.removeFromSuperview()
        reloadWordSearch(first: false)
    }
}
