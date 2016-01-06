//
//  Observer.swift
//  Pods
//
//  Created by Sam Williams on 1/5/16.
//
//

import Foundation

public protocol Observer:AnyObject {
    typealias ValueType
    func valueChanged<ObservableType:Observable>(value:ValueType?, observable:ObservableType?)
}
