//
//  CollectionViewDataSource.swift
//  T21TableViewDataSource
//
//  Created by Eloi Guzmán Cerón on 31/05/2017.
//  Copyright © 2017 Worldline. All rights reserved.
//

import Foundation
import UIKit

open class CollectionViewDataSource<ItemType> : NSObject, UICollectionViewDelegate, UICollectionViewDataSource where ItemType: DataSourceComparable, ItemType: Hashable {

    private var dataSource = ArrayDataSource<ItemType>()
    
    //MARK: Animations
    
    public var sortingFunction: ( _ a: ItemType,_ b: ItemType) -> Bool = { return $0 < $1 } {
        didSet {
            self.dataSource.setSortingFunction(self.sortingFunction, {
                self.resetItems(self.dataSource.items)
            })
        }
    }
    
    //MARK: Accessing items
    public weak var collectionView: UICollectionView? {
        didSet {
            collectionView?.dataSource = self
            collectionView?.delegate = self
            onCollectionViewDidSet(collectionView)
        }
    }
    
    public subscript(index: Int) -> ItemType? {
        return dataSource[index]
    }
    
    public subscript(uid: String) -> ItemType? {
        return dataSource[uid]
    }
    
    public var count: Int {
        return dataSource.count
    }
    
    public var items: [ItemType] {
        return dataSource.items
    }
    
    //MARK: Configurable closures
    
    public var onCollectionViewDidSet: ( _ collectionView: UICollectionView?) -> () = { (collectionView) in }
    
    public var onCellForRowFunction : (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ item: ItemType) -> (UICollectionViewCell) = { (collectionView, indexPath, item) in
        return UICollectionViewCell.init()
    }
    
    public var onDidSelectCellFunction : (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ item: ItemType) -> () = { (_,_,_) in }
    
    public var onDidDeselectedCellFunction : (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ item: ItemType) -> () = { (_,_,_) in }
    
    public var onDidHighlightCellFunction : (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ item: ItemType) -> () = { (_,_,_) in }
    
    public var onDidUnhighlightCellFunction : (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ item: ItemType) -> () = { (_,_,_) in }
    
    //MARK: Managing items
    public func addItems(_ items: [ItemType], _ onCompletion: @escaping () -> () = { () -> () in }) {

        if let cv = collectionView {
            dataSource.addItems(items, {
                //noop
            }, { (newDataSource: [ItemType] ,indexesToRemove: [Int], indexesToInsert: [Int], indexesToReload: [Int]) in
                cv.performBatchUpdates({
                    self.dataSource.items = newDataSource
                    var reloadIndexPaths = [IndexPath]()
                    reloadIndexPaths.reserveCapacity(indexesToReload.count)
                    for row in indexesToReload {
                        reloadIndexPaths.append(IndexPath(row: row,section: 0))
                    }
                    cv.reloadItems(at: reloadIndexPaths)
                    
                    var deletedIndexPaths = [IndexPath]()
                    deletedIndexPaths.reserveCapacity(indexesToRemove.count)
                    for row in indexesToRemove {
                        deletedIndexPaths.append(IndexPath(row: row,section: 0))
                    }
                    cv.deleteItems(at: deletedIndexPaths)
                    
                    var insertedIndexPaths = [IndexPath]()
                    insertedIndexPaths.reserveCapacity(indexesToInsert.count)
                    for row in indexesToInsert {
                        insertedIndexPaths.append(IndexPath(row: row,section: 0))
                    }
                    cv.insertItems(at: insertedIndexPaths)
                }, completion: { (finished) in
                    onCompletion()
                })
            })
        }
    }
    
    public func removeItems(_ items: [ItemType], _ onCompletion: @escaping () -> () = { () -> () in }) {
        
        if let cv = collectionView {
            dataSource.removeItems(items, {
                //noop
            }, { (newDataSource: [ItemType], indexesToRemove: [Int]) in
                cv.performBatchUpdates({
                    self.dataSource.items = newDataSource
                    var deletedIndexPaths = [IndexPath]()
                    deletedIndexPaths.reserveCapacity(indexesToRemove.count)
                    for row in indexesToRemove {
                        deletedIndexPaths.append(IndexPath(row: row,section: 0))
                    }
                    cv.deleteItems(at: deletedIndexPaths)
                }, completion: { (finished) in
                    onCompletion()
                })
            })
        }
    }
    
    public func resetItems(_ items: [ItemType], _ onCompletion: @escaping () -> () = { () -> () in }) {
        
        if let cv = collectionView {
            dataSource.resetItems(items, {
                //noop
            }, { (newDataSource: [ItemType], indexesToRemove: [Int], indexesToInsert: [Int]) in
                cv.performBatchUpdates({
                    self.dataSource.items = newDataSource
                    var deletedIndexPaths = [IndexPath]()
                    deletedIndexPaths.reserveCapacity(indexesToRemove.count)
                    for row in indexesToRemove {
                        deletedIndexPaths.append(IndexPath(row: row,section: 0))
                    }
                    cv.deleteItems(at: deletedIndexPaths)
                    
                    var insertedIndexPaths = [IndexPath]()
                    insertedIndexPaths.reserveCapacity(indexesToInsert.count)
                    for row in indexesToInsert {
                        insertedIndexPaths.append(IndexPath(row: row,section: 0))
                    }
                    cv.insertItems(at: insertedIndexPaths)
                }, completion: { (finished) in
                    onCompletion()
                })
            })
        }
    }
    
    //MARK: UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return onCellForRowFunction(collectionView, indexPath, dataSource[indexPath.row]!)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //MARK: UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onDidSelectCellFunction(collectionView,indexPath, dataSource[indexPath.row]!)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        onDidDeselectedCellFunction(collectionView,indexPath, dataSource[indexPath.row]!)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        onDidHighlightCellFunction(collectionView,indexPath, dataSource[indexPath.row]!)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        onDidUnhighlightCellFunction(collectionView,indexPath, dataSource[indexPath.row]!)
    }
}
