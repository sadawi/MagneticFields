//
//  Observer.swift
//  Pods
//
//  Created by Sam Williams on 1/5/16.
//
//

import Foundation

public protocol Observer:AnyObject {
    func observableValueChanged<ObservableType:Observable>(value:Any?, observable:ObservableType?)
}
