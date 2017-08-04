//
//  ArrayDataSource.swift
//  MyApp
//
//  Created by Eloi Guzmán Cerón on 15/12/16.
//

import UIKit

public class ArrayDataSource<ItemType> where ItemType: DataSourceComparable, ItemType: Hashable {
    
    private typealias ItemTypeHashValue = Int
    
    private var orderedDataSource: Array<ItemType> = [ItemType]()

    private let queue = OperationQueue()
    
    init() {
        self.queue.maxConcurrentOperationCount = 1
    }
    
    public subscript(index: Int) -> ItemType? {
        return orderedDataSource[index]
    }
    
    public subscript(uid: String) -> ItemType? {
        return orderedDataSource.filter({ (item) -> Bool in
            return item.hashValue == uid.hashValue
        }).first
    }
    
    public var count: Int {
        return orderedDataSource.count
    }
    
    internal(set) var items: [ItemType] {
        get {
            return orderedDataSource
        }
        set (value) {
            orderedDataSource = value
        }
    }
    
    private var innerSortingFunction : ( _ a: ItemType,_ b: ItemType) -> Bool = { return $0 < $1 }
    
    public func setSortingFunction( _ sortingFunction: @escaping ( _ a: ItemType,_ b: ItemType) -> (Bool), _ onCompletion: @escaping () -> ()) {
            let newOperation = BlockOperation(block: {
                self.innerSortingFunction = sortingFunction
                DispatchQueue.main.sync {
                    onCompletion()
                }
            })
            addNewOperation(newOperation)
    }
    
    public func getSortingFunction() -> ( _ a: ItemType,_ b: ItemType) -> (Bool) {
        return innerSortingFunction
    }
    
    public func addItems (_ items: [ItemType], _ beforeCompletion: @escaping () -> () = { }, _ onCompletion: @escaping ( _ newDataSource: [ItemType], _ indexesToRemove: [Int], _ indexesToInsert: [Int], _ indexesToReload: [Int]) -> () = { (newDataSource,indexesToRemove,indexesToInsert,indexesToReload) -> () in }) {
        
        let newOperation = BlockOperation(block: {
            
            var orderedDataSourceCopy = self.orderedDataSource
            let sortingFunctionCopy = self.innerSortingFunction

            var orderedNewItems = [ItemType]()
            orderedNewItems.reserveCapacity(items.count)
            var newItemsHash = Dictionary<Int,Bool>()
            var removedIndexes: [(Int,ItemType)] = []
            
            //check for duplicated added items and generate a hash of new items
            for element in items {
                let hash = element.hashValue
                if newItemsHash[hash] == nil {
                    newItemsHash[hash] = true
                    orderedNewItems.append(element)
                }
            }
            orderedNewItems = orderedNewItems.sorted(by: sortingFunctionCopy)
            
            //calculate the deleted indexes ordered using the generated hash
            removedIndexes.reserveCapacity(newItemsHash.count)
            for (index, element) in self.orderedDataSource.enumerated() {
                if newItemsHash[element.hashValue] != nil {
                    removedIndexes.append((index,element))
                }
            }
            
            //find the indexes after the insertions/deletions
            let modifications = self.findIndexes(removedIndexes, orderedNewItems, &self.orderedDataSource, sortingFunctionCopy)
            
            //replace the datasource with the indexes
            
            var acc = 0
            for index in modifications.indexesToRemove {
                orderedDataSourceCopy.remove(at: index - acc)
                acc += 1
            }
            for index in modifications.indexesToInsert {
                orderedDataSourceCopy.insert(orderedNewItems.removeFirst(), at: index)
            }
            
            var finalIndexesToReload = [Int]()
            finalIndexesToReload.reserveCapacity(modifications.indexToReload.count)
            for element in modifications.indexToReload {
                let index = element.0
                finalIndexesToReload.append(index)
                orderedDataSourceCopy.remove(at: index)
                orderedDataSourceCopy.insert(element.1, at: index)
            }
            
            DispatchQueue.main.sync {
                beforeCompletion()
                onCompletion(orderedDataSourceCopy,modifications.indexesToRemove,modifications.indexesToInsert,finalIndexesToReload)
            }
        })
        addNewOperation(newOperation)
    }
    
    private func addNewOperation(_ newOperation: Operation) {
        newOperation.qualityOfService = QualityOfService.userInteractive
        if let prevOperation = queue.operations.last {
            newOperation.addDependency(prevOperation)
        }
        queue.addOperation(newOperation)
    }
    
    public func removeItems (_ items: [ItemType], _ beforeCompletion: @escaping () -> () = { }, _ onCompletion: @escaping (_ newDataSource: [ItemType], _ indexesToRemove: [Int]) -> () = { (newDataSource,indexesToRemove) -> () in }) {
        
        let newOperation = BlockOperation(block: {
            
            var orderedDataSourceCopy = self.orderedDataSource
            let sortingFunctionCopy = self.innerSortingFunction
            
            var newItemsHash = Dictionary<Int,Bool>()
            var removedIndexes: [(Int,ItemType)] = []
            removedIndexes.reserveCapacity(items.count)
            
            //calculate the deleted indexes ordered
            for element in items {
                newItemsHash[element.hashValue] = true
            }
            
            for (index, element) in orderedDataSourceCopy.enumerated() {
                if newItemsHash[element.hashValue] != nil {
                    removedIndexes.append((index,element))
                }
            }
            
            let modifications = self.findIndexes(removedIndexes, [], &orderedDataSourceCopy, sortingFunctionCopy)
            
            //replace the datasource
            var acc = 0
            for index in modifications.indexesToRemove {
                orderedDataSourceCopy.remove(at: index - acc)
                acc += 1
            }
            
            DispatchQueue.main.sync {
                beforeCompletion()
                onCompletion(orderedDataSourceCopy,modifications.indexesToRemove)
            }
            
        })
        addNewOperation(newOperation)
        
    }
    
