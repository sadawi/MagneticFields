//
//  operators.swift
//  Pods
//
//  Created by Sam Williams on 11/27/15.
//
//

import Foundation


public func ==<T:Equatable>(left: Field<T>, right: T) -> Bool {
    return left.value == right
}

public func ==<T>(left: T, right: Field<T>) -> Bool {
    return left == right.value
}
