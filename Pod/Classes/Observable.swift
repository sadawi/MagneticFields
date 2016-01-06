//
//  Observable.swift
//  Pods
//
//  Created by Sam Williams on 1/5/16.
//
//

import Foundation

public protocol Observable {
    typealias ValueType
    
    func addObserver(observer:FieldObserver?, action:(ValueType? -> Void)?) -> Observation<ValueType>
}

public extension Observable {
    public func addObserver(observer:FieldObserver?) -> Observation<ValueType> {
        return self.addObserver(observer, action: nil)
    }
    
    public func addObserver(action action:(ValueType? -> Void)?) -> Observation<ValueType> {
        return self.addObserver(nil, action: action)
    }
}