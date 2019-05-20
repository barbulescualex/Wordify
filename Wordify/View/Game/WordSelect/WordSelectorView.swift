//
//  WordFindView.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

///View to show the words left to find and reveal them on the grid
class WordSelectorView: UIView {
    //MARS: Vars
    
    ///Cell reuse identifier
    private let id = "cell"
    
    ///Words the view holds
    public var words = [Word]() {
        didSet{
            ///reload data and shown index
            collectionView.reloadData()
            indexPath.item = 0
        }
    }
    
    ///The indexPath for the cell in focus
    private var indexPath = IndexPath(item: 0, section: 0) {
        didSet{
            if words.count == 0 {return} //nothing to do
            
            //remove focus
            for cell in collectionView.visibleCells {
                guard let cell = cell as? WordCell else {continue}
                cell.removeFocus()
            }
            
            //set new cell at indexPath in focus
            guard let cell = collectionView.cellForItem(at: indexPath) as? WordCell else {return}
            cell.setInFocus()
            
            //Scroll collectionView to new cell in focus
            collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        }
    }
    
    //Arrow images in all orientations
    private let backImage = UIImage(named: "back").resize(targetSize: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
    private let forwardImage = UIImage(named: "forward").resize(targetSize: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
    private let upImage = UIImage(named: "back").rotate(radians: .pi/2).resize(targetSize: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
    private let downImage = UIImage(named: "forward").rotate(radians: .pi/2).resize(targetSize: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
    

    //MARK: View Components
    ///Stack that holds all the elements in the view
    private var stackView : UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    ///Back button to scroll back in collection view
    private lazy var backButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.gray
        button.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.clipsToBounds = false
        button.imageView?.contentMode = .center
        return button
    }()
    
    ///Forward button to scroll back in collection view
    private lazy var forwardButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "forward")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.gray
        button.addTarget(self, action: #selector(forward(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    ///Layout for collection view
    private var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 12
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    ///Collection view that holds word cells
    private lazy var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WordCell.self, forCellWithReuseIdentifier: id)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    //MARK: Init
    required init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Setup
    
    ///sets up the views
    private func setup(){
        //properties
        translatesAutoresizingMaskIntoConstraints = false
        
        //subviews
        addSubview(stackView)
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(forwardButton)
        
        //constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    //MARK: Functions
    
    ///Tries to remove a specific word form the selector view
    public func removeWordFromSelection(word: Word){
        guard let index = words.firstIndex(of: word) else { return }
        words.remove(at: index)
    }
    
    ///Update the view to new orientation layout
    public func updateOrientation(direction : UICollectionView.ScrollDirection){
        layout.scrollDirection = direction
        switch direction {
            case .horizontal:
                stackView.axis = .horizontal
                backButton.setImage(backImage, for: .normal)
                forwardButton.setImage(forwardImage, for: .normal)
            case .vertical:
                stackView.axis = .vertical
                backButton.setImage(upImage, for: .normal)
                forwardButton.setImage(downImage, for: .normal)
        @unknown default:
            print("unkown default in word selector view update word selector view")
        }
        collectionView.reloadData()
        indexPath.item = 0
    }
    
    //MARK: Event Handlers
    
    ///Back button handler, scrolls the collection view back
    @objc private func back(_ sender: UIButton){
        let newIndex = indexPath.item - 1
        if newIndex < 0 {return}
        indexPath.item = newIndex
    }
    
    ///Forward button handler, scrolls the collection view forward
    @objc private func forward(_ sender: UIButton){
        let newIndex = indexPath.item + 1
        if newIndex > words.count-1 {return}
        indexPath.item = newIndex
    }
}

extension WordSelectorView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //population
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! WordCell
        cell.word = words[indexPath.item]
        if indexPath.item == 0 && self.indexPath.item == 0 {
            cell.setInFocus()
        } else {
            cell.removeFocus()
        }
        return cell
    }
    
    //sizing
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 40)
    }
}

