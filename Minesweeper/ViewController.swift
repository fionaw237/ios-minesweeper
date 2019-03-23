//
//  ViewController.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 25/02/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var indexPathsOfMines = Set<IndexPath>()
    
    let numberOfItemsInSection = 8
    let numberOfSections = 8
    let numberOfMines = 10
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        self.resetGame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indexPathsOfMines = self.getIndexPathsOfMines()
    }
    
    func resetGame() {
        self.indexPathsOfMines = self.getIndexPathsOfMines()
        self.collectionView.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.hasMine = (self.indexPathsOfMines.contains(indexPath))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width / CGFloat(numberOfItemsInSection)) - 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: CollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        if cell.hasMine {
            cell.configureMineContainingCell()
            return
        }
        
        let minesInVicinity = numberOfMinesInVicinityOfCellAt(indexPath: indexPath)
        cell.configureNumberOfMinesLabel(numberOfMines: minesInVicinity)
    }
    
    func getIndexPathsOfMines() -> Set<IndexPath> {
        
        var mineIndexPaths = Set<IndexPath>()
        
        while mineIndexPaths.count < numberOfMines {
            let randomRow = Int.random(in: 0...(numberOfItemsInSection - 1))
            let randomSection = Int.random(in: 0...(numberOfSections - 1))
            let randomIndexPath = IndexPath.init(row: randomRow, section: randomSection)
            if !mineIndexPaths.contains(randomIndexPath) {
                mineIndexPaths.insert(randomIndexPath)
            }
        }
        
        
        
        
        return mineIndexPaths
    }
    
    func numberOfMinesInVicinityOfCellAt(indexPath: IndexPath) -> Int {
        var mineCount = 0
        
        for i in (indexPath.row - 1)...(indexPath.row + 1) {
            
            for j in (indexPath.section - 1)...(indexPath.section + 1) {
                
                if ( !(i == indexPath.row && j == indexPath.section) && i >= 0 && j >= 0 && i < collectionView.numberOfItems(inSection: indexPath.section) && j < collectionView.numberOfSections ) {
                    
                    let cell = collectionView.cellForItem(at: IndexPath.init(row: i, section: j)) as! CollectionViewCell
                    
                    if cell.hasMine {
                        mineCount += 1
                    }
                    
                }
            }
            
        }
        
        return mineCount
    }

}

