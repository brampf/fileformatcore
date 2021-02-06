import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BaseFileTests.allTests),
        testCase(PersistentFrameReaderTests.allTests),
        testCase(PropertyWrapperTests.allTests),
        testCase(ReaderTests.allTests)
    ]
}
#endif
