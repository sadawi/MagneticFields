//
//  FieldModel.swift
//  Pods
//
//  Created by Sam Williams on 11/27/15.
//
//

import Foundation

public protocol FieldModel {
}

extension FieldModel {
//    public func fields() -> NSDictionary {
//        let result = NSMutableDictionary()
//        let mirror = Mirror(reflecting: self)
//        for child in mirror.children {
//            if let label = child.label, value = child.value as? FieldType {
//                result[label] = value
//            }
////            if let value = child.value as? BaseField<Any>, label = child.label {
////                result[label] = value
////            }
//        }
//        return NSDictionary(dictionary: result)
//    }

    public func fields() -> [String:BaseField<Any>] {
        var result:[String:BaseField<Any>] = [:]
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            print(child.value as? BaseField<Any>)
            if let label = child.label, value = child.value as? BaseField<Any> {
                result[label] = value
            }
            //            if let value = child.value as? BaseField<Any>, label = child.label {
            //                result[label] = value
            //            }
        }
        return result
    }

    
//    public var dictionaryValue:[String:AnyObject] {
//        get {
//            var result:[String:AnyObject] = [:]
//            for (name, field) in self.fields() {
//                let f = field as? BaseField
//                if let name = name as? String, field = field as? BaseField<AnyObject>, value = field.value {
//                    result[name] = field.value
//                }
//            }
//            return result
//        }
//        set {
//        }
//    }
}