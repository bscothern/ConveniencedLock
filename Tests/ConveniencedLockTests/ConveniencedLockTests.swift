// The MIT License (MIT)
//
// Copyright (c) 2018 Braden Scothern.
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
//  ConveniencedLockTests.swift
//  ConveniencedLock
//
//  Created by Braden Scothern on 11/1/18.
//  Copyright © 2018 Braden Scothern. All rights reserved.
//

import XCTest
import Foundation
@testable import ConveniencedLock

final class ConveniencedLockTests: XCTestCase {
    func testNSLock() {
        let lock = NSLock(name: #function)
        multithreadedTest(lock: lock)
        throwingTest(lock: lock)
        returningTest(lock: lock)
    }

    func testNSRecursiveLock() {
        let lock = NSRecursiveLock(name: #function)
        multithreadedTest(lock: lock)
        throwingTest(lock: lock)
        returningTest(lock: lock)
    }

    func testNSRecursiveLockWorksRecursively() {
        let lock = NSRecursiveLock(name: #function)
        lock.execute {
            throwingTest(lock: lock)
        }
    }

    func testNSCondition() {
        let lock = NSCondition(name: #function)
        multithreadedTest(lock: lock)
        throwingTest(lock: lock)
        returningTest(lock: lock)
    }

    func testNSConditionLock() {
        let lock = NSConditionLock(name: #function)
        multithreadedTest(lock: lock)
        throwingTest(lock: lock)
        returningTest(lock: lock)
    }
}

private func multithreadedTest(lock: ConveniencedLock, expectedCount: Int = 1000) {
    var count = 0
    for _ in 0 ..< expectedCount {
        DispatchQueue.global().async {
            lock.execute {
                count += 1
            }
        }
    }
    usleep(2000 * UInt32(expectedCount))
    XCTAssert(count == expectedCount, "\(#function) failed by \(lock.name!). Had a count of: \(count) but expected \(expectedCount)")
}

private func throwingTest(lock: ConveniencedLock) {
    enum TestError: Error {
        case a
        case b
    }

    let throwingFunction = { () throws -> Int in
        throw TestError.a
    }

    do {
        try lock.execute(throwingFunction)
    } catch let error as TestError {
        XCTAssert(error == .a, "\(#function) failed by \(lock.name!). Unexpected error thrown. Received \(error) but expected \(TestError.a)")
    } catch {
        XCTAssert(false, "\(#function) failed by \(lock.name!). Unexpected error thrown.")
    }

    guard let unexpected = try? lock.execute(throwingFunction) else {
        return
    }
    XCTAssert(false, "\(#function) failed by \(lock.name!). Function didn't throw and returned \(unexpected).")
}

private func returningTest(lock: ConveniencedLock, count: Int = 100) {
    var count = 0

    let returningFunction = { () -> Int in
        defer { count += 1 }
        return count
    }

    var results = [Int](repeating: 0, count: count)
    var expectedResult: Int = 0

    for i in 0 ..< count {
        DispatchQueue.global().async {
            results[i] = lock.execute(returningFunction)
        }
        expectedResult += i
    }
    usleep(2000 * UInt32(count))
    let resultSum = results.reduce(0, +)
    XCTAssert(expectedResult == resultSum, "\(#function) failed by \(lock.name!). Results didn't summ to expected value of \(expectedResult) and instead summed to \(resultSum)")
}
