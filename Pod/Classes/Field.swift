//
//  File.swift
//  Pods
//
//  Created by Sam Williams on 11/25/15.
//
//

import Foundation

public enum LoadState {
    case NotSet
    case Set
    case Loading
    case Error
}

public enum ValidationState:Equatable {
    case Unknown
    case Invalid([String])
    case Valid
}
public func ==(lhs:ValidationState, rhs:ValidationState) -> Bool {
    switch (lhs, rhs) {
    case (.Unknown, .Unknown): return true
    case (.Valid, .Valid): return true
    case (let .Invalid(leftMessages), let .Invalid(rightMessages)): return leftMessages == rightMessages
    default: return false
    }
}

public protocol FieldType:AnyObject { }

public protocol FieldObserver:AnyObject {
    func fieldValueChanged(value:Any?, field:FieldType?)
}

let defaultObserverKey:NSString = "____"

public class BaseField<T>: FieldType, FieldObserver {
    
    public var value:T? {
        didSet {
            self.valueUpdated(oldValue: oldValue, newValue: self.value)
        }
    }
    
    private func valueUpdated(oldValue oldValue:T?, newValue: T?) {
        self.state = .Set
        self.validationState = .Unknown
        self.updatedAt = NSDate()
    }
    
    public var state:LoadState = .NotSet
    public var error:ErrorType?
    public var name:String?
    
    public var changedAt:NSDate?
    public var updatedAt:NSDate?

    
    public var valid:Bool {
        get {
            return self.validate() == .Valid
        }
    }
    
    public init(value:T?=nil, name:String?=nil, allowedValues:[T]?=nil) {
        self.value = value
        self.name = name
        if let allowedValues = allowedValues {
            self.allowedValues = allowedValues
        }
    }
    
    // MARK: - Validation

    public var allowedValues:[T] = []
    public var validators:[Validator<T>] = []
    private var validationState:ValidationState = .Unknown

    public func validate() -> ValidationState {
        if self.validationState == .Unknown {
            var valid = true
            var messages:[String] = []
            for validator in self.validators {
                if validator.validate(self.value) == false {
                    valid = false
                    messages.append(validator.message)
                }
            }
            self.validationState = valid ? .Valid : .Invalid(messages)
        }
        return self.validationState
    }
    
    public func require(message message:String?=nil, presence:Bool=false, rule:(T -> Bool)?=nil) -> Self {
        let validator = Validator<T>(message:message, rule: rule, allowNil: !presence)
        self.validators.append(validator)
        return self
    }
    
    func valueChanged() {
        self.changedAt = NSDate()
        for (_, observation) in self.observations {
            observation.call(value:self.value, field:self)
        }
    }
    
    // MARK: - Observation
    
    private var observations:[Int:Observation<T>] = [:]

    public func addObserver(observer:FieldObserver?=nil, action:(T? -> Void)?=nil) -> Observation<T> {
        let observation = Observation<T>(observer:observer, action:action)
        self.observations[observation.key] = observation
        observation.call(value:self.value, field:self)
        return observation
    }
    
    public func removeObserver(observer:FieldObserver) {
        self.observations[Observation<T>.keyForObserver(observer)] = nil
    }
    
    public func removeAllObservers() {
        self.observations = [:]
    }
    
    
    // MARK: - FieldObserver protocol methods
    
    public func fieldValueChanged(value:Any?, field:FieldType?) {
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
            self.state = .Set
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