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
