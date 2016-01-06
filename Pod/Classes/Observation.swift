//
//  Observation.swift
//  Pods
//
//  Created by Sam Williams on 11/28/15.
//
//

import Foundation

public class Observation<T> {
    public typealias ObservationAction = (T? -> Void)
    typealias ChainableObservationAction = (T? -> T?)
    
    var observer:Observer?
    
    var action:ObservationAction?
    var chainableAction:ChainableObservationAction?
    
    var nextObservation:Observation<T>?
   
    public init(observer:Observer?, action:ObservationAction?) {
        self.observer = observer
        self.action = action
    }
    
    public func call<O:Observable where O.ValueType == T>(value value:T?, observable:O?) {
        // TODO: chainable
        if let action = action {
            action(observable?.observableValue)
        } else if let observer = self.observer {
            observer.observableValueChanged(observable?.observableValue, observable: observable)
        }
        
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
    
    class func keyForObserver(observer:Observer?) -> Int {
        return ObjectIdentifier(observer ?? DefaultObserverKey).hashValue
    }
    
    var key: Int {
        return Observation.keyForObserver(self.observer)
    }
}

