//
//  WordFindView.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

class WordSelectorView: UIView {
    //MARS: Vars
    private let id = "cell"
    public var words = [Word]() {
        didSet{
            collectionView.reloadData()
            indexPath.item = words.count/2
        }
    }
    
    private var indexPath = IndexPath(item: 0, section: 0) {
        didSet{
             collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        }
    }
    
    let backImage = UIImage(named: "back").resize(targetSize: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
    let forwardImage = UIImage(named: "forward").resize(targetSize: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
    let upImage = UIImage(named: "back").rotate(radians: .pi/2).resize(targetSize: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
    let downImage = UIImage(named: "forward").rotate(radians: .pi/2).resize(targetSize: CGSize(width: 30, height: 30))?.withRenderingMode(.alwaysTemplate)
    

    //MARK: View Components
    private var stackView : UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
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
    
    private lazy var forwardButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "forward")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.gray
        button.addTarget(self, action: #selector(forward(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 12
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    public lazy var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SelectorCell.self, forCellWithReuseIdentifier: id)
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
    fileprivate func setup(){
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(forwardButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    //MARK: Functions
    public func removeWordFromSelection(word: Word){
        guard let index = words.firstIndex(of: word) else {print("word index NOT found");return}
        words.remove(at: index)
    }
    
    public func updateScrollDirection(direction : UICollectionView.ScrollDirection){
        layout.scrollDirection = direction
        if words.count != 0 {
            indexPath.item = words.count/2
        }
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
    }
    
    @objc private func back(_ sender: UIButton){
        let numVisible = collectionView.visibleCells.count
        let numWords = words.count
        let newItem = indexPath.item - 1
        if newItem < numVisible/2 { return }
        indexPath.item = newItem
    }
    
    @objc private func forward(_ sender: UIButton){
        let numVisible = collectionView.visibleCells.count
        let numWords = words.count
        let newItem = indexPath.item + 1
        if newItem > numWords - 1 - numVisible/2 { return }
        indexPath.item = newItem
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! SelectorCell
        cell.word = words[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    //sizing
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 40)
    }
}

extension WordSelectorView: SelectorCellDelegate {
    func panned(_ sender: SelectorCell) {
        
    }
}

