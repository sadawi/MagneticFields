//
//  ArrayField.swift
//  Pods
//
//  Created by Sam Williams on 1/7/16.
//
//

import Foundation

prefix operator *

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
open class ArrayField<T:Equatable>: BaseField<[T]> {
    /**
     A field describing how individual values will be transformed and validated.
     */
    open var field:Field<T>
    
    open override var value:[T]? {
        didSet {
            self.valueUpdated(oldValue: oldValue, newValue: self.value)
        }
    }
    
    public init(_ field:Field<T>, value:[T]?=[], name:String?=nil, priority:Int=0, key:String?=nil) {
        self.field = field
        super.init(name: name ?? field.name, priority: priority ?? field.priority, key:key ?? field.key)
        self.value = value
    }
    
    open func append(_ value:T) {
        self.value?.append(value)
        self.valueAdded(value)
    }
    
    open func removeFirst(_ value:T) {
        if let index = self.value?.index(of: value) {
            self.removeAtIndex(index)
        }
    }

    open func removeAtIndex(_ index:Int) {
        let value = self.value?[index]
        self.value?.remove(at: index)
        if let value = value {
            self.valueRemoved(value)
        }
    }
    
    // MARK: - Dictionary values
    
    open override func read(from dictionary:[String:AnyObject]) {
        if let key = self.key, let dictionaryValues = dictionary[key] as? [AnyObject] {
            self.value = dictionaryValues.map { self.field.valueTransformer().importValue($0) }.flatMap{$0}
        }
    }
    
    open override func writeUnseenValue(to dictionary: inout [String : AnyObject], seenFields: inout [FieldType], key: String, explicitNull: Bool = false) {
        if let key = self.key, let value = self.value {
            let newValue = value.map { self.field.valueTransformer().exportValue($0) }.flatMap { $0 }
            dictionary[key] = newValue as AnyObject
        }
    }

    
    open func valueRemoved(_ value: T) {
    }
    
    open func valueAdded(_ value: T) {
    }
}
