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
        self.setDefaultValueTransformers()
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
    
    public func setDefaultValueTransformers() {
        self.valueTransformers = [DefaultValueTransformerKey: self.defaultValueTransformer()]
    }
    
    // TODO: don't repeat this.
    public func defaultValueTransformer() -> ValueTransformer<T> {
        return SimpleValueTransformer<T>()
    }
    
    internal override func valueUpdated(oldValue oldValue:T?, newValue: T?) {
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

