//
//  operators.swift
//  Pods
//
//  Created by Sam Williams on 11/27/15.
//
//

import Foundation


infix operator <-- { associativity left precedence 95 }
infix operator --> { associativity left precedence 95 }
infix operator -/-> { associativity left precedence 95 }
infix operator <--> { associativity left precedence 95 }

public func <--<T>(observer:FieldObserver, observedField:Field<T>) {
    observedField.addObserver(observer)
}

//public func --><T>(observedField:Field<T>, observer:FieldObserver) -> Observation<T> {
//    return observedField.addObserver(observer)
//}

public func --><T:Observable>(observable:T, observer:FieldObserver) -> Observation<T.ValueType> {
    return observable.addObserver(observer)
}

public func --><T>(observedField:Field<T>, onChange:(T? -> Void)) -> Observation<T> {
    return observedField.addObserver(action: onChange)
}

public func -/-><T>(observedField:Field<T>, observer:FieldObserver) {
    observedField.removeObserver(observer)
}

public func <--><T>(left: Field<T>, right: Field<T>) {
    // Order is important!
    right.addObserver(left)
    left.addObserver(right)
}

public func ==<T:Equatable>(left: Field<T>, right: T) -> Bool {
    return left.value == right
}

public func ==<T>(left: T, right: Field<T>) -> Bool {
    return left == right.value
}
