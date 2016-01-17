# MirrorObject
Mirroring dynamic properties automatically.

[![CI Status](http://img.shields.io/travis/Matzo/MirrorObject.svg?style=flat)](https://travis-ci.org/Matzo/MirrorObject)
[![Version](https://img.shields.io/cocoapods/v/MirrorObject.svg?style=flat)](http://cocoapods.org/pods/MirrorObject)
[![License](https://img.shields.io/cocoapods/l/MirrorObject.svg?style=flat)](http://cocoapods.org/pods/MirrorObject)
[![Platform](https://img.shields.io/cocoapods/p/MirrorObject.svg?style=flat)](http://cocoapods.org/pods/MirrorObject)

## Usage
Update an dynamic property, then it will be reflected to other object which has same identifier.

```swift
let a = User("u1", followers: 0)
let b = User("u1", followers: 0)

print(a.followers) // -> 0
print(b.followers) // -> 0

a.followers += 1

print(a.followers) // -> 1
print(b.followers) // -> 1
```

User class is defined as following.

```swift
import MirrorObject

class User: NSObject, MirrorObject {
    var id: String
    dynamic var followers: Int

    init(id: String, followers: Int) {
        self.id        = id
        self.followers = followers

        super.init()
        self.startMirroring()
    }

    deinit {
        self.stopMirroring()
    }

    func identifier() -> String {
        return id
    }
}
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8 or later

## Installation

MirrorObject is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MirrorObject"
```

## Author

Matzo, ksk.matsuo@gmail.com

## License

MirrorObject is available under the MIT license. See the LICENSE file for more info.
