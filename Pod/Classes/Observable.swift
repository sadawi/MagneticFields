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
    var value: ValueType? { get set }
    var observations: ObservationRegistry<ValueType> { get }
}

public extension Observable {
    private func didCreateObservation(observation:Observation<ValueType>) {
        observation.valueChanged(self.value)
        observation.getValue = { [weak self] in
            return self?.value
        }
    }
    
    /**
     Registers a value change observer.
     
     - parameter observer: an Observer object that will receive change notifications
     */
    public func addObserver<U:Observer where U.ValueType==ValueType>(observer:U) -> Observation<ValueType> {
        let observation = Observation<ValueType>()
        observation.onChange = { (value:ValueType?) -> Void in
            observer.valueChanged(value, observable:self)
        }
        self.didCreateObservation(observation)
        self.observations.set(observer, observation)
        return observation
    }
    
    /**
     Registers a value change action.
     
     - parameter action: A closure to be run when the value changes
     */
    public func addObserver(onChange onChange:(ValueType? -> Void)) -> Observation<ValueType> {
        let observation = Observation<ValueType>()
        observation.onChange = onChange
        self.observations.setNil(observation) // TODO
        self.didCreateObservation(observation)
        return observation
    }

    /**
     Registers a value change action, along with a generic owner.
     
     - parameter owner: The observation owner, used only as a key for registering the action
     - parameter action: A closure to be run when the value changes
     */
    public func addObserver<U:Observer where U.ValueType==ValueType>(owner owner:U, onChange:(ValueType? -> Void)) -> Observation<ValueType> {
        let observation = Observation<ValueType>()
        observation.onChange = onChange
        self.observations.set(owner, observation)
        self.didCreateObservation(observation)
        return observation
    }
    
    public func notifyObservers() {
        self.observations.each { observation in
            observation.valueChanged(self.value)
        }
    }
    
    /**
     Unregisters all observers and closures.
     */
    public func removeAllObservers() {
        self.observations.clear()
    }
    
    /**
     Unregisters an observer
     */
    public func removeObserver<U:Observer where U.ValueType==ValueType>(observer:U) {
        self.observations.remove(observer)
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
    return observable.addObserver(onChange: onChange)
}

public func -/-><T:Observable, U:Observer where U.ValueType == T.ValueType>(observable:T, observer:U) {
    observable.removeObserver(observer)
}

public func <--><T where T:Observer, T:Observable>(left: T, right: T) {
    // Order is important!
    right.addObserver(left)
    left.addObserver(right)
}

