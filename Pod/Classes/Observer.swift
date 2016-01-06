//
//  Observer.swift
//  Pods
//
//  Created by Sam Williams on 1/5/16.
//
//

import Foundation

public protocol Observer:AnyObject {
    func observableValueChanged<O:Observable>(value:Any?, observable:O?)
}
