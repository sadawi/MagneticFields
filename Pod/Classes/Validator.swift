//
//  Validator.swift
//  Pods
//
//  Created by Sam Williams on 11/28/15.
//
//

import Foundation

public class Validator<ValueType> {
    var rule:(ValueType -> Bool)?
    var message:String
    var allowNil:Bool
    
    init(message:String?=nil, rule:(ValueType -> Bool)?=nil, allowNil:Bool = true) {
        self.message = message ?? "is invalid"
        self.rule = rule
        self.allowNil = allowNil
    }
    
    public func validate(value:ValueType?) -> Bool {
        if let unwrappedValue = value {
            if let rule = self.rule {
                return rule(unwrappedValue)
            } else {
                return true
            }
        } else {
            return self.allowNil
        }
    }
}