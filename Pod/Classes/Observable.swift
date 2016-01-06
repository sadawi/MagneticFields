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
    var observableValue: ValueType? { get set }
    func addObserver(observer:Observer?, action:(ValueType? -> Void)?) -> Observation<ValueType>
    func removeObserver(observer:Observer)
    func removeAllObservers()
}

public extension Observable {
    public func addObserver(observer:Observer?) -> Observation<ValueType> {
        return self.addObserver(observer, action: nil)
    }
    
    public func addObserver(action action:(ValueType? -> Void)?) -> Observation<ValueType> {
        return self.addObserver(nil, action: action)
    }
}