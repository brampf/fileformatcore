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
    
    struct Field : ReadableAutoFrame {
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
    
    struct Tuple : ReadableAutoFrame {
        
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
        
        struct TestElement : ReadableAutoFrame {
            
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
    
    
    
    func testElementProperty() {
        
        struct TestFile : BaseFile {
            typealias Configuration = TestConfig
            
            @Persistent(equals: 8) var array : [UInt8] = []
            
            @Persistent var text: String? = nil
        }
        
        let bytes : [UInt8] = [
                0,1,2,3,4,5,6,7,8,9,50,52
        ]
        
        let new = try! TestFile.read(data: Data(bytes))!
        
        XCTAssertEqual(new.array.count, 9)
        XCTAssertEqual(new.array, [0,1,2,3,4,5,6,7,8])
        XCTAssertEqual(new.text, "\t24")
        
    }
    
    func testChildProperty() {
        
        struct TestFile : BaseFile {
            typealias Configuration = TestConfig
            
            @Persistent(\TestField.number, equals: 8) var array : [TestField] = []
            
            @Persistent var text: String? = nil
        }
        
        struct TestField : ReadableAutoFrame {
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [
            0,1,2,3,4,5,6,7,8,9,50,52
        ]
        
        let new = try! TestFile.read(data: Data(bytes))!
        
        XCTAssertEqual(new.array.count, 9)
        XCTAssertEqual(new.array[8].number, 8)
        XCTAssertEqual(new.text, "\t24")
        
    }

    func testConditionalProperty() {
        
        struct TestFile : BaseFile {
            typealias Configuration = TestConfig
            
            @Persistent(\TestField.number, equals: 8) var array : [TestField] = []
            
            @Persistent var text: String? = nil
        }
        
        struct TestField : ReadableAutoFrame {
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [
            0,1,2,3,4,5,6,7,8,9,50,52
        ]
        
        let new = try! TestFile.read(data: Data(bytes))!
        
        XCTAssertEqual(new.array.count, 9)
        XCTAssertEqual(new.array[8].number, 8)
        XCTAssertEqual(new.text, "\t24")
        
    }
    
    func testStringProperty() {
        
        struct TestFile : BaseFile {
            typealias Configuration = TestConfig
            
            @Persistent(.cstring) var first = "Test"
            
            @Persistent var second: String? = nil
        }
        
        let bytes : [UInt8] = [
            52,50,0,0x74,0x65,0x73,0x74
        ]
        
        let new = try! TestFile.read(data: Data(bytes))!
        
        XCTAssertEqual(new.first, "42")
        XCTAssertEqual(new.second, "test")
        
    }
    
    
    
    func testCustomFrame() throws {
        
        struct TestFrame : ReadableFrame {
            
            var number : UInt32 = 0
            var array : [UInt8] = []
            
            init() {
                // default initializer
            }
            
            
            mutating func read(_ data: UnsafeRawBufferPointer, context: inout Context) throws {
                
                number = try data.read(&context.offset, byteSwapped: context.bigEndian)
                
                array = try data.read(&context.offset, upperBound: context.head?.endOffset ?? data.endIndex, byteSwapped: context.bigEndian)
            }
            
            var byteSize: Int {
                return 4 + array.byteSize
            }
            
            
            static func size(_ data: UnsafeRawBufferPointer, with context: inout Context) -> Int? {
                nil
            }
            
        }
        
        let bytes : [UInt8] = [0,0,0,32,1,2,3,4,5,6,7,8,9]
        
        var context : Context = ReaderContext(using: TestConfig(), out: nil
        )
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.new(ptr, with: &context, nil)
        }
        
        XCTAssertEqual(frame?.number, 32)
        XCTAssertEqual(frame?.array, [1,2,3,4,5,6,7,8,9])
        
        print(frame?.array.map{$0.description})
    }
    
}



