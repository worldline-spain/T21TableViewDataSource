//
//  TableViewDataSource.swift
//  MyApp
//
//  Created by Eloi Guzmán Cerón on 16/12/16.
//

import UIKit

open class TableViewDataSource<ItemType> : NSObject, UITableViewDataSource, UITableViewDelegate where ItemType: DataSourceComparable, ItemType: Hashable {
    
    private var dataSource = ArrayDataSource<ItemType>()
    
    //MARK: Animations
    public var insertRowAnimation = UITableViewRowAnimation.fade
    public var deleteRowAnimation = UITableViewRowAnimation.fade
    public var reloadRowAnimation = UITableViewRowAnimation.fade

    public var sortingFunction: ( _ a: ItemType,_ b: ItemType) -> Bool = { return $0 < $1 } {
        didSet {
            self.dataSource.setSortingFunction(self.sortingFunction, {
                self.resetItems(self.dataSource.items)
            })
        }
    }
    
    //MARK: Accessing items
    public weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
            self.onTableViewDidSetFunction(tableView)
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
    
    //MARK: TableView DataSource & Delegate Functors
    public var onTableViewDidSetFunction: (_ tableView: UITableView?) -> Void = { (tableView) in }
    
    public var cellForRowFunction: (_ tableView: UITableView, _ indexPath: IndexPath, _ item: ItemType) -> (UITableViewCell) = {(tableView,indexPath,item) in
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "c")
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    public var heightForRowFunction: (_ tableView: UITableView,_ indexPath: IndexPath, _ item: ItemType) -> CGFloat = {
        (tableView,indexPath,item) in
        return 44.0
    }
    
    public var didSelectRowFunction: (_ tableView: UITableView,_ indexPath: IndexPath, _ item: ItemType) -> Void = { (tableView,indexPath,item) in }
    
    public var didDeselectRowFunction: (_ tableView: UITableView,_ indexPath: IndexPath, _ item: ItemType) -> Void = { (tableView,indexPath,item) in }
    
    public var willSelectRowFunction: (_ tableView: UITableView,_ indexPath: IndexPath, _ item: ItemType) -> IndexPath? = {
        (tableView,indexPath,item) in
        return indexPath
    }
    
    public var willDeselectRowFunction: (_ tableView: UITableView,_ indexPath: IndexPath, _ item: ItemType) -> IndexPath? = {
        (tableView,indexPath,item) in
        return indexPath
    }
    

    //MARK: Managing items
    public func addItems(_ items: [ItemType], _ onCompletion: @escaping () -> () = { () -> () in }) {
        dataSource.addItems(items, { () -> () in
            if let t = self.tableView {
                t.beginUpdates()
            }
        }, {(newDataSource,deletions,insertions,reloads) -> () in
            self.dataSource.items = newDataSource
            if let t = self.tableView {
                var reloadIndexPaths = [IndexPath]()
                reloadIndexPaths.reserveCapacity(reloads.count)
                for row in reloads {
                    reloadIndexPaths.append(IndexPath(row: row,section: 0))
                }
                t.reloadRows(at: reloadIndexPaths, with: self.reloadRowAnimation)
                
                
                var deletedIndexPaths = [IndexPath]()
                deletedIndexPaths.reserveCapacity(deletions.count)
                for row in deletions {
                    deletedIndexPaths.append(IndexPath(row: row,section: 0))
                }
                t.deleteRows(at: deletedIndexPaths, with: self.deleteRowAnimation)
                
                var insertedIndexPaths = [IndexPath]()
                insertedIndexPaths.reserveCapacity(insertions.count)
                for row in insertions {
                    insertedIndexPaths.append(IndexPath(row: row,section: 0))
                }
                t.insertRows(at: insertedIndexPaths, with: self.insertRowAnimation)
                t.endUpdates()
                onCompletion()
            }
        })
    }
    
    public func removeItems(_ items: [ItemType], _ onCompletion: @escaping () -> () = { () -> () in }) {
        dataSource.removeItems(items,{ () -> () in
            if let t = self.tableView {
                t.beginUpdates()
            }
        }, {(newDataSource,deletions) -> () in
            self.dataSource.items = newDataSource
            if let t = self.tableView {
                var deletedIndexPaths = [IndexPath]()
                deletedIndexPaths.reserveCapacity(deletions.count)
                for row in deletions {
                    deletedIndexPaths.append(IndexPath(row: row,section: 0))
                }
                t.deleteRows(at: deletedIndexPaths, with: self.deleteRowAnimation)
                t.endUpdates()
                onCompletion()
            }
        })
    }
    
    public func resetItems(_ items: [ItemType], _ onCompletion: @escaping () -> () = { () -> () in }) {
        dataSource.resetItems(items,{ () -> () in
            if let t = self.tableView {
                t.beginUpdates()
            }
        }, {(newDataSource,deletions,insertions) -> () in
            self.dataSource.items = newDataSource
            if let t = self.tableView {
                var deletedIndexPaths = [IndexPath]()
                deletedIndexPaths.reserveCapacity(deletions.count)
                for row in deletions {
                    deletedIndexPaths.append(IndexPath(row: row,section: 0))
                }
                t.deleteRows(at: deletedIndexPaths, with: self.deleteRowAnimation)
                
                var insertedIndexPaths = [IndexPath]()
                insertedIndexPaths.reserveCapacity(insertions.count)
                for row in insertions {
                    insertedIndexPaths.append(IndexPath(row: row,section: 0))
                }
                t.insertRows(at: insertedIndexPaths, with: self.insertRowAnimation)
                t.endUpdates()
                onCompletion()
            }
        })
    }
    
    //MARK: UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        //todo: support for more than one animated section
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cellForRowFunction(tableView,indexPath,self[indexPath.row]!)
    }
    
    //MARK: UITableViewDelegate
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightForRowFunction(tableView,indexPath,self[indexPath.row]!)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectRowFunction(tableView,indexPath,self[indexPath.row]!)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.didDeselectRowFunction(tableView,indexPath,self[indexPath.row]!)
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return self.willSelectRowFunction(tableView,indexPath,self[indexPath.row]!)
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return self.willDeselectRowFunction(tableView,indexPath,self[indexPath.row]!)
    }
}
