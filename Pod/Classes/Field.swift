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

public protocol FieldType:AnyObject {
    var anyObjectValue: AnyObject? { get }
    var anyValue: Any? { get }
    var valueType:Any.Type { get }
    var name: String? { get set }
    var priority: Int { get set }
    var key: String? { get set }
    var validationState:ValidationState { get }
    
    func addValidationError(message:String)
    func resetValidationState()
    func validate() -> ValidationState
    
    func readFromDictionary(dictionary:[String:AnyObject], name: String, valueTransformer:String)
    func writeToDictionary(inout dictionary:[String:AnyObject], name: String, valueTransformer:String)

    func readFromDictionary(dictionary:[String:AnyObject], name: String)
    func writeToDictionary(inout dictionary:[String:AnyObject], name: String)
}

public protocol FieldObserver:AnyObject {
    func fieldValueChanged(value:Any?, field:FieldType?)
}

let DefaultObserverKey:NSString = "____"
let DefaultValueTransformerKey = "default"

public class BaseField<T>: FieldType, FieldObserver {
    
    public var valueType:Any.Type {
        return T.self
    }
    
    /**
    Information about whether this field's value has been set
    */
    public var state:LoadState = .NotSet
    
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
    }
    
    public var anyValue:Any? {
        get {
            // It's important to cast to `Any?` rather than `Any`.
            // Casting to `Any` seems to hide the optional in a way that's hard to unwrap.
            return self.value as Any?
        }
    }
    
    private func valueUpdated(oldValue oldValue:T?, newValue: T?) {
        self.state = .Set
        self.validationState = .Unknown
        self.updatedAt = NSDate()
    }
    
    
    public var changedAt:NSDate?
    public var updatedAt:NSDate?
    
    
    /**
    Initialize a new field.
    */
    init(value:T?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        self.value = value
        self.name = name
        self.priority = priority
        self.key = key
    }
    
    // MARK: - Validation
    
    private var validationRules:[ValidationRule<T>] = []
    
    public  var validationState:ValidationState = .Unknown
    
    /**
    Test whether the current field value passes all the validation rules.
    */
    public var valid:Bool {
        get {
            return self.validate() == .Valid
        }
    }
    
    /**
    Test whether the current field value passes all the validation rules.
    
    - returns: A ValidationState that includes error messages, if applicable.
    */
    public func validate() -> ValidationState {
        if self.validationState == .Unknown {
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
        }
        return self.validationState
    }
    
    public func resetValidationState() {
        self.validationState = .Unknown
    }
    
    // TODO: think about this. If I set an error manually, validate() won't run the validators.
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
        return self.require(message: "Field is required", allowNil:false) { T -> Bool in return true }
    }
    
    public func require(rule: ValidationRule<T>) -> Self {
        self.validationRules.append(rule)
        return self
    }
    
    private func valueChanged() {
        self.changedAt = NSDate()
        for (_, observation) in self.observations {
            observation.call(value:self.value, field:self)
        }
    }
    
    // MARK: - Observation
    
    private var observations:[Int:Observation<T>] = [:]
    
    /**
    Registers a value change observer, which can either be a FieldObserver object or a closure.
    Registering an observerless closure will replace any previous closure.
    
    - parameter observer: a FieldObserver object that will receive change notifications
    - parameter action: a closure to handle changes
    */
    public func addObserver(observer:FieldObserver?=nil, action:(T? -> Void)?=nil) -> Observation<T> {
        let observation = Observation<T>(observer:observer, action:action)
        self.observations[observation.key] = observation
        observation.call(value:self.value, field:self)
        return observation
    }
    
    /**
    Unregisters an observer
    */
    public func removeObserver(observer:FieldObserver) {
        self.observations[Observation<T>.keyForObserver(observer)] = nil
    }
    
    /**
    Unregisters all observers and closures.
    */
    public func removeAllObservers() {
        self.observations = [:]
    }
    
    
    // MARK: - FieldObserver protocol methods
    
    public func fieldValueChanged(value:Any?, field:FieldType?) {
        if let observedField = field as? BaseField<T> {
            self.value = observedField.value
        }
    }
    
    // MARK: - Dictionary values

    public func readFromDictionary(dictionary:[String:AnyObject], name: String) {
        self.readFromDictionary(dictionary, name: name, valueTransformer: DefaultValueTransformerKey)
    }
    
    /**
    Adds data needed to reconstruct self to a dictionary containing many values.
    */
    public func writeToDictionary(inout dictionary:[String:AnyObject], name: String) {
        dictionary[name] = nil
        self.writeToDictionary(&dictionary, name: name, valueTransformer: DefaultValueTransformerKey)
    }

    
    /**
    Given a dictionary of many values, extracts the relevant ones for this field and updates self.
    */
    public func readFromDictionary(dictionary:[String:AnyObject], name: String, valueTransformer:String) {
    }
    
    /**
    Adds data needed to reconstruct self to a dictionary containing many values.
    */
    public func writeToDictionary(inout dictionary:[String:AnyObject], name: String, valueTransformer:String) {
        dictionary[name] = nil
    }
    
}

