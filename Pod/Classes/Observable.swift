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
//    var observations:[Int:Observation<ValueType>] { get set }
    func addObserver(observer:Observer?, action:(ValueType? -> Void)?) -> Observation<ValueType>
}

public extension Observable {
//    public mutating func addObserver(observer:Observer?, action:(ValueType? -> Void)?) -> Observation<ValueType> {
//        let observation:Observation<ValueType> = Observation<ValueType>(observer:observer, action:action)
//        self.observations[observation.key] = observation
//        observation.call(value:self.observableValue, observable:self)
//        return observation
//    }

    
    public func addObserver(observer:Observer?) -> Observation<ValueType> {
        return self.addObserver(observer, action: nil)
    }
    
    public func addObserver(action action:(ValueType? -> Void)?) -> Observation<ValueType> {
        return self.addObserver(nil, action: action)
    }
}