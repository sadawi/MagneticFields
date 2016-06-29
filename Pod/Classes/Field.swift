//
//  File.swift
//  Pods
//
//  Created by Sam Williams on 11/25/15.
//
//

import Foundation

public class Field<T:Equatable>: BaseField<T>, Equatable {
    public var valueTransformers:[String:ValueTransformer<T>] = [:]
    
    public override init(value:T?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        super.init(value: value, name: name, priority: priority, key: key)
    }
    
    /**
     Sets a ValueTransformer for this field.  An identifier can be provided to distinguish different transformers.
     
     - parameter transformer: The ValueTransformer to set
     - parameter name: An identifier for the transformer.
     */
    public func transform(transformer:ValueTransformer<T>, name transformerName:String?=nil) -> Self {
        self.valueTransformers[transformerName ?? DefaultValueTransformerKey] = transformer
        return self
    }
    
    /**
     Adds a value transformer (with optional name) for this field.
     
     - parameter name: A string used to identify this transformer. If omitted, will be the default transformer.
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
    
    public override func valueUpdated(oldValue oldValue:T?, newValue: T?) {
        super.valueUpdated(oldValue: oldValue, newValue: newValue)
        if oldValue != self.value {
            self.valueChanged()
        }
    }
    
    // MARK: Value transformers
    
    public func valueTransformer(name key: String? = nil) -> ValueTransformer<T> {
        return self.valueTransformers[key ??  DefaultValueTransformerKey] ?? self.defaultValueTransformer()
    }
    
    // MARK: - Dictionary values
    
    public override func readFromDictionary(dictionary:[String:AnyObject]) {
        if let key = self.key, let dictionaryValue = dictionary[key] {
            self.value = self.valueTransformer().importValue(dictionaryValue)
        }
    }

    public override func writeUnseenValueToDictionary(inout dictionary: [String : AnyObject], inout seenFields: [FieldType], key: String, explicitNull: Bool = false) {
        dictionary[key] = self.valueTransformer().exportValue(self.value, explicitNull: explicitNull)
    }

    public override func writeSeenValueToDictionary(inout dictionary: [String : AnyObject], inout seenFields: [FieldType], key: String) {
        self.writeUnseenValueToDictionary(&dictionary, seenFields: &seenFields, key: key)
    }

}

public func ==<T:Equatable>(left: Field<T>, right: Field<T>) -> Bool {
    return left.value == right.value
}

