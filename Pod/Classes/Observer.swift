//
//  Observer.swift
//  Pods
//
//  Created by Sam Williams on 1/5/16.
//
//

import Foundation

public protocol Observer:AnyObject {
    associatedtype ObserverValueType
    func valueChanged<ObservableType:Observable>(value:ObserverValueType?, observable:ObservableType?)
}
