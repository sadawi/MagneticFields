//
//  Observation.swift
//  Pods
//
//  Created by Sam Williams on 11/28/15.
//
//

import Foundation

public class Observation<T> {
    var owner:AnyObject?
    var observer:FieldObserver?
    
    var action:(T? -> Void)?
    var chainableAction:(T? -> T?)?
    
    var date:NSDate?
    var nextObservation:Observation<T>?
    
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
        return ObjectIdentifier(observer ?? defaultObserverKey).hashValue
    }
    
    var key: Int {
        return Observation.keyForObserver(self.observer)
    }
}

