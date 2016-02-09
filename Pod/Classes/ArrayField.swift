//
//  ArrayField.swift
//  Pods
//
//  Created by Sam Williams on 1/7/16.
//
//

import Foundation

prefix operator * { }

/**
 Convenience prefix operator for declaring an ArrayField: just put a * in front of the declaration for the equivalent single-valued field.
 
 Note: this will be lower precedence than method calls, so if you want to call methods on the ArrayField, be sure to put parentheses around the whole expression first:
 
 let tags = (*Field<String>()).require(...)
 */
public prefix func *<T>(right:Field<T>) -> ArrayField<T> {
    return ArrayField(right)
}

/**
 
 A multi-valued field.  It's a wrapper for a single-valued field that will handle transformations and validation for individual values.
 
 Attributes that pertain to the top-level array value (e.g., field name, key, etc.) do properly belong to the ArrayField object and can be initialized there,
 but they will default to any values specified in the inner field.
 
 For example, if we defined a field like:
 let tag = Field<String>(name: "Tag")
 
 then the equivalent ArrayField declaration could be any of these:
 let tags = ArrayField(Field<String>(), name: "Tags")
 let tags = ArrayField(Field<String>(name: "Tags"))
 let tags = *Field<String>(name: "Tags")
 
 */
public class ArrayField<T:Hashable>: BaseField<[T]> {
    /**
     A field describing how individual values will be transformed and validated.
     */
    public var field:Field<T>
    
    public override var value:[T]? {
        didSet {
            let oldSet:Set<T>
            let newSet:Set<T>
            
            if let oldValue = oldValue {
                oldSet = Set(oldValue)
            } else {
                oldSet = Set()
            }
            
            if let newValue = self.value {
                newSet = Set(newValue)
            } else {
                newSet = Set()
            }
            
            let removed = oldSet.subtract(newSet)
            let added = newSet.subtract(oldSet)
            
            for value in removed {
                self.valueRemoved(value)
            }
            for value in added {
                self.valueAdded(value)
            }
            
            self.valueUpdated(oldValue: oldValue, newValue: self.value)
        }
    }
    
    public init(_ field:Field<T>, value:[T]?=[], name:String?=nil, priority:Int=0, key:String?=nil) {
        self.field = field
        super.init(name: name ?? field.name, priority: priority ?? field.priority, key:key ?? field.key)
        self.value = value
    }
    
    public func appendValue(value:T) {
        self.value?.append(value)
        self.valueAdded(value)
    }
    
    public func removeValue(value:T) {
        if let index = self.value?.indexOf(value) {
            self.value?.removeAtIndex(index)
            self.valueRemoved(value)
        }
    }
    
    // MARK: - Dictionary values
    
    public override func readFromDictionary(dictionary:[String:AnyObject], name: String, valueTransformer:String?) {
        if let dictionaryValues = dictionary[name] as? [AnyObject] {
            self.value = dictionaryValues.map { self.field.valueTransformers[valueTransformer ?? DefaultValueTransformerKey]?.importValue($0) }.flatMap { $0 }
        }
    }
    
    public override func writeToDictionary(inout dictionary:[String:AnyObject], name: String, valueTransformer:String?) {
        if let value = self.value {
            dictionary[name] = value.map { self.field.valueTransformers[valueTransformer ?? DefaultValueTransformerKey]?.exportValue($0) }.flatMap { $0 }
        }
    }
    
    public override func valueUpdated(oldValue oldValue:[T]?, newValue: [T]?) {
        super.valueUpdated(oldValue: oldValue, newValue: newValue)
    }
    
    public func valueRemoved(value: T) {
    }

    public func valueAdded(value: T) {
    }
    
}