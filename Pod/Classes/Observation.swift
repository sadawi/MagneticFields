//
//  Observation.swift
//  Pods
//
//  Created by Sam Williams on 11/28/15.
//
//

import Foundation

public typealias ObservationKey = Int

public class Observation<T> {
//    public typealias ObservationAction = (T? -> Void)
    
    typealias ChainableObservationAction = (T? -> T?)
    
//    var observer:ObserverType?
    
    var action:(T? -> Void)?
    var chainableAction:ChainableObservationAction?
    
    var nextObservation:Observation<T>?
   
    public init(action:(T? -> Void)?) {
        self.action = action
    }
    
    public func call<O:Observable where O.ValueType == T>(value value:T?, observable:O?) {
        // TODO: chainable
        if let action = action {
            action(observable?.value)
        }
//        } else if let observer = self.observer {
////            observer.observableValueChanged(observable?.observableValue, observable: observable)
//        }
        
//        if let chainableAction = chainableAction {
//            let result = chainableAction(observable?.observableValue)
//            if let nextObservation = nextObservation {
//                nextObservation.call(value: result, observable: nil)
//            }
//        } else if let action = action {
//            action(observable?.observableValue)
//        } else if let observer = self.observer {
//            observer.observableValueChanged(observable?.observableValue, observable: observable)
//        }
    }
}

public class ObservationRegistry<V> {
    var observations:[ObservationKey:Observation<V>] = [:]
    
    public init() { }

    class func keyForObject(object:AnyObject?) -> ObservationKey {
        return ObjectIdentifier(object ?? DefaultObserverKey).hashValue
    }
    
    public func clear() {
        self.observations = [:]
    }
    
    public func each(closure:(Observation<V> -> Void)) {
        for (_, observation) in self.observations {
            closure(observation)
        }
    }
    
    public func get<U:Observer where U.ValueType==V>(observer:U?) -> Observation<V>? {
        return self.observations[ObservationRegistry.keyForObject(observer)]
    }

    public func setNil(observation:Observation<V>?) {
        self.observations[ObservationRegistry.keyForObject(nil)] = observation
    }

    public func set<U:Observer where U.ValueType==V>(observer:U?, _ observation:Observation<V>?) {
        self.observations[ObservationRegistry.keyForObject(observer)] = observation
    }
    
    public func remove<U:Observer where U.ValueType==V>(observer:U) {
        self.set(observer, nil)
    }

}

