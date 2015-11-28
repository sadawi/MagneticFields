# MagneticFields

[![CI Status](http://img.shields.io/travis/Sam Williams/MagneticFields.svg?style=flat)](https://travis-ci.org/Sam Williams/MagneticFields)
[![Version](https://img.shields.io/cocoapods/v/MagneticFields.svg?style=flat)](http://cocoapods.org/pods/MagneticFields)
[![License](https://img.shields.io/cocoapods/l/MagneticFields.svg?style=flat)](http://cocoapods.org/pods/MagneticFields)
[![Platform](https://img.shields.io/cocoapods/p/MagneticFields.svg?style=flat)](http://cocoapods.org/pods/MagneticFields)

## Overview

MagneticFields is a library for adding fields to your model objects.  It'll give you:
* type-safe change observation
* automatic timestamps
* validations
* load state

## Installation

MagneticFields is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MagneticFields"
```

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Basic

```swift
class Person {
  let age = Field<Int>()
}
person.age.value = 10
```

### Validations

Simple closure validations:

```swift
let age = Field<Int>().require { $0 > 0 }
```

Rules can be chained, too, implying an AND.  Order is not important.

```swift
let age = Field<Int>().require { $0 > 0 }.require { $0 % 2 == 0 }
```

By default, `nil` values will be considered valid.  To change that for a given rule, pass `allowNil: false` to `require`.

### Timestamps

Fields will automatically have the following timestamps:
* `updatedAt`: the last time any value was set
* `changedAt`: the last time a new value was set (compared using `==`)

### Observers

A field can have any number of registered observer objects.  The `-->` operator is a shortcut for the `addObserver` method.  Observation events are triggered once when the observer is added, and after that whenever a field value is set.

An observer can be added if it implements the `FieldObserver` protocol:

```swift
field --> observer
```

Or, if it implements `Hashable`, a closure can be provided:
```swift
field --> observer { value in
  print(value)
}
```

`Field` itself implements `FieldObserver`, and the `-->` operator can be used to create a link between two fields.

```swift
sourceField --> destinationField
```
This will set the value of `destinationField` to that of `sourceField` immediately, and again whenever `sourceField`'s value changes.

The relation can be made bidirectional using the `<-->` operator:

```swift
sourceField <--> destinationField
```
Here, both fields will initially have the value of `destinationField`, and subsequent changes to either will be propagated to the other.

A field can have a single onChange closure.

```swift
age --> { value in 
  print("Age was changed to \(value)")
}
```

The `-->` operator can be chained through any combination of closures and fields.

```swift
purchase.dollars --> { $0 * 100 } --> purchase.cents --> { print("I spent \($0) cents") }
```

Unregistering observers is done with the `removeObserver` method, or the `-/->` operator.  All observers can be removed with `removeAllObservers()` or by `field --> nil`

## Load State

It can be useful to distinguish between a value that's nil because hasn't been loaded yet (e.g., from an API), and one that is known to be nil.  For this, fields provide the `state` property, whose values are in the `LoadState` enum:

```swift
public enum LoadState {
    case NotLoaded
    case Loading
    case Loaded
    case Error
}
```

All fields are initially in the `.NotLoaded` state, but automatically become `.Loaded` when their value is set to anything.

The `.Loading` state can be useful when the process of loading takes time.  You might decide to show a spinner in the UI while making an API request, for example.

## License

MagneticFields is available under the MIT license. See the LICENSE file for more info.
