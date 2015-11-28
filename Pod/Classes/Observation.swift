//
//  Observation.swift
//  Pods
//
//  Created by Sam Williams on 11/28/15.
//
//

import Foundation

public struct Observation<T> {
    var owner:AnyObject?
    var observer:FieldObserver?
    var action:(BaseField<T> -> Void)?
    var date:NSDate?
    
    func call(field:BaseField<T>) {
        if let action = action {
            action(field)
        } else if let observer = self.observer {
            observer.fieldValueChanged(field.value, field: field)
        }
    }
    
    static func keyForObserver(observer:FieldObserver?) -> Int {
        return ObjectIdentifier(observer ?? defaultObserverKey).hashValue
    }
    
    var key: Int {
        return Observation.keyForObserver(self.observer)
    }
}

