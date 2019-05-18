//
//  ViewController.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-13.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //MARK: Vars
    var wordSearchViewWidthAnchor : NSLayoutConstraint?
    var wordSelectorViewConstraints = [NSLayoutConstraint]()
    
    var wordsFound = 0 {
        didSet{
            wordCountLabel.text = "Found: \(wordsFound)/8"
        }
    }
    
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
    
    private var wordCountLabel : UILabel = {
        let label = UILabel()
        label.text = "Found: 0/8"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        label.textColor = UIColor.offWhite
        return label
    }()
    
    private lazy var refreshButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "refresh")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.offWhite
        button.alpha = 0
        button.addTarget(self, action: #selector(refreshPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var wordSearchView : WordSearchView = {
        let view = WordSearchView(size: 10)
        view.alpha = 0
        view.delegate = self
        return view
    }()
    
    private lazy var wordSelectorView : WordSelectorView = {
        let view = WordSelectorView()
        view.alpha = 0
        view.delegate = self
        return view
    }()
    
    //MARK: Init
    required init(){
        super.init(nibName: nil, bundle: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupConstraints()
        animateIn()
    }

    //MARK: Setup
    fileprivate func setup(){
         NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        view.backgroundColor = UIColor.highlight
        
        //add subviews
        view.addSubview(titleLabel)
        view.addSubview(wordCountLabel)
        view.addSubview(refreshButton)
        view.addSubview(wordSelectorView)
        view.addSubview(wordSearchView)
    }
    
    fileprivate func setupConstraints(){
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            
            wordCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            wordCountLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            
            refreshButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            refreshButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            
            
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
        
        //update new
        if (view.frame.height > view.frame.width) {
            wordSearchViewWidthAnchor?.isActive = false
            NSLayoutConstraint.deactivate(wordSelectorViewConstraints)
            
            wordSearchViewWidthAnchor = wordSearchView.widthAnchor.constraint(equalToConstant: self.view.frame.width)
            wordSearchViewWidthAnchor?.isActive = true
            
            wordSelectorViewConstraints = [wordSelectorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                           wordSelectorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                                           wordSelectorView.heightAnchor.constraint(equalToConstant: 60),
                                           wordSelectorView.topAnchor.constraint(equalTo: wordSearchView.bottomAnchor)]
            
            NSLayoutConstraint.activate(wordSelectorViewConstraints)
            
            wordSelectorView.updateScrollDirection(direction: .horizontal)
        } else {
            var bottomPadding = view.safeAreaInsets.bottom
            if (bottomPadding == 0) {
                bottomPadding = 10 //add some anyways for the aesthetics
            }
            
            wordSearchViewWidthAnchor = wordSearchView.widthAnchor.constraint(equalToConstant: self.view.frame.height - bottomPadding*2)
            wordSearchViewWidthAnchor?.isActive = true
            
            wordSelectorViewConstraints = [wordSelectorView.leadingAnchor.constraint(equalTo: wordSearchView.trailingAnchor, constant: 10),
                                           wordSelectorView.widthAnchor.constraint(equalToConstant: 90),
                                           wordSelectorView.heightAnchor.constraint(equalTo: wordSearchView.heightAnchor),
                                           wordSelectorView.centerYAnchor.constraint(equalTo: wordSearchView.centerYAnchor)
                                          ]
            
            NSLayoutConstraint.activate(wordSelectorViewConstraints)
            
            wordSelectorView.updateScrollDirection(direction: .vertical)
        }
    }
    
    //MARK: Animations
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
        self.wordSelectorView.reset()
    }
    
    @objc fileprivate func orientationChanged(){
        updateConstraints()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension ViewController: WordSelectorViewDelegate {
    func showWord(word: String?) {
        guard let word = word else {return}
        wordSearchView.showWord(named: word)
    }
}

extension ViewController: WordSearchViewDelegate {
    func foundWord(word: Word) {
        wordsFound += 1
        wordSelectorView.removeWordFromSelection(word: word)
    }
}
