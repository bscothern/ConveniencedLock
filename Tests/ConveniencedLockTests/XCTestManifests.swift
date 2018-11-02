import XCTest

extension ConveniencedLockTests {
    static let __allTests = [
        ("testNSCondition", testNSCondition),
        ("testNSConditionLock", testNSConditionLock),
        ("testNSLock", testNSLock),
        ("testNSRecursiveLock", testNSRecursiveLock),
        ("testNSRecursiveLockWorksRecursively", testNSRecursiveLockWorksRecursively),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ConveniencedLockTests.__allTests),
    ]
}
#endif
