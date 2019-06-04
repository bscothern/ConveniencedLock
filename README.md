# ConveniencedLock

A framework to help with ensure proper usage of `NSLocking` types.

### Swift Package Manager

Update your `Package.swift` to include this to your package dependencies:
```
.package(url: "https://github.com/bscothern/ConveniencedLock.git", from: "1.0.2")
```

### Carthage

Include this line in your `Cartfile`:
```
github "bscothern/ConveniencedLock"
```

## Extensions
Supported Types:
```
NSLock
NSRecursiveLock
NSCondition
NSConditionLock
```

### New Init

Creates an instance of a lock while setting its name.

`init(name: String)`

### New Function

A function that executes a critical section of code while a lock is locked and ensures that it is unlocked after execution.

`@discardableResult func execute<T>(_ criticalBlock: () throws -> T) rethrows -> T`

### Example Usage
```
import ConveniencedLock
import Foundation

let lock = NSLock(name: "ExampleLock")
var count: Int = 0

DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    lock.execute {
        count += 1
    }
}

// Time to ensure that the dispatch queue blocks have all executed

print(count) // 1000
```
