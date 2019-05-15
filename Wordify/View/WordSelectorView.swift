//
//  WordFindView.swift
//  Wordify
//
//  Created by Alex Barbulescu on 2019-05-14.
//  Copyright © 2019 ca.alexs. All rights reserved.
//

import UIKit

protocol WordSelectorViewDelegate : AnyObject {
    func showWord(word: String?)
}

class WordSelectorView: UIView {
    private let id = "cell"
    
    private var data = Data.words
    
    public lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 15
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.register(SelectorCell.self, forCellWithReuseIdentifier: id)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    weak var delegate : WordSelectorViewDelegate?

    required init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    public func removeWordFromSelection(word: Word){
        guard let index = data.firstIndex(of: word.string) else {return}
        data.remove(at: index)
        collectionView.reloadData()
    }
    
    public func reset(){
        data = Data.words
        collectionView.reloadData()
    }

}

extension WordSelectorView: UICollectionViewDelegate, UICollectionViewDataSource, SelectorCellDelegate, UICollectionViewDelegateFlowLayout{
    //population
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! SelectorCell
        cell.word = data[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    //sizing
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(100)
        let height = CGFloat(50)
        return CGSize(width: width, height: height)
    }
    
    func tapped(sender: SelectorCell) {
        delegate?.showWord(word: sender.word)
    }
}


