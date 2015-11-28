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
infix operator <--> { associativity left precedence 95 }

public func <--<T>(observingField:Field<T>, observedField:Field<T>) {
    observedField.addObserver(observingField)
    observingField.value = observedField.value
}

public func --><T>(observedField:Field<T>, observingField:Field<T>) {
    observingField <-- observedField
}

public func --><T>(observedField:Field<T>, onChange:(BaseField<T> -> Void)) {
    observedField.observe(onChange)
}

public func <--><T>(left: Field<T>, right: Field<T>) {
    left.addObserver(right)
    left.value = right.value
    right.addObserver(left)
}
public func ==<T:Equatable>(left: Field<T>, right: T) -> Bool {
    return left.value == right
}

public func ==<T>(left: T, right: Field<T>) -> Bool {
    return left == right.value
}
