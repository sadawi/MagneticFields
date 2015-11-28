//
//  File.swift
//  Pods
//
//  Created by Sam Williams on 11/25/15.
//
//

import Foundation

public enum LoadState {
    case NotLoaded
    case Loading
    case Loaded
    case Error
}

public enum ValidationState {
    case Unknown
    case Invalid
    case Valid
}

public protocol FieldType:AnyObject { }

public protocol FieldObserver:AnyObject {
    func fieldValueChanged(field:FieldType)
}

public class BaseField<T>: FieldType, FieldObserver {
    public var value:T? {
        didSet {
            self.valueUpdated(oldValue: oldValue, newValue: self.value)
        }
    }
    
    private func valueUpdated(oldValue oldValue:T?, newValue: T?) {
        self.state = .Loaded
        self.validationState = .Unknown
        self.updatedAt = NSDate()
    }
    
    public var state:LoadState = .NotLoaded
    public var error:ErrorType?
    public var name:String?
    public var allowedValues:[T] = []
    public var validators:[Validator<T>] = []
    
    public var updatedAt:NSDate?

    private var validationState:ValidationState = .Unknown
    
    public var valid:Bool {
        get {
            self.validate()
            return self.validationState == .Valid
        }
    }
    
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
    
    private func validate() {
        if self.validationState == .Unknown {
            var valid = true
            for validator in self.validators {
                valid = valid && validator.validate(self.value)
            }
            self.validationState = valid ? .Valid : .Invalid
        }
    }
    
    public func require(message message:String?=nil, presence:Bool=false, rule:(T -> Bool)?=nil) -> Self {
        let validator = Validator<T>(message:message, rule: rule, allowNil: !presence)
        self.validators.append(validator)
        return self
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

    private override func valueUpdated(oldValue oldValue:T?, newValue: T?) {
        super.valueUpdated(oldValue: oldValue, newValue: newValue)
        if oldValue != self.value {
            self.valueChanged()
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