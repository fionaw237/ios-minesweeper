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
    
    var minesArray: [IndexPath]!
    
    let numberOfItemsInSection = 8
    let numberOfSections = 8
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        self.collectionView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.minesArray = self.getIndexPathsOfMines()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.hasMine = (self.minesArray.contains(indexPath))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width / CGFloat(numberOfItemsInSection)) - 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: CollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        if cell.hasMine {
            cell.numberOfMinesLabel.text = "X"
            
            return
        }
        
        let minesInVicinity = numberOfMinesInVicinityOfCellAt(indexPath: indexPath)
        
        cell.numberOfMinesLabel.text = "\(minesInVicinity)"
    }
    
    func getIndexPathsOfMines() -> [IndexPath] {
        return [IndexPath.init(row: 0, section: 0),
                IndexPath.init(row: 2, section: 2),
                IndexPath.init(row: 4, section: 4),
                IndexPath.init(row: 1, section: 3)]
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

