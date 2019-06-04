// The MIT License (MIT)
//
// Copyright (c) 2016 Braden Scothern.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//
//  ConveniencedLock.swift
//  ConveniencedLock
//
//  Created by Braden Scothern on 10/16/16.
//  Copyright © 2016 Braden Scothern. All rights reserved.
//

import Foundation

/// A protocol that makes it easier to work with NSLocking types.
public protocol ConveniencedLock: NSLocking {
    /// The name associated with the lock.
    var name: String? { get set }

    /// Creates a default instance of the lock.
    ///
    /// This is required to support `init(name:)`
    init()
}

public extension ConveniencedLock {
    /// Creates an instance of the lock while setting its name.
    ///
    /// - Parameter name: The name to associate with the lock.
    init(name: String) {
        self.init()
        self.name = name
    }

    /// A function that executes a critical section of code while the lock is locked and ensures that it is unlocked after execution.
    ///
    /// - Parameter criticalBlock: The criticial portion of code that should be executed while the lock is locked.
    /// - Returns: The return value of the `criticalBlock` that is protected by the lock.
    /// - Throws: Any value thrown by the `criticalBlock`.
    @discardableResult
    func execute<T>(_ criticalBlock: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try criticalBlock()
    }
}
