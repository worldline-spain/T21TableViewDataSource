//
//  DataSourceItemGeneric.swift
//  T21TableViewDataSource
//
//  Created by Eloi Guzmán Cerón on 08/05/2017.
//  Copyright © 2017 Worldline. All rights reserved.
//

import Foundation

public class DataSourceItemGeneric<Type> : DataSourceComparable, Hashable {
    
    public private(set) var value: Type
    public private(set) var getUIDClosure: (Type) -> (String)
    public private(set) var getIndexClosure: (Type) -> (Float)
    
    public init(_ value: Type, _ getUIDClosure: @escaping (Type) -> (String), _ getIndexClosure: @escaping (Type) -> (Float) = { (item) in return -1 }) {
        self.value = value
        self.getUIDClosure = getUIDClosure
        self.getIndexClosure = getIndexClosure
    }
    
    public var hashValue: Int {
        return self.uid.hashValue
    }
    
    public var index: Float {
        return getIndexClosure(value)
    }
    
    public var uid: String {
        return getUIDClosure(value)
    }
}

extension DataSourceItemGeneric : CustomStringConvertible {
    public var description: String {
        return self.uid
    }
}

public func == <Type>(lhs: DataSourceItemGeneric<Type>, rhs: DataSourceItemGeneric<Type>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public func < <Type>(lhs: DataSourceItemGeneric<Type>, rhs: DataSourceItemGeneric<Type>) -> Bool {
    return lhs.index < rhs.index
}
