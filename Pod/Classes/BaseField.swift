//
//  BaseField.swift
//  Pods
//
//  Created by Sam Williams on 1/7/16.
//
//

import Foundation


public enum LoadState {
    case NotLoaded
    case Loaded
    case Loading
    case Error
}

public enum ValidationState:Equatable {
    case Unknown
    case Invalid([String])
    case Valid
    
    public var isInvalid: Bool {
        switch self {
        case .Invalid: return true
        default: return false
        }
    }
    
    public var isValid: Bool {
        return self == .Valid
    }
}
public func ==(lhs:ValidationState, rhs:ValidationState) -> Bool {
    switch (lhs, rhs) {
    case (.Unknown, .Unknown): return true
    case (.Valid, .Valid): return true
    case (let .Invalid(leftMessages), let .Invalid(rightMessages)): return leftMessages == rightMessages
    default: return false
    }
}

public protocol FieldType:AnyObject {
    var anyObjectValue: AnyObject? { get set }
    var anyValue: Any? { get }
    var valueType:Any.Type { get }
    var name: String? { get set }
    var priority: Int { get set }
    var key: String? { get set }
    var validationState:ValidationState { get }
    var loadState:LoadState { get }
    
    func addValidationError(message:String)
    func resetValidationState()
    func validate() -> ValidationState

    func readFromDictionary(dictionary:[String:AnyObject])
    func writeToDictionary(inout dictionary:[String:AnyObject], inout seenFields:[FieldType], explicitNull: Bool)
}

public extension FieldType {
    /// A version of writeToDictionary with optional params, since that's not possible with just the protocol.
    public func writeToDictionary(inout dictionary:[String:AnyObject], explicitNull: Bool = false) {
        var seenFields:[FieldType] = []
        self.writeToDictionary(&dictionary, seenFields: &seenFields, explicitNull: explicitNull)
    }
}


let DefaultObserverKey:NSString = "____"
let DefaultValueTransformerKey = "default"

public class BaseField<T>: FieldType, Observer, Observable {
    public typealias ValueType = T
    
    public var valueType:Any.Type {
        return T.self
    }
    
    /**
     Information about whether this field's value has been set
     */
    public var loadState:LoadState = .NotLoaded
    
    /**
     A human-readable name for this field.
     */
    public var name:String?
    
    /**
     Desired position in forms
     */
    public var priority:Int = 0
    
    /**
     An internal identifier (e.g., for identifying form fields)
     */
    public var key:String?
    
    /**
     The value contained in this field.  Note: it's always Optional.
     */
    public var value:T? {
        didSet {
            self.valueUpdated(oldValue: oldValue, newValue: self.value)
        }
    }
    
    public var anyObjectValue:AnyObject? {
        get {
            return self.value as? AnyObject
        }
        set {
            // Always set nil if it's passed in
            if newValue == nil {
                self.value = nil
            }
            // If it's not nil, only set a value if it's the right type
            if let value = newValue as? T {
                self.value = value
            }
        }
    }
    
    public var anyValue:Any? {
        get {
            // It's important to cast to `Any?` rather than `Any`.
            // Casting to `Any` seems to hide the optional in a way that's hard to unwrap.
            return self.value as Any?
        }
    }
    
    public func valueUpdated(oldValue oldValue:T?, newValue: T?) {
        self.loadState = .Loaded
        self.validationState = .Unknown
        self.updatedAt = NSDate()
        self.valueUpdatedHandler?(newValue)
    }
    
    
    // MARK: -
    
    internal var valueUpdatedHandler:(T? -> Void)?
    
    public func valueUpdated(handler: (T? -> Void)) -> Self {
        self.valueUpdatedHandler = handler
        return self
    }
    
    
    public var changedAt:NSDate?
    public var updatedAt:NSDate?
    
    
    /**
     Initialize a new field.
     */
    init(value:T?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        if let value = value {
            self.value = value
            
            // didSet isn't triggered from init
            self.loadState = .Loaded
        }
        self.name = name
        self.priority = priority
        self.key = key
    }
    
    // MARK: - Validation
    
    internal var validationRules:[ValidationRule<T>] = []
    
    public  var validationState:ValidationState = .Unknown
    
    /**
     Test whether the current field value passes all the validation rules.
     
     - returns: A ValidationState that includes error messages, if applicable.
     */
    public func validate() -> ValidationState {
        var valid = true
        var messages:[String] = []
        for validator in self.validationRules {
            if validator.validate(self.value) == false {
                valid = false
                if let message = validator.message {
                    messages.append(message)
                }
            }
        }
        self.validationState = valid ? .Valid : .Invalid(messages)
        return self.validationState
    }
    
    public func validateIfNeeded() -> ValidationState {
        if self.validationState == .Unknown {
            self.validate()
        }
        return self.validationState
    }
    
    public func resetValidationState() {
        self.validationState = .Unknown
    }
    
    public func addValidationError(message:String) {
        switch self.validationState {
        case .Invalid(var messages):
            messages.append(message)
            self.validationState = .Invalid(messages)
        default:
            self.validationState = .Invalid([message])
        }
    }
    
    /**
     Adds a validation rule to the field.
     
     - parameter message: A message explaining why validation failed, in the form of a partial sentence (e.g., "must be zonzero")
     - parameter allowNil: Whether nil values should be considered valid
     - parameter rule: A closure containing validation logic for an unwrapped field value
     */
    public func require(message message:String?=nil, allowNil:Bool=true, test:(T -> Bool)) -> Self {
        let rule = ValidationRule<T>(test: test, message:message, allowNil: allowNil)
        return self.require(rule)
    }
    
    public func requireNotNil() -> Self {
        return self.require(message: "is required", allowNil:false) { T -> Bool in return true }
    }
    
    public func require(rule: ValidationRule<T>) -> Self {
        self.validationRules.append(rule)
        return self
    }
    
    internal func valueChanged() {
        self.changedAt = NSDate()
        self.notifyObservers()
    }
    
    // MARK: - Observation
    
    public var observations = ObservationRegistry<T>()
    
    /**
     If a field is registered as an observer, it will set its own value to the observed new value.
     */
    public func valueChanged<ObservableType:Observable>(value:T?, observable:ObservableType?) {
        self.value = value
    }
    
    // MARK: - Dictionary values
    
    public func readFromDictionary(dictionary:[String:AnyObject]) { }
    public func writeToDictionary(inout dictionary: [String : AnyObject], inout seenFields: [FieldType], explicitNull: Bool = false) {
        if let key = self.key {
            if seenFields.contains({$0 === self}) {
                self.writeSeenValueToDictionary(&dictionary, seenFields: &seenFields, key: key)
            } else {
                seenFields.append(self)
                self.writeUnseenValueToDictionary(&dictionary, seenFields: &seenFields, key: key, explicitNull: explicitNull)
            }
        }
    }
    
    public func writeUnseenValueToDictionary(inout dictionary: [String : AnyObject], inout seenFields: [FieldType], key: String, explicitNull: Bool = false) {
        // Implement in subclass
    }
    
    public func writeSeenValueToDictionary(inout dictionary: [String : AnyObject], inout seenFields: [FieldType], key: String) {
        // Implement in subclass
    }
    
}