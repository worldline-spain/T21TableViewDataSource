//
//  DataSourceItem.swift
//  T21TableViewDataSource
//
//  Created by Eloi Guzmán Cerón on 08/05/2017.
//  Copyright © 2017 Worldline. All rights reserved.
//

import Foundation

public class DataSourceItem : DataSourceComparable, Hashable {
    
    public private(set) var value: Any
    public private(set) var uid: String
    public private(set) var index: Float = -1
    
    public init(_ value: Any, _ uid: String, _ index: Float = -1) {
        self.value = value
        self.uid = uid
        self.index = index
    }
    
    public var hashValue: Int {
        return self.uid.hashValue
    }
}

extension DataSourceItem : CustomStringConvertible {
    public var description: String {
        return self.uid
    }
}

public func ==(lhs: DataSourceItem, rhs: DataSourceItem) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public func <(lhs: DataSourceItem, rhs: DataSourceItem) -> Bool {
    return lhs.index < rhs.index
}
