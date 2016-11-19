//
//  File.swift
//  Pods
//
//  Created by Sam Williams on 11/25/15.
//
//

import Foundation

open class Field<T:Equatable>: BaseField<T>, Equatable {
    open var valueTransformers:[String:ValueTransformer<T>] = [:]
    
    public override init(value:T?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        super.init(value: value, name: name, priority: priority, key: key)
    }
    
    /**
     Sets a ValueTransformer for this field.  An identifier can be provided to distinguish different transformers.
     
     - parameter transformer: The ValueTransformer to set
     - parameter name: An identifier for the transformer.
     */
    open func transform(_ transformer:ValueTransformer<T>, name transformerName:String?=nil) -> Self {
        self.valueTransformers[transformerName ?? DefaultValueTransformerKey] = transformer
        return self
    }
    
    /**
     Adds a value transformer (with optional name) for this field.
     
     - parameter name: A string used to identify this transformer. If omitted, will be the default transformer.
     - parameter importValue: A closure mapping an external value (e.g., a string) to a value for this field.
     - parameter exportValue: A closure mapping a field value to an external value
     */
    open func transform(importValue:@escaping ((AnyObject?) -> T?), exportValue:@escaping ((T?) -> AnyObject?), name transformerName: String?=nil) -> Self {
        
        self.valueTransformers[transformerName ?? DefaultValueTransformerKey] = ValueTransformer(importAction: importValue, exportAction: exportValue)
        return self
    }
    
    // TODO: don't repeat this.
    open func defaultValueTransformer() -> ValueTransformer<T> {
        return SimpleValueTransformer<T>()
    }
    
    open override func valueUpdated(oldValue:T?, newValue: T?) {
        super.valueUpdated(oldValue: oldValue, newValue: newValue)
        if oldValue != self.value {
            self.valueChanged()
        }
    }
    
    // MARK: Value transformers
    
    open func valueTransformer(name key: String? = nil) -> ValueTransformer<T> {
        return self.valueTransformers[key ??  DefaultValueTransformerKey] ?? self.defaultValueTransformer()
    }
    
    // MARK: - Dictionary values
    
    open override func read(from dictionary:[String:AnyObject]) {
        if let key = self.key, let dictionaryValue = dictionary[key] {
            self.value = self.valueTransformer().importValue(dictionaryValue)
        }
    }

    open override func writeUnseenValue(to dictionary: inout [String : AnyObject], seenFields: inout [FieldType], key: String, explicitNull: Bool = false) {
        dictionary[key] = self.valueTransformer().exportValue(self.value, explicitNull: explicitNull)
    }

    open override func writeSeenValue(to dictionary: inout [String : AnyObject], seenFields: inout [FieldType], key: String) {
        self.writeUnseenValue(to: &dictionary, seenFields: &seenFields, key: key)
    }

}

public func ==<T:Equatable>(left: Field<T>, right: Field<T>) -> Bool {
    return left.value == right.value
}

