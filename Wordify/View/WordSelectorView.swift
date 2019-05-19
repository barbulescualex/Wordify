//
//  WordFindView.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

protocol WordSelectorViewDelegate : AnyObject {
    func showWord(word: Word)
}

class WordSelectorView: UIView {
    //MARS: Vars
    private let id = "cell"
    public var words = [Word]() {
        didSet{
            collectionView.reloadData()
        }
    }
    
    weak var delegate : WordSelectorViewDelegate?
    
    //MARK: View Components
    public var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 15
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    public lazy var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.register(SelectorCell.self, forCellWithReuseIdentifier: id)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
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
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)

        ])
    }
    
    //MARK: Functions
    public func removeWordFromSelection(word: Word){
        guard let index = words.firstIndex(of: word) else {return}
        words.remove(at: index)
    }
    
    public func updateScrollDirection(direction : UICollectionView.ScrollDirection){
        layout.scrollDirection = direction
        
        switch direction {
            case .horizontal:
                collectionView.alwaysBounceVertical = false
                collectionView.alwaysBounceHorizontal = true
            case .vertical:
                collectionView.alwaysBounceVertical = true
                collectionView.alwaysBounceHorizontal = false
        @unknown default:
            print("unkown default in word selector view update word selector view")
        }
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectorCell else {return}
        guard let word = cell.word else {return}
        cell.tapped()
        delegate?.showWord(word: word)
    }
    
    //sizing
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 40)
    }
}


