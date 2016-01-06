//
//  Observable.swift
//  Pods
//
//  Created by Sam Williams on 1/5/16.
//
//

import Foundation

/**
 Note: The only reason this is a class protocol is that marking some methods as "mutating" seemed to cause segfaults.
 */
public protocol Observable: class {
    typealias ValueType
    var observations:[Int:Observation<ValueType>] { get set }
    var observableValue: ValueType? { get set }
}

public extension Observable {
    public func addObserver(observer:Observer?) -> Observation<ValueType> {
        return self.addObserver(observer, action: nil)
    }
    
    public func addObserver(action action:(ValueType? -> Void)?) -> Observation<ValueType> {
        return self.addObserver(nil, action: action)
    }

    public func notifyObservers() {
        for (_, observation) in self.observations {
            observation.call(value:self.observableValue, observable:self)
        }
    }
    
    public func addObserver(observer:Observer?, action:(ValueType? -> Void)?) -> Observation<ValueType> {
        let observation = Observation<ValueType>(observer:observer, action:action)
        self.observations[observation.key] = observation
        observation.call(value:self.observableValue, observable:self)
        return observation
    }
    
    /**
     Unregisters all observers and closures.
     */
    public func removeAllObservers() {
        self.observations = [:]
    }
    
    /**
     Unregisters an observer
     */
    public func removeObserver(observer:Observer) {
        self.observations[Observation<ValueType>.keyForObserver(observer)] = nil
    }


}