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

public protocol FieldType:AnyObject { }

public protocol FieldObserver:AnyObject {
    func fieldValueChanged(field:FieldType)
}

public class BaseField<T>: FieldType, FieldObserver {
    public var value:T? {
        didSet {
            self.state = .Loaded
        }
    }
    
    public var state:FieldState = .NotLoaded
    public var error:ErrorType?
    public var name:String?
    public var allowedValues:[T] = []
    
    private weak var observedField:BaseField<T>? {
        didSet {
            if self.observedField == nil {
                if let oldField = oldValue {
                    oldField.removeObserver(self)
                }
            }
        }
    }
    
    private var observers:NSMutableSet = NSMutableSet()
    private var onChange:(BaseField<T> -> Void)?
    
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
        if let observerField = observer as? BaseField<T> {
            observerField.observedField = self
        }
    }
    
    public func observe(action:(BaseField<T> -> Void)) {
        self.onChange = action
    }
    
    public func removeObserver(observer:FieldObserver) {
        self.observers.removeObject(observer)
        if let observerField = observer as? BaseField<T> {
            observerField.observedField = nil
        }
    }
    
    public func fieldValueChanged(field:FieldType) {
        if let observedField = field as? BaseField<T> {
            self.value = observedField.value
        }
    }
}

public class Field<T:Equatable>: BaseField<T>, Equatable {
    public override init(value:T?=nil, name:String?=nil, allowedValues:[T]?=nil) {
        super.init(value: value, name: name, allowedValues: allowedValues)
    }

    public override var value:T? {
        didSet {
            self.state = .Loaded
            if oldValue != self.value {
                self.valueChanged()
            }
        }
    }
}
public func ==<T:Equatable>(left: Field<T>, right: Field<T>) -> Bool {
    return left.value == right.value
}

public class ArrayField<T:Equatable>: BaseField<[T]> {
    public override var value:[T]? {
        didSet {
            self.state = .Loaded
            var changed = false
            if oldValue != nil && self.value != nil {
                changed = oldValue! != self.value!
            } else if oldValue == nil && self.value == nil {
                changed = false
            } else {
                changed = true
            }
            if changed {
                self.valueChanged()
            }
        }
    }
    
    public init(value:[T]?=nil, name:String?=nil) {
        super.init(name: name)
        self.value = value
    }

}