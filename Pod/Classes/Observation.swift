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
    public typealias ObservationAction = (T? -> Void)
    public typealias ObserverType = AnyObject
    
    typealias ChainableObservationAction = (T? -> T?)
    
    var observer:ObserverType?
    
    var action:ObservationAction?
    var chainableAction:ChainableObservationAction?
    
    var nextObservation:Observation<T>?
   
    public init(observer:ObserverType?, action:ObservationAction?) {
        self.observer = observer
        self.action = action
    }
    
    public func call<O:Observable where O.ValueType == T>(value value:T?, observable:O?) {
        // TODO: chainable
        if let action = action {
            action(observable?.observableValue)
        } else if let observer = self.observer {
//            observer.observableValueChanged(observable?.observableValue, observable: observable)
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
    
    class func keyForObserver(observer:ObserverType?) -> ObservationKey {
        return ObjectIdentifier(observer ?? DefaultObserverKey).hashValue
    }
    
    public var key: Int {
        return Observation.keyForObserver(self.observer)
    }
}

