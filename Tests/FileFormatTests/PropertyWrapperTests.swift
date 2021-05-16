import XCTest
import FileReader

final class PropertyWrapperTests: XCTestCase {
    
        static var allTests = [
        ("testUInt8", testUInt8),
        ("testSingleFrame", testSingleFrame),
        ("testRepeatingFrame", testRepeatingFrame),
        ("testCountedChildFrame", testCountedChildFrame),
        ("testStringFrame", testStringFrame),
        ("testOptionalStringFrame", testOptionalStringFrame),
        ("testCountingLookup", testCountingLookup),
        ("testTransient", testTransient)
    ]
    
    func testUInt8() throws {
        
        struct TestFrame: AutoReadable {
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [42]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.read(ptr, with: &context)
        }
       
        XCTAssertNotNil(frame)
        XCTAssertEqual(frame?.number, 42)
        
    }
    
    func testSingleFrame() throws {
        
        struct TestFrame: AutoReadable {
            
            @Persistent var child : ChildFrame? = nil
            
        }
        
        struct ChildFrame: AutoReadable {
            
            @Persistent var number : UInt8 = 0
        }
        
        let bytes : [UInt8] = [42]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.read(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertNotNil(frame?.child)
        XCTAssertEqual(frame?.child?.number, 42)
        
    }
    
    func testRepeatingFrame() throws {
        
        struct TestFrame: AutoReadable {
            
            @Persistent var child : [ChildFrame] = []
            
        }
        
        struct ChildFrame: AutoReadable {
            
            @Persistent var number : UInt8 = 0
        }
        
        let bytes : [UInt8] = [42,23]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.read(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertNotNil(frame?.child)
        XCTAssertEqual(frame?.child.count, 2)
        XCTAssertEqual(frame?.child.first?.number, 42)
        XCTAssertEqual(frame?.child.last?.number, 23)
        
    }
    
    func testCountedChildFrame() throws {
        
        struct TestFrame: AutoReadable {
            
            @Transient(\TestFrame.count) var count : UInt8 = 0
            
            @Persistent(\TestFrame.count) var child : [ChildFrame] = []
            
        }
        
        struct ChildFrame: AutoReadable {
            
            @Persistent var number : UInt8 = 0
        }
        
        let bytes : [UInt8] = [2,42,23,0,0,0,0,0,0]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.read(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertNotNil(frame?.child)
        XCTAssertEqual(frame?.child.count, 2)
        XCTAssertEqual(frame?.child.first?.number, 42)
        XCTAssertEqual(frame?.child.last?.number, 23)
        
    }
    
    func testStringFrame() throws {
        
        struct TestFrame: AutoReadable {
        
            @Persistent var text : String = ""
            
        }
        
        let bytes : [UInt8] = [0,116,101,115,116]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.read(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertNotNil(frame?.text, "test")
        
    }
    
    func testOptionalStringFrame() throws {
        
        struct TestFrame: AutoReadable {
            
            @Persistent var text : String? = nil
            
        }
        
        let bytes : [UInt8] = [116,101,115,116]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.read(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertNotNil(frame?.text, "test")
        
    }
    
    func testCountingLookup() throws {
        
        
        struct TestFrame : AutoReadable {
            
            @Persistent var suparraycount : UInt8 = 0
            
            @Transient(\TestFrame.arrayCount) var arrayCount : UInt8 = 0
            
            @Persistent var child : TestChild? = nil
            
            @Persistent(\TestFrame.arrayCount) var array : [UInt8] = []
        }
        
        struct TestChild : AutoReadable {
            
            @Transient(\TestChild.count) var count : UInt8 = 0
            
            @Persistent(\TestChild.count) var subarray : [UInt8] = []
            
            @Persistent(\TestFrame.suparraycount) var suparray : [UInt8] = []
            
            //@Persistent var text : String? = nil
        }
        
     
        let bytes : [UInt8] = [
            2,              // TestFrame.suparraycount
            4,              // TestFrame.arrayCount
            
            3,               // TestChild.count
            0,1,2,           // TestChild.subarray
            23,42,            // TestChild.suparray
            116,101,115,116,  // TestChild.text
            
            116,101,115,116,  // TestFrame.array
            //0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            
         ]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.read(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertEqual(frame?.suparraycount, 2)
        XCTAssertEqual(frame?.arrayCount, 4)
        
        XCTAssertNotNil(frame?.child)
        XCTAssertEqual(frame?.child?.count, 3)
        XCTAssertEqual(frame?.child?.subarray, [0,1,2])
        
        XCTAssertEqual(frame?.child?.suparray, [23,42])
        //XCTAssertEqual(frame?.child?.text, "test")
        
        
        XCTAssertEqual(frame?.array.count, 4)
        XCTAssertEqual(frame?.array, [116,101,115,116])
    }
    
    func testTransient() throws {
        
        struct TestFrame : AutoReadable {
            
            @Transient(\TestFrame.array.count8) var counter : UInt8 = 0
            
            @Persistent var array : [UInt8] = []
        }
        
        let bytes : [UInt8] = [10,0,1,2,3,4,5,6,7,8,9]

        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.read(ptr, with: &context)
        }
        
        XCTAssertEqual(frame?.array, [0,1,2,3,4,5,6,7,8,9])
        XCTAssertEqual(frame?.array.count, 10)
        
        /// - ToDO: Fix this
        // XCTAssertEqual(frame?.counter, 10)
    }
    
    func testOptionalProperty() throws {
        
        
        struct TestFrame : AutoReadable {
            
            @Transient(\TestFrame.condition) var condition : UInt8
            
            @Transient(\TestFrame.condition, equals: 1) var test : UInt64? = nil
        
        }
        
        let test = TestFrame()
        test.test = 42
        
        XCTAssertEqual(test.test, 42)
        
        let truebytes : [UInt8] = [1,0,0,0,0,0,0,0,23]
        
        var context = DefaultContext()
        let trueframe = try truebytes.withUnsafeBytes{ ptr in
            try TestFrame.read(ptr, with: &context)
        }
        
        XCTAssertEqual(trueframe?.condition, 1)
        XCTAssertEqual(trueframe?.test, 23)
        
        let falsebytes : [UInt8] = [0,0,0,0,0,0,0,0,23]
        
        context = DefaultContext()
        let falseframe = try falsebytes.withUnsafeBytes{ ptr in
            try TestFrame.read(ptr, with: &context)
        }
        
        XCTAssertEqual(falseframe?.condition, 0)
        XCTAssertEqual(falseframe?.test, nil)
        
    }
    
}