public class Field<T:Equatable>: BaseField<T>, Equatable {
    public var valueTransformers:[String:ValueTransformer<T>] = [:]
    
    public override init(value:T?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        super.init(value: value, name: name, priority: priority, key: key)
        self.valueTransformers = [DefaultValueTransformerKey: self.defaultValueTransformer()]
    }
    
    public func transform(transformer:ValueTransformer<T>, name transformerName:String?=nil) -> Self {
        self.valueTransformers[transformerName ?? DefaultValueTransformerKey] = transformer
        return self
    }
    
    /**
    Adds a value transformer (with optional name) for this field.
    
    - parameter transformerName: A string used to identify this transformer. If omitted, will be the default transformer.
    - parameter importValue: A closure mapping an external value (e.g., a string) to a value for this field.
    - parameter exportValue: A closure mapping a field value to an external value
    */
    public func transform(importValue importValue:(AnyObject? -> T?), exportValue:(T? -> AnyObject?), name transformerName: String?=nil) -> Self {
        
        self.valueTransformers[transformerName ?? DefaultValueTransformerKey] = ValueTransformer(importAction: importValue, exportAction: exportValue)
        return self
    }
    
    // TODO: don't repeat this.
    public func defaultValueTransformer() -> ValueTransformer<T> {
        return SimpleValueTransformer<T>()
    }
    
    private override func valueUpdated(oldValue oldValue:T?, newValue: T?) {
        super.valueUpdated(oldValue: oldValue, newValue: newValue)
        if oldValue != self.value {
            self.valueChanged()
        }
    }
    
    // MARK: - Dictionary values
    
    public override func readFromDictionary(dictionary:[String:AnyObject], name: String, valueTransformer:String?) {
        if let dictionaryValue = dictionary[name] {
            self.value = self.valueTransformers[valueTransformer ?? DefaultValueTransformerKey]?.importValue(dictionaryValue)
        }
    }
    
    public override func writeToDictionary(inout dictionary:[String:AnyObject], name: String, valueTransformer:String?) {
        dictionary[name] = self.valueTransformers[valueTransformer ?? DefaultValueTransformerKey]?.exportValue(self.value)
    }
    
}

public func ==<T:Equatable>(left: Field<T>, right: Field<T>) -> Bool {
    return left.value == right.value
}

public class ArrayField<T:Equatable>: BaseField<[T]> {
    public var valueTransformers:[String:ValueTransformer<T>] = [:]
    
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

    public func transform(transformer:ValueTransformer<T>, name transformerName:String? = nil) -> Self {
        self.valueTransformers[transformerName ?? DefaultValueTransformerKey] = transformer
        return self
    }
    
    public func defaultValueTransformer() -> ValueTransformer<T> {
        return SimpleValueTransformer<T>()
    }
    
    public override init(value:[T]?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        super.init(name: name, priority: priority, key:key)
        self.value = value
        self.valueTransformers = [DefaultValueTransformerKey: self.defaultValueTransformer()]
    }
    
    public func appendValue(value:T) {
        if self.value?.indexOf(value) == nil {
            self.value?.append(value)
        }
    }
    
    public func removeValue(value:T) {
        if let index = self.value?.indexOf(value) {
            self.value?.removeAtIndex(index)
        }
    }
    
    // MARK: - Dictionary values
    
    public override func readFromDictionary(dictionary:[String:AnyObject], name: String, valueTransformer:String?) {
        if let dictionaryValues = dictionary[name] as? [AnyObject] {
            self.value = dictionaryValues.map { self.valueTransformers[valueTransformer ?? DefaultValueTransformerKey]?.importValue($0) }.flatMap { $0 }
        }
    }
    
    public override func writeToDictionary(inout dictionary:[String:AnyObject], name: String, valueTransformer:String?) {
        if let value = self.value {
            dictionary[name] = value.map { self.valueTransformers[valueTransformer ?? DefaultValueTransformerKey]?.exportValue($0) }.flatMap { $0 }
        }
    }
    
}