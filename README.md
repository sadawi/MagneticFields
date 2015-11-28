# MagneticFields

[![CI Status](http://img.shields.io/travis/Sam Williams/MagneticFields.svg?style=flat)](https://travis-ci.org/Sam Williams/MagneticFields)
[![Version](https://img.shields.io/cocoapods/v/MagneticFields.svg?style=flat)](http://cocoapods.org/pods/MagneticFields)
[![License](https://img.shields.io/cocoapods/l/MagneticFields.svg?style=flat)](http://cocoapods.org/pods/MagneticFields)
[![Platform](https://img.shields.io/cocoapods/p/MagneticFields.svg?style=flat)](http://cocoapods.org/pods/MagneticFields)

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
let age = Field<Int>()
age.value = 10
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

A field can have any number of registered observer objects, which must conform to the `FieldObserver` protocol.

```swift
field.addObserver(observer)
field.removeObserver(observer)
```

A field can have a single onChange closure.

```swift
age --> { value in 
  print("Age was changed to \(value)")
}
```

The `-->` operator can also be used to create a link between two fields.  `sourceField --> destinationField` will set the value of `destinationField` to that of `sourceField` immediately, and again whenever `sourceField`'s value changes.

The relation can be made bidirectional using the `<-->` operator.  In that case, both fields will initially have the value of the field on the right-hand side, and subsequent changes to either will be propagated to the other.

The `-->` operator can also take a block to transform values:

```swift
purchase.dollars --> purchase.cents { $0 * 100 }
purchase.dollars --> { $0 * 100 } --> purchase.cents
```

## License

MagneticFields is available under the MIT license. See the LICENSE file for more info.
