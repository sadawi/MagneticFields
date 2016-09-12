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
 
 Your class is responsible for calling `self.notifyObservers()` when appropriate.
 
 Note: The only reason this is a class protocol is that marking its methods as "mutating" seemed to cause segfaults!
 */
public protocol Observable: class {
    associatedtype ObservableValueType
    var value: ObservableValueType? { get }
    var observations: ObservationRegistry<ObservableValueType> { get }
}

public extension Observable {
    /**
     Registers a value change observer.
     
     - parameter observer: an Observer object that will receive change notifications
     */
    public func addObserver<U:Observer where U.ObserverValueType==ObservableValueType>(observer:U) -> Observation<ObservableValueType> {
        let observation = Observation<ObservableValueType>()
        observation.onChange = { (value:ObservableValueType?) -> Void in
            observer.valueChanged(value, observable:self)
        }
        observation.valueChanged(self.value)
        observation.getValue = { [weak self] in
            return self?.value
        }
        self.observations.set(observer, observation)
        return observation
    }
    
    /**
     Registers a value change action.
     
     - parameter onChange: A closure to be run when the value changes
     */
    public func addObserver(onChange onChange:(ObservableValueType? -> Void)) -> Observation<ObservableValueType> {
        let observation = self.createClosureObservation(onChange: onChange)
        self.observations.setNil(observation)
        return observation
    }

    /**
     Registers a value change action, along with a generic owner.
     
     - parameter owner: The observation owner, used only as a key for registering the action
     - parameter onChange: A closure to be run when the value changes
     */
    public func addObserver<U:Observer where U.ObserverValueType==ObservableValueType>(owner owner:U, onChange:(ObservableValueType? -> Void)) -> Observation<ObservableValueType> {
        let observation = self.createClosureObservation(onChange: onChange)
        self.observations.set(owner, observation)
        return observation
    }
    
    private func createClosureObservation(onChange onChange:(ObservableValueType? -> Void)) -> Observation<ObservableValueType> {
        let observation = Observation<ObservableValueType>()
        observation.onChange = onChange
        observation.valueChanged(self.value)
        observation.getValue = { [weak self] in
            return self?.value
        }
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
    public func removeObserver<U:Observer where U.ObserverValueType==ObservableValueType>(observer:U) {
        self.observations.remove(observer)
    }
}

infix operator <-- { associativity left precedence 95 }
infix operator --> { associativity left precedence 95 }
infix operator -/-> { associativity left precedence 95 }
infix operator <--> { associativity left precedence 95 }

public func <--<T:Observable, U:Observer where U.ObserverValueType == T.ObservableValueType>(observer:U, observedField:T) {
    observedField.addObserver(observer)
}

public func --><T:Observable, U:Observer where U.ObserverValueType == T.ObservableValueType>(observable:T, observer:U) -> Observation<T.ObservableValueType> {
    return observable.addObserver(observer)
}

public func --><T:Observable>(observable:T, onChange:(T.ObservableValueType? -> Void)) -> Observation<T.ObservableValueType> {
    return observable.addObserver(onChange: onChange)
}

public func -/-><T:Observable, U:Observer where U.ObserverValueType == T.ObservableValueType>(observable:T, observer:U) {
    observable.removeObserver(observer)
}

public func <--><T, U where T:Observer, T:Observable, U:Observer, U:Observable, T.ObserverValueType == U.ObservableValueType, T.ObservableValueType == U.ObserverValueType>(left: T, right: U) {
    // Order is important!
    right.addObserver(left)
    left.addObserver(right)
}

// MARK: Chaining transformations

public class Transformation<T, U>: Observable, Observer {
    public typealias ObserverValueType = T
    public typealias ObservableValueType = U
    var closure: ((T?)->U?)
    public var observations = ObservationRegistry<U>()

    public init(closure: ((T?)->U?)) {
        self.closure = closure
    }
    
    func apply(value: T?) -> U? {
        return self.closure(value)
    }
    
    public private(set) var value: U?
    
    public func valueChanged<ObservableType:Observable>(value:T?, observable:ObservableType?) {
        self.value = self.apply(value)
        self.notifyObservers()
    }
}

/**
 Chainable transformation operator. Takes a closure and creates a Transformation object that can itself be observed.
 
 Example: 
    c.name --> { $0?.uppercaseString } --> d.name
 
 - parameter observable: The object whose value is to be transformed
 - parameter closure: How the value is to be transformed
 - returns: A Transformation object from which the transformed value can be retrieved; it is itself Observable, so it can be chained into another Observer. 
 
 */
public func --><T, U where T:Observable>(observable: T, closure: (T.ObservableValueType? -> U?)) -> Transformation<T.ObservableValueType,U> {
    let transformation = Transformation { (input: T.ObservableValueType?)->U? in
        return closure(input)
    }
    observable.addObserver(transformation)
    return transformation
}