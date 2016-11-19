//
//  BaseField.swift
//  Pods
//
//  Created by Sam Williams on 1/7/16.
//
//

import Foundation


public enum LoadState {
    case notLoaded
    case loaded
    case loading
    case error
}

public enum ValidationState:Equatable {
    case unknown
    case invalid([String])
    case valid
    
    public var isInvalid: Bool {
        switch self {
        case .invalid: return true
        default: return false
        }
    }
    
    public var isValid: Bool {
        return self == .valid
    }
}
public func ==(lhs:ValidationState, rhs:ValidationState) -> Bool {
    switch (lhs, rhs) {
    case (.unknown, .unknown): return true
    case (.valid, .valid): return true
    case (let .invalid(leftMessages), let .invalid(rightMessages)): return leftMessages == rightMessages
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
    
    func addValidationError(_ message:String)
    func resetValidationState()
    func validate() -> ValidationState

    func read(from dictionary:[String:AnyObject])
    func write(to dictionary:inout [String:AnyObject], seenFields:inout [FieldType], explicitNull: Bool)
}

public extension FieldType {
    /// A version of writeToDictionary with optional params, since that's not possible with just the protocol.
    public func write(to dictionary:inout [String:AnyObject], explicitNull: Bool = false) {
        var seenFields:[FieldType] = []
        self.write(to: &dictionary, seenFields: &seenFields, explicitNull: explicitNull)
    }
}


let DefaultObserverKey:NSString = "____"
let DefaultValueTransformerKey = "default"

open class BaseField<T>: FieldType, Observer, Observable {
    public typealias ValueType = T
    
    open var valueType:Any.Type {
        return T.self
    }
    
    /**
     Information about whether this field's value has been set
     */
    open var loadState:LoadState = .notLoaded
    
    /**
     A human-readable name for this field.
     */
    open var name:String?
    
    /**
     Desired position in forms
     */
    open var priority:Int = 0
    
    /**
     An internal identifier (e.g., for identifying form fields)
     */
    open var key:String?
    
    /**
     The value contained in this field.  Note: it's always Optional.
     */
    open var value:T? {
        didSet {
            self.valueUpdated(oldValue: oldValue, newValue: self.value)
        }
    }
    
    open var anyObjectValue:AnyObject? {
        get {
            return self.value as AnyObject?
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
    
    open var anyValue:Any? {
        get {
            // It's important to cast to `Any?` rather than `Any`.
            // Casting to `Any` seems to hide the optional in a way that's hard to unwrap.
            return self.value as Any?
        }
    }
    
    open func valueUpdated(oldValue:T?, newValue: T?) {
        self.loadState = .loaded
        self.validationState = .unknown
        self.updatedAt = Date()
        self.valueUpdatedHandler?(newValue)
    }
    
    
    // MARK: -
    
    internal var valueUpdatedHandler:((T?) -> Void)?
    
    open func valueUpdated(_ handler: @escaping ((T?) -> Void)) -> Self {
        self.valueUpdatedHandler = handler
        return self
    }
    
    
    open var changedAt:Date?
    open var updatedAt:Date?
    
    
    /**
     Initialize a new field.
     */
    init(value:T?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        if let value = value {
            self.value = value
            
            // didSet isn't triggered from init
            self.loadState = .loaded
        }
        self.name = name
        self.priority = priority
        self.key = key
    }
    
    // MARK: - Validation
    
    internal var validationRules:[ValidationRule<T>] = []
    
    open  var validationState:ValidationState = .unknown
    
    /**
     Test whether the current field value passes all the validation rules.
     
     - returns: A ValidationState that includes error messages, if applicable.
     */
    open func validate() -> ValidationState {
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
        self.validationState = valid ? .valid : .invalid(messages)
        return self.validationState
    }
    
    open func validateIfNeeded() -> ValidationState {
        if self.validationState == .unknown {
            self.validate()
        }
        return self.validationState
    }
    
    open func resetValidationState() {
        self.validationState = .unknown
    }
    
    open func addValidationError(_ message:String) {
        switch self.validationState {
        case .invalid(var messages):
            messages.append(message)
            self.validationState = .invalid(messages)
        default:
            self.validationState = .invalid([message])
        }
    }
    
    /**
     Adds a validation rule to the field.
     
     - parameter message: A message explaining why validation failed, in the form of a partial sentence (e.g., "must be zonzero")
     - parameter allowNil: Whether nil values should be considered valid
     - parameter rule: A closure containing validation logic for an unwrapped field value
     */
    open func require(message:String?=nil, allowNil:Bool=true, test:@escaping ((T) -> Bool)) -> Self {
        let rule = ValidationRule<T>(test: test, message:message, allowNil: allowNil)
        return self.require(rule)
    }
    
    open func requireNotNil() -> Self {
        return self.require(message: "is required", allowNil:false) { T -> Bool in return true }
    }
    
    open func require(_ rule: ValidationRule<T>) -> Self {
        self.validationRules.append(rule)
        return self
    }
    
    internal func valueChanged() {
        self.changedAt = Date()
        self.notifyObservers()
    }
    
    // MARK: - Observation
    
    open var observations = ObservationRegistry<T>()
    
    /**
     If a field is registered as an observer, it will set its own value to the observed new value.
     */
    open func valueChanged<ObservableType:Observable>(_ value:T?, observable:ObservableType?) {
        self.value = value
    }
    
    // MARK: - Dictionary values
    
    open func read(from dictionary:[String:AnyObject]) { }
    open func write(to dictionary: inout [String : AnyObject], seenFields: inout [FieldType], explicitNull: Bool = false) {
        if let key = self.key {
            if seenFields.contains(where: {$0 === self}) {
                self.writeSeenValue(to: &dictionary, seenFields: &seenFields, key: key)
            } else {
                seenFields.append(self)
                self.writeUnseenValue(to: &dictionary, seenFields: &seenFields, key: key, explicitNull: explicitNull)
            }
        }
    }
    
    open func writeUnseenValue(to dictionary: inout [String : AnyObject], seenFields: inout [FieldType], key: String, explicitNull: Bool = false) {
        // Implement in subclass
    }
    
    open func writeSeenValue(to dictionary: inout [String : AnyObject], seenFields: inout [FieldType], key: String) {
        // Implement in subclass
    }
    
}
