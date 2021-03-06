[![Version](https://img.shields.io/cocoapods/v/MagneticFields.svg?style=flat)](http://cocoapods.org/pods/MagneticFields)
[![License](https://img.shields.io/cocoapods/l/MagneticFields.svg?style=flat)](http://cocoapods.org/pods/MagneticFields)
[![Platform](https://img.shields.io/cocoapods/p/MagneticFields.svg?style=flat)](http://cocoapods.org/pods/MagneticFields)

# MagneticFields

## Overview

MagneticFields is a library for adding fields to your model objects.  It'll give you:
* type-safe change observation
* automatic timestamps
* validations
* load state

## Installation

MagneticFields is available through [CocoaPods](http://cocoapods.org). To install it, add the following line to your Podfile:

```ruby
pod "MagneticFields"
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Basic Usage

```swift
class Person {
  let age = Field<Int>()
}
person.age.value = 10
```

## Field classes

The basic field class is `Field`, parameterized by its value type.

```swift
let tag = Field<String>(name: "Tag")
let age = Field<Int>(name: "Age")
```

For multivalued fields, there is `ArrayField`, which wraps a field object describing the single-valued type.

```swift
let tags = ArrayField(Field<String>(), name: "Tags")
```

The inner field is responsible for validations, transformations, etc..  The `ArrayField` owns top-level attributes like `name`, `key`, etc. -- but for convenience, it will copy them from the inner field at initialization.

The unary prefix operator `*` is provided to wrap a `Field` in an `ArrayField`.  So you can also write the above declaration like this:

```swift
let tags = *Field<String>(name: "Tags")
```


## Validations

Simple closure validations:

```swift
let age = Field<Int>().require { $0 > 0 }
```

Rules can be chained, too, implying an AND.  Order is not important.

```swift
let age = Field<Int>().require { $0 > 0 }.require { $0 % 2 == 0 }
```

By default, `nil` values will be considered valid.  To change that for a given rule, pass `allowNil: false` to `require`.

To validate a field value, either call `field.valid` (returning a `Bool`) or `field.validate()`, which returns a `ValidationState` enum:

```swift
public enum ValidationState:Equatable {
    case Unknown
    case Invalid([String])
    case Valid
}
```

The associated value of the `.Invalid` case is a list of error messages (e.g., `["must be greater than 0", "is required"]`).


## Timestamps

Fields will automatically have the following timestamps:
* `updatedAt`: the last time any value was set
* `changedAt`: the last time a new value was set (compared using `==`)

## Observers

This library includes the `Observer` and `Observable` protocols for generic, type-safe change observation.  Fields implement both protocols.

An `Observable` can have any number of registered `Observer` objects.  The `-->` operator is a shortcut for the `addObserver` method (`<--` works the same, only with its arguments swapped). Observation events are triggered once when the observer is added, and after that whenever a field value is set.

### Adding an observer

An observer can be added if it implements the `Observer` protocol, which has a `valueChanged(observable, value: value)` method.

```swift
field --> observer
```

Or, a closure can be provided.  In place of an observer object, an `owner` is used only to identify each closure; each owner can only have one associated closure.

```swift
field --> owner { value in
  print(value)
}
```

We can still register a closure even if no observer is given.  This is effectively registering the closure with a null observer.  There can only be one of these at a time.

```swift
age --> { value in 
  print("Age was changed to \(value)")
}
```

### Binding a field to another field

Since `Field` itself implements both `Observable` and `Observer`, the `-->` operator can be used to create a link between two field values.

```swift
sourceField --> destinationField
```
This will set the value of `destinationField` to that of `sourceField` immediately, and again whenever `sourceField`'s value changes.

The `<-->` operator is a shortcut for `<--` followed by `-->` (and can only be used between two Fields).

```swift
field1 <--> field2
```

Since `<--` is called first, both fields will initially have the value of `field2`.

### Type safety

Fields and Observables have a strongly typed `value` property, which must match an Observer's associated type (`ValueType`) or the closure's parameter.

So this will fail to compile:

```swift
let name = Field<String>()
let age = Field<Int>()
name --> age
```

### Unregistering

Unregistering observers is done with the `removeObserver` method, or the `-/->` operator.  All observers can be removed with `removeAllObservers()`.

## Load State

It can be useful to distinguish between a value that's nil because hasn't been loaded yet (e.g., from an API), and one that is known to be nil.  For this, fields provide the `loadState` property, whose values are in the `LoadState` enum:

```swift
public enum LoadState {
    case NotLoaded
    case Loaded
    case Loading
    case Error
}
```

All fields are initially in the `.NotLoaded` state, but automatically become `.Loaded` when their value is set to anything.

The `.Loading` state can be useful when the process of loading takes time.  You might decide to show a spinner in the UI while making an API request, for example.
