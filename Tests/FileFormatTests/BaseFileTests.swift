import XCTest
import FileFormat

final class BaseFileTests: XCTestCase {

    static var allTests = [
        ("testSimpleFile", testSimpleFile),
        ("testComplexFile", testComplexFile),
        ("testFileWithPrimtiiveProperties",testFileWithPrimtiiveProperties),
        ("testFileWithConditionalProperties", testFileWithConditionalProperties),
        ("testFileWithCountingProperties", testFileWithCountingProperties),
        ("testFileWithStringProperties", testFileWithStringProperties),
        ("testCustomElement", testCustomElement),
    ]
 
    struct TestConfig : FileConfiguration {
        
        var bigEndian: Bool = true
        
        var ignoreRecoverableErrors: Bool = true
        
        
    }
    
    
    // Regression : Read an abritraty file structure
    func testSimpleFile() {
        
        struct TestFile : BaseFile {
            
            typealias Context = FileReader
            
            @Persistent var version : UInt32 = 0
            
            @Persistent var field : Field? = nil
            
            init() {
                
            }
        }
        
        struct Field : AutoReadable {
            
            static func size<C: Context>(_ data: UnsafeRawBufferPointer, with context: inout C) -> Int? {
                nil
            }
            
            
            @Persistent var number : UInt16 = 32
            
            @Transient(\Field.count) var count : UInt8 = 0
            
            @Persistent(\Field.count) var tuples : [Tuple] = []
            
            @Persistent var text : String = ""
            
            var test : UInt32 = 0
            
            init() {
                // new
            }
            
        }
        
        struct Tuple : AutoReadable {
            
            init() {
            }
            
            @Persistent var index: UInt8 = 0
            @Persistent var payload: UInt32 = 0
        }
        
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
        
        let new = try! TestFile.read(from: Data(bytes))!
        
        XCTAssertEqual(new.version, 42)
        XCTAssertEqual(new.field?.number, 23)
        XCTAssertEqual(new.field?.count, 2)
        XCTAssertEqual(new.field?.tuples.count, 2)
        XCTAssertEqual(new.field?.tuples[0].index, 1)
        XCTAssertEqual(new.field?.tuples[0].payload, 52)
        XCTAssertEqual(new.field?.tuples[1].index, 2)
        XCTAssertEqual(new.field?.tuples[1].payload, 52)
        XCTAssertEqual(new.field?.test, 0)
        XCTAssertEqual(new.field?.text, "2424")
        
        //print(new.debugDescription)
        
        print(new.debugLayout)
        
    }
    
    // Regression : Read an abritraty file structure
    func testComplexFile() {
        
        struct TestFile : BaseFile {
            typealias Context = FileReader
            
            @Persistent var number : UInt16 = 0
            
            @Persistent var element : TestElement? = nil
            
            @Transient(\TestFile.count) var count : UInt32 = 0
            
            @Persistent(\TestFile.count) var array : [UInt8] = []
            
            @Persistent var list : [TestElement] = []
    
        }
        
        struct TestElement : AutoReadable {
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [
            0,42,     //number
            
            23,       // element
            
            0,0,0,3,  // count
            1,2,3,    // array
            
            4,5,6,7,8,9 // list
            ]
        
        let new = try! TestFile.read(from: Data(bytes))!
        
        XCTAssertEqual(new.number, 42)
        XCTAssertEqual(new.count, 3)
        XCTAssertEqual(new.array.count, 3)
        XCTAssertEqual(new.list.count, 6)
        
        print(new.debugLayout)
        
    }
    
    
    
    func testFileWithPrimtiiveProperties() {
        
        struct TestFile : BaseFile {
            typealias Context = FileReader
            
            @Persistent(equals: 8) var array : [UInt8] = []
            
            @Persistent var text: String? = nil
        }
        
        let bytes : [UInt8] = [
                0,1,2,3,4,5,6,7,8,9,101,115,116
        ]
        
        let new = try! TestFile.read(from: Data(bytes))!
        
        XCTAssertEqual(new.array.count, 9)
        XCTAssertEqual(new.array, [0,1,2,3,4,5,6,7,8])
        XCTAssertEqual(new.text, "\test")
        
    }
    
    func testFileWithConditionalProperties() {
        
        struct TestFile : BaseFile {
            typealias Context = FileReader
            
            @Persistent(\TestField.number, equals: 8) var array : [TestField] = []
            
            @Persistent var text: String? = nil
        }
        
        struct TestField : AutoReadable {
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [
            0,1,2,3,4,5,6,7,8,9,101,115,116
        ]
        
        let new = try! TestFile.read(from: Data(bytes))!
        
        XCTAssertEqual(new.array.count, 9)
        XCTAssertEqual(new.array[8].number, 8)
        XCTAssertEqual(new.text, "\test")
        
    }

    func testFileWithCountingProperties() {
        
        struct TestFile : BaseFile {
            typealias Context = FileReader
            
            @Persistent(\TestField.number, equals: 8) var array : [TestField] = []
            
            @Persistent var aftermath: [UInt8] = []
        }
        
        struct TestField : AutoReadable {
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [
            0,1,2,3,4,5,6,7,8,9,50,52
        ]
        
        let new = try! TestFile.read(from: Data(bytes))!
        
        XCTAssertEqual(new.array.count, 9)
        XCTAssertEqual(new.array[8].number, 8)
        XCTAssertEqual(new.aftermath, [9,50,52])
        
    }
    
    func testFileWithStringProperties() {
        
        struct TestFile : BaseFile {
            typealias Context = FileReader
            
            @Persistent(.cstring) var first = "Test"
            
            @Persistent var second: String? = nil
        }
        
        let bytes : [UInt8] = [
            52,50,0,0x74,0x65,0x73,0x74
        ]
        
        let new = try! TestFile.read(from: Data(bytes))!
        
        XCTAssertEqual(new.first, "42")
        XCTAssertEqual(new.second, "test")
        
    }
    
    
    
    
    func testCustomElement() throws {
        
        struct TestElement : AnyReadable {
            
            public static func new<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?) throws -> Self? {
                return TestElement()
            }
            
            public static func upperBound<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C) throws -> Int? {
                return nil
            }
            
            mutating func read(_ bytes: UnsafeRawBufferPointer, with reader: FileReader, _ symbol: String?) throws {
            
                self.number = try bytes.read(&reader.offset, byteSwapped: reader.bigEndian)
                
                self.array = try bytes.read(&reader.offset, upperBound: reader.head?.endOffset ?? bytes.endIndex, byteSwapped: reader.bigEndian)
            }
            
            var number : UInt32 = 0
            var array : [UInt8] = []
            
            init() {
                // default initializer
            }
            
            
            var byteSize: Int {
                return 4 + array.byteSize
            }
            
            
            static func size<C: Context>(_ data: UnsafeRawBufferPointer, with context: inout C) -> Int? {
                nil
            }
            
        }
        
        let bytes : [UInt8] = [0,0,0,32,1,2,3,4,5,6,7,8,9]
        
        let reader = FileReader(using: TestConfig(), out: nil)
        let frame : TestElement? = try bytes.withUnsafeBytes{ ptr in
            try reader.parse(ptr)
        }
        
        XCTAssertEqual(frame?.number, 32)
        XCTAssertEqual(frame?.array, [1,2,3,4,5,6,7,8,9])
    }
    
}



