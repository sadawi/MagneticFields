//
//  Observable.swift
//  Pods
//
//  Created by Sam Williams on 1/5/16.
//
//

import Foundation

/**
 An object that has a single observable value and can register observers to be notified when that value changes.
 
 Your class is responsible for calling self.notifyObservers() when appropriate
 
 Note: The only reason this is a class protocol is that marking its methods as "mutating" seemed to cause segfaults!
 */
public protocol Observable: class {
    typealias ValueType
    var observableValue: ValueType? { get set }
    var observations:[ObservationKey:Observation<ValueType>] { get set }
}

public extension Observable {
    public func addObserver<U:Observer where U.ValueType==ValueType>(observer:U?) -> Observation<ValueType> {
        return self.addObserver(observer, action: nil)
    }
    
    public func addObserver(action action:(ValueType? -> Void)?) -> Observation<ValueType> {
        let observation = Observation<ValueType>(observer:nil, action:action)
        self.observations[observation.key] = observation
        observation.call(value:self.observableValue, observable:self)
        return observation
//        return self.addObserver(nil, action: action)
    }

    public func notifyObservers() {
        for (_, observation) in self.observations {
            observation.call(value:self.observableValue, observable:self)
        }
    }
    
    public func addObserver<U:Observer where U.ValueType==ValueType>(observer:U?, action:(ValueType? -> Void)?) -> Observation<ValueType> {
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
    public func removeObserver<U:Observer where U.ValueType==ValueType>(observer:U) {
        self.observations[Observation<ValueType>.keyForObserver(observer)] = nil
    }
}

infix operator <-- { associativity left precedence 95 }
infix operator --> { associativity left precedence 95 }
infix operator -/-> { associativity left precedence 95 }
infix operator <--> { associativity left precedence 95 }

public func <--<T:Observable, U:Observer where U.ValueType == T.ValueType>(observer:U, observedField:T) {
    observedField.addObserver(observer)
}

public func --><T:Observable, U:Observer where U.ValueType == T.ValueType>(observable:T, observer:U) -> Observation<T.ValueType> {
    return observable.addObserver(observer)
}

public func --><T:Observable>(observable:T, onChange:(T.ValueType? -> Void)) -> Observation<T.ValueType> {
    return observable.addObserver(action: onChange)
}

public func -/-><T:Observable, U:Observer where U.ValueType == T.ValueType>(observable:T, observer:U) {
    observable.removeObserver(observer)
}

public func <--><T where T:Observer, T:Observable>(left: T, right: T) {
    // Order is important!
    right.addObserver(left)
    left.addObserver(right)
}