    public func resetItems (_ items: [ItemType], _ beforeCompletion: @escaping () -> () = { }, _ onCompletion: @escaping (_ newDataSource: [ItemType], _ indexesToRemove: [Int], _ indexesToInsert: [Int]) -> () = { (newDataSource,indexesToRemove,indexesToInsert) -> () in }) {
        
        let newOperation = BlockOperation(block: {
            
            let sortingFunctionCopy = self.innerSortingFunction
            let oldCount = self.orderedDataSource.count
            
            var orderedNewItems = [ItemType]()
            orderedNewItems.reserveCapacity(items.count)
            var newItemsHash = Dictionary<Int,Bool>()
            var accIndex = 0
            
            
            var indexesToRemove = [Int]()
            var indexesToInsert = [Int]()
            
            for index in 0 ..< oldCount {
                indexesToRemove.append(index)
            }
            
            for element in items {
                let hash = element.hashValue
                if newItemsHash[hash] == nil {
                    newItemsHash[hash] = true
                    orderedNewItems.append(element)
                    indexesToInsert.append(accIndex)
                    accIndex += 1
                }
            }
            
            orderedNewItems = orderedNewItems.sorted(by: sortingFunctionCopy)

            
            DispatchQueue.main.sync {
                beforeCompletion()
                onCompletion(orderedNewItems,indexesToRemove,indexesToInsert)
            }
        })
        addNewOperation(newOperation)
        
    }
    
    private func findIndexes(_ orderedIndexesToRemove: [(index: Int, item: ItemType)], _ orderedNewItems: [ItemType],  _ orderedDataSource: inout Array<ItemType>, _ sortingFunction: ( _ a: ItemType,_ b: ItemType) -> Bool) -> (indexesToRemove: [Int],indexesToInsert: [Int], indexToReload: [(Int,ItemType)]) {
        
        var newItems = orderedNewItems
        var deletedItems = orderedIndexesToRemove
        
        //start algorithm to find the inserted, removed and reloaded indexes
        var finalIndexesToRemove: [Int] = []
        var finalIndexesToInsert: [Int] = []
        var finalIndexesToReload = [(Int,ItemType)]()
        
        var changesTable: Dictionary<ItemTypeHashValue,(deletionIndex: Int,insertIndex: Int, newItem: ItemType?)> = Dictionary<ItemTypeHashValue,(Int,Int,ItemType?)>() //used to avoid reloading unmoved cells
        
        var accToInsert: Int = 0
        for index in 0 ..< orderedDataSource.count {
            
            var removed = false
            if let removedIndex = deletedItems.first {
                if index == removedIndex.index {
                    finalIndexesToRemove.append(index)
                    deletedItems.remove(at: 0)
                    accToInsert -= 1
                    removed = true
                    
                    //fill the changes table
                    if changesTable[removedIndex.item.hashValue] != nil {
                       changesTable[removedIndex.item.hashValue]?.deletionIndex = index
                    } else {
                       changesTable[removedIndex.item.hashValue] = (index,-1,nil)
                    }
                }
            }
            
            if !removed {
                var previousItemAvailable = false
                let currentItem = orderedDataSource[index]
                repeat {
                    if let firstItemAdded = newItems.first {
                        if sortingFunction(firstItemAdded,currentItem) {
                            finalIndexesToInsert.append(index + accToInsert)
                            accToInsert += 1
                            previousItemAvailable = true
                            newItems.remove(at: 0)
                            
                            //fill the changes table
                            if changesTable[firstItemAdded.hashValue] != nil {
                                changesTable[firstItemAdded.hashValue]?.insertIndex = index + accToInsert
                                changesTable[firstItemAdded.hashValue]?.newItem = firstItemAdded
                            } else {
                                changesTable[firstItemAdded.hashValue] = (-1,index + accToInsert,firstItemAdded)
                            }
                            
                        } else {
                            previousItemAvailable = false
                        }
                    } else {
                        previousItemAvailable = false
                    }
                } while previousItemAvailable
            }
        }
        
        let count = orderedDataSource.count
        
        var index = 0
        for element in newItems {
            finalIndexesToInsert.append(index + count + accToInsert)
            
            //fill the changes table
            if changesTable[element.hashValue] != nil {
                changesTable[element.hashValue]?.insertIndex = index + count + accToInsert
                changesTable[element.hashValue]?.newItem = element
            } else {
                changesTable[element.hashValue] = (-1,index + count + accToInsert,element)
            }
            
            index += 1
        }
        
        //separate not moved rows to indexes to reload
        var indexesToReload = Set<Int>()
        for element in changesTable {
            if element.value.deletionIndex == element.value.insertIndex {
                finalIndexesToReload.append((element.value.deletionIndex,element.value.newItem!))
                indexesToReload.insert(element.value.deletionIndex)
            }
        }
        
        finalIndexesToRemove = finalIndexesToRemove.filter { (index: Int) -> Bool in
            return !indexesToReload.contains(index)
        }
        
        finalIndexesToInsert = finalIndexesToInsert.filter { (index: Int) -> Bool in
            return !indexesToReload.contains(index)
        }
        
        return (finalIndexesToRemove,finalIndexesToInsert,finalIndexesToReload)
    }
    
    public var description: String {
        return self.orderedDataSource.description
    }
}

extension ArrayDataSource : CustomStringConvertible {
    
}


public protocol DataSourceComparable {
    static func <(lhs: Self, rhs: Self) -> Bool
}
