import XCTest
import FileReader

final class NewReaderTests: XCTestCase {

 
    struct TestConfig : FileConfiguration {
        
        var bigEndian: Bool = true
        
        var ignoreRecoverableErrors: Bool = true
        
        
    }
    
    struct TestFile : BaseFile {
        
        typealias Configuration = TestConfig
        
        @Persistent var version : UInt32 = 0
        
        @Persistent var field : Field? = nil
        
        init() {
            
        }
    }
    
    struct Field : ReadableAutoalignFrame {
        static func size(_ data: UnsafeRawBufferPointer, with context: inout Context) -> Int? {
            nil
        }
        
        
        @Persistent var number : UInt16 = 32
        
        @Transient(\Field.tuples.count8) var count : UInt8 = 0
        
        @Persistent(\Field._count) var tuples : [Tuple] = []
        
        @Persistent var text : String = ""
        
        var test : UInt32 = 0
        
        init() {
            // new
        }
        
    }
    
    struct Tuple : ReadableAutoalignFrame {
        
        init() {
        }
        
        @Persistent var index: UInt8 = 0
        @Persistent var payload: UInt32 = 0
    }
    
    
    func testReading() {
        
        let bytes : [UInt8] = [
            
            0,0,0,42,   // TestFile.version
            0,23,       // TestFile.field.number
            2,          // TestFile.field.count
            1,          // TestFile.field.tuples[0].index
            0,0,0,52,   // TestFile.field.tuples[0].payload
            2,          // TestFile.field.tuples[1].index
            0,0,0,52,    // TestFile.field.tuples[1].payload
            50,52,50,52
            
        ]
        
        let new = try! TestFile.read(data: Data(bytes))!
        
        XCTAssertEqual(new.version, 42)
        XCTAssertEqual(new.field?.number, 23)
        XCTAssertEqual(new.field?.count, 0)
        XCTAssertEqual(new.field?.tuples.count, 2)
        XCTAssertEqual(new.field?.tuples[0].index, 1)
        XCTAssertEqual(new.field?.tuples[0].payload, 52)
        XCTAssertEqual(new.field?.tuples[1].index, 2)
        XCTAssertEqual(new.field?.tuples[1].payload, 52)
        XCTAssertEqual(new.field?.test, 0)
        XCTAssertEqual(new.field?.text, "2424")
        
        print(new.debugDescription)
        
        print(new.debugLayout)
        
    }
    
    func testStored() {
        
        struct TestFile : BaseFile {
            typealias Configuration = TestConfig
            
            @Persistent var number : UInt16 = 0
            
            @Persistent var element : TestElement? = nil
            
            @Transient(\TestFile.array.count32) var count : UInt32 = 0
            
            @Persistent(\TestFile._count) var array : [UInt8] = []
            
            @Persistent var list : [TestElement] = []
    
        }
        
        struct TestElement : ReadableAutoalignFrame {
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [
            0,42,     //number
            
            23,       // element
            
            0,0,0,3,  // count
            1,2,3,    // array
            
            4,5,6,7,8,9 // list
            ]
        
        let new = try! TestFile.read(data: Data(bytes))!
        
        XCTAssertEqual(new.number, 42)
        XCTAssertEqual(new.count, 0)
        XCTAssertEqual(new.array.count, 3)
        XCTAssertEqual(new.list.count, 6)
        
        print(new.debugLayout)
        
    }
}




