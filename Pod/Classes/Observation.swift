//
//  Observation.swift
//  Pods
//
//  Created by Sam Williams on 11/28/15.
//
//

import Foundation

public class Observation<T> {
    typealias ObservationAction = (T? -> Void)
    typealias ChainableObservationAction = (T? -> T?)
    
    var observer:FieldObserver?
    
    var action:ObservationAction?
    var chainableAction:ChainableObservationAction?
    
    var nextObservation:Observation<T>?
   
    init(observer:FieldObserver?, action:ObservationAction?) {
        self.observer = observer
        self.action = action
    }
    
    func call(value value:T?, field:BaseField<T>?) {
        if let chainableAction = chainableAction {
            let result = chainableAction(field?.value)
            if let nextObservation = nextObservation {
                nextObservation.call(value: result, field: nil)
            }
        } else if let action = action {
            action(field?.value)
        } else if let observer = self.observer {
            observer.fieldValueChanged(field?.value, field: field)
        }
    }
    
    class func keyForObserver(observer:FieldObserver?) -> Int {
        return ObjectIdentifier(observer ?? DefaultObserverKey).hashValue
    }
    
    var key: Int {
        return Observation.keyForObserver(self.observer)
    }
}

