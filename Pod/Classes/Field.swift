//
//  File.swift
//  Pods
//
//  Created by Sam Williams on 11/25/15.
//
//

import Foundation

public enum FieldState {
    case NotLoaded
    case Loading
    case Loaded
    case Error
}

public protocol FieldType {
    
}

public protocol FieldObserver:AnyObject {
    func fieldValueChanged(field:FieldType)
}

public class Field<T:Equatable>: FieldType, FieldObserver, Equatable {
    
    public var value:T? {
        didSet {
            self.state = .Loaded
            if oldValue != self.value {
                self.valueChanged()
            }
        }
    }
    public var state:FieldState = .NotLoaded
    public var error:ErrorType?
    public var name:String?
    public var allowedValues:[T] = []
    
    private weak var observedField:Field<T>? {
        didSet {
            if self.observedField == nil {
                if let oldField = oldValue {
                    oldField.removeObserver(self)
                }
            }
        }
    }
    
    private var observers:NSMutableSet = NSMutableSet()
    private var onChange:(Field<T> -> Void)?
    
    public init(value:T?=nil, name:String?=nil, allowedValues:[T]?=nil) {
        self.value = value
        self.name = name
        if let allowedValues = allowedValues {
            self.allowedValues = allowedValues
        }
    }
    
    func valueChanged() {
        for observer in self.observers {
            if let observer = observer as? FieldObserver {
                observer.fieldValueChanged(self)
            }
        }
        if let action = self.onChange {
            action(self)
        }
    }
    
    public func addObserver(observer:FieldObserver) {
        self.observers.addObject(observer)
        if let observerField = observer as? Field<T> {
            observerField.observedField = self
        }
    }
    
    public func observe(action:(Field<T> -> Void)) {
        self.onChange = action
    }
    
    public func removeObserver(observer:FieldObserver) {
        self.observers.removeObject(observer)
        if let observerField = observer as? Field<T> {
            observerField.observedField = nil
        }
    }
    
    public func fieldValueChanged(field:FieldType) {
        if let observedField = field as? Field<T> {
            self.value = observedField.value
        }
    }
}


infix operator <-- { associativity left precedence 95 }
infix operator --> { associativity left precedence 95 }
infix operator <--> { associativity left precedence 95 }

public func <--<T>(observedField:Field<T>, value:T?) {
    observedField.value = value
    observedField.observedField = nil
}

public func <--<T>(observingField:Field<T>, observedField:Field<T>) {
    observedField.addObserver(observingField)
    observingField.value = observedField.value
}

public func --><T>(observedField:Field<T>, observingField:Field<T>) {
    observingField <-- observedField
}

public func --><T>(observedField:Field<T>, onChange:(Field<T> -> Void)) {
    observedField.observe(onChange)
}

public func <--><T>(left: Field<T>, right: Field<T>) {
    left.addObserver(right)
    left.value = right.value
    right.addObserver(left)
}

public func ==<T>(left: Field<T>, right: Field<T>) -> Bool {
    return left.value == right.value
}

public func ==<T>(left: Field<T>, right: T) -> Bool {
    return left.value == right
}

public func ==<T>(left: T, right: Field<T>) -> Bool {
    return left == right.value
}
