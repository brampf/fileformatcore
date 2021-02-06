import XCTest
import FileReader

final class PropertyWrapperTests: XCTestCase {
    
    
    
    func testUInt8() throws {
        
        struct TestFrame: ReadableFrame {
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [42]
        
        var context = ReaderContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.readElement(ptr, with: &context)
        }
       
        XCTAssertNotNil(frame)
        XCTAssertEqual(frame?.number, 42)
        
    }
    
    func testSingleFrame() throws {
        
        struct TestFrame: ReadableFrame {
            
            @Persistent var child : ChildFrame? = nil
            
        }
        
        struct ChildFrame: ReadableFrame {
            
            @Persistent var number : UInt8 = 0
        }
        
        let bytes : [UInt8] = [42]
        
        var context = ReaderContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.readElement(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertNotNil(frame?.child)
        XCTAssertEqual(frame?.child?.number, 42)
        
    }
    
    func testRepeatingFrame() throws {
        
        struct TestFrame: ReadableFrame {
            
            @Persistent var child : [ChildFrame] = []
            
        }
        
        struct ChildFrame: ReadableFrame {
            
            @Persistent var number : UInt8 = 0
        }
        
        let bytes : [UInt8] = [42,23]
        
        var context = ReaderContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.readElement(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertNotNil(frame?.child)
        XCTAssertEqual(frame?.child.count, 2)
        XCTAssertEqual(frame?.child.first?.number, 42)
        XCTAssertEqual(frame?.child.last?.number, 23)
        
    }
    
    func testCountedChildFrame() throws {
        
        struct TestFrame: ReadableFrame {
            
            @Transient(\TestFrame.count) var count : UInt8 = 0
            
            @Persistent(\TestFrame.count) var child : [ChildFrame] = []
            
        }
        
        struct ChildFrame: ReadableFrame {
            
            @Persistent var number : UInt8 = 0
        }
        
        let bytes : [UInt8] = [2,42,23,0,0,0,0,0,0]
        
        var context = ReaderContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.readElement(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertNotNil(frame?.child)
        XCTAssertEqual(frame?.child.count, 2)
        XCTAssertEqual(frame?.child.first?.number, 42)
        XCTAssertEqual(frame?.child.last?.number, 23)
        
    }
    
    func testStringFrame() throws {
        
        struct TestFrame: ReadableFrame {
        
            @Persistent var text : String = ""
            
        }
        
        let bytes : [UInt8] = [0,116,101,115,116]
        
        var context = ReaderContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.readElement(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertNotNil(frame?.text, "test")
        
    }
    
    func testOptionalStringFrame() throws {
        
        struct TestFrame: ReadableFrame {
            
            @Persistent var text : String? = nil
            
        }
        
        let bytes : [UInt8] = [116,101,115,116]
        
        var context = ReaderContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.readElement(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertNotNil(frame?.text, "test")
        
    }
    
    func testCountingLookup() throws {
        
        
        struct TestFrame : ReadableFrame {
            
            @Persistent var suparraycount : UInt8 = 0
            
            @Transient(\TestFrame.arrayCount) var arrayCount : UInt8 = 0
            
            @Persistent var child : TestChild? = nil
            
            @Persistent(\TestFrame.arrayCount) var array : [UInt8] = []
        }
        
        struct TestChild : ReadableFrame {
            
            @Transient(\TestChild.count) var count : UInt8 = 0
            
            @Persistent(\TestChild.count) var subarray : [UInt8] = []
            
            @Persistent(\TestFrame.suparraycount) var suparray : [UInt8] = []
            
            //@Persistent var text : String? = nil
        }
        
     
        let bytes : [UInt8] = [
            2,              // TestFrame.suparraycount
            4,              // TestFrame.arrayCount
            
            4,               // TestChild.count
            0,1,2,3,         // TestChild.subarray
            23,42,            // TestChild.suparray
            116,101,115,116,  // TestChild.text
            
            116,101,115,116,  // TestFrame.array
            //0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            
         ]
        
        var context = ReaderContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.readElement(ptr, with: &context)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertEqual(frame?.suparraycount, 2)
        XCTAssertEqual(frame?.arrayCount, 0)
        
        XCTAssertNotNil(frame?.child)
        XCTAssertEqual(frame?.child?.count, 0)
        XCTAssertEqual(frame?.child?.subarray, [0,1,2,3])
        
        XCTAssertEqual(frame?.child?.suparray, [23,42])
        //XCTAssertEqual(frame?.child?.text, "test")
        
        
        XCTAssertEqual(frame?.array.count, 4)
        XCTAssertEqual(frame?.array, [116,101,115,116])
    }
    
    func testTransient() throws {
        
        struct TestFrame : ReadableFrame {
            
            @Transient<TestFrame,UInt8>(\TestFrame.array.count8) var counter : UInt8
            
            @Persistent var array : [UInt8] = []
        }
        
        let bytes : [UInt8] = [10,0,1,2,3,4,5,6,7,8,9]

        var context = ReaderContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.readElement(ptr, with: &context)
        }
        
        XCTAssertEqual(frame?.array, [0,1,2,3,4,5,6,7,8,9])
        XCTAssertEqual(frame?.array.count, 10)
        XCTAssertEqual(frame?.counter, 10)
    }
    
}
