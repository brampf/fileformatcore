import XCTest
@testable import FileReader

/// Test of the various `
final class PersistentFrameReaderTests: XCTestCase {

    static var allTests = [
        ("testSequentialFrame", testSequentialFrame),
        ("testComparisonBoundedFrame", testComparisonBoundedFrame),
        ("testFixedCharBoundedFrame", testFixedCharBoundedFrame)
    ]
    
    struct TestConfig : FileConfiguration {
        
        var bigEndian: Bool = true
        
        var ignoreRecoverableErrors: Bool = true
    }
    
 
    func testSequentialFrame() throws {
        
        
        let bytes = "Hallo World,42,\"Hello, World!\",test,\"Hully\r\nGully\",test,23\r\ntest,\"next\",23,44"
        
        let frame = SequentialFrame<String>(bound: [0x0D, 0x0A], divider: 0x2C, escape: 0x22)
        
        var context = DefaultContext(using: TestConfig()) { msg in
            print(msg)
        }
        
        let new = try bytes.data(using: .utf8)?.withUnsafeBytes{ ptr in
            try frame.read("Seq", from: ptr, in: &context)
        }
        
        new?.forEach{ e in
            print(e)
        }
        
    }
    
    func testComparisonBoundedFrame() throws {
        
        struct Parent : BaseFile {
            
            typealias Configuration = TestConfig
            typealias Context = DefaultContext<Configuration>
            
            @Persistent(\Child.data, equals: 1701733408) var children : [Child] = []
            
            @Persistent var counter : UInt8 = 0
            @Persistent var text = ""
            
        }
        
        struct Child : AutoReadable {
            
            @Persistent var index : UInt8 = 0
            
            @Persistent var data : UInt32 = 0
        }
        
        let bytes : [UInt8] = [
            0, 115,116,97,114,  // star
            1, 109,101,116,97,  // meta
            2, 105,110,102,111, // info
            3, 101,110,100,32,  // end
            4, 116,101,115,116, // test
            //6, 32,32,32,32,32
        ]
        
        let file = try Parent.read(from: bytes)!
        
        XCTAssertEqual(file.children.count, 4)
        XCTAssertEqual(file.children[0].index, 0)
        XCTAssertEqual(file.children[0].data, 1937006962)
        XCTAssertEqual(file.children[1].index, 1)
        XCTAssertEqual(file.children[1].data, 1835365473)
        XCTAssertEqual(file.children[2].index, 2)
        XCTAssertEqual(file.children[2].data, 1768842863)
        XCTAssertEqual(file.children[3].index, 3)
        XCTAssertEqual(file.children[3].data, 1701733408)
        XCTAssertEqual(file.counter, 4)
        XCTAssertEqual(file.text, "test")
        
    }
    
    func testFixedCharBoundedFrame() throws {
        
        struct Frame : BaseFile {
            typealias Context = DefaultContext<TestConfig>
            
            @Persistent(UInt32.self) var label = ""
            
            @Persistent var array : [UInt8] = []

        }
        
        let bytes : [UInt8] = [
            116,101,115,116,
            1,2,3,4,5,6,7,8,9
        ]
        
        let frame = try Frame.read(from: bytes)!
        
        XCTAssertEqual(frame.label, "test")
        XCTAssertEqual(frame.array, [1,2,3,4,5,6,7,8,9])
        
    }

}
