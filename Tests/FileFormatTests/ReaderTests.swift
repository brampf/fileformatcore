import XCTest
import FileReader

final class ReaderTests: XCTestCase {


    static var allTests = [
        ("testExample", testExample),
    ]
    
    class Outer : Readable {
        
        @ReadableInteger var index : UInt16
        
        @ReadableCString var chars : String?
        
        @ReadableChildren var inner : [Inner]
        
        public var debugSymbol: String {
            "_OUTER"
        }
        
    }
    
    class Inner : Readable {

        @ReadableInteger var number : UInt8
        
        public var debugSymbol: String {
            "_INNER"
        }
        
    }
    
    class TestConfig : FileConfiguration {
        
        func next(_ data: UnsafeRawBufferPointer, context: Context) throws -> (new: AnyReadable?, upperBound: Int?) {
            if context.head?.readable is Outer {
                return (Inner(), nil)
            } else {
                return (Outer(), nil)
            }
        }
        
        var bigEndian: Bool = true
        
        var ignoreRecoverableErrors: Bool = true
        
        
    }
    
    
    func testParser() {
        
        let bytes : [UInt8] = [
            0,23, // index
            52,
            50,
            0,
            1,
            2,
            3,
            4,
            5,
            6,

        ]
        
        
        var context: Context = ReaderContext(using: TestConfig()) { msg in
            print(msg)
        }
        
        let out = try! bytes.withUnsafeBytes{ ptr in
            try Outer.read(ptr, context: &context)!
        } as! Outer
        
        
        print(out.debugDescription)
        
        print(out.debugLayout)
        
        XCTAssertEqual(out.index, 23)
        XCTAssertEqual(out.inner.count, 6)
        XCTAssertEqual(out.chars, "42")
        XCTAssertEqual(out.inner[0].number, 1)
        XCTAssertEqual(out.inner[1].number, 2)
        XCTAssertEqual(out.inner[2].number, 3)
        XCTAssertEqual(out.inner[3].number, 4)
        XCTAssertEqual(out.inner[4].number, 5)
        XCTAssertEqual(out.inner[5].number, 6)
       
        
        XCTAssertEqual(context.offset, bytes.count)
        
    }
    
    
    func testExample() {

        print(Error("Something went wrong"))
        print(Error("Something went wrong", 23, 42))
        print(Error("Something went wrong", node: Self.self))
        print(Error("Something went wrong", 23, node: Self.self))
        print(Error("Something went wrong", 23, 42, node: Self.self))
    }
    
    
    func testReadString() {
    
        let data = Data([109, 105, 109, 0, 101, 108, 105])
        
        var offset = 0
        
        data.withUnsafeBytes{ ptr in
            XCTAssertEqual(try? ptr.read(&offset), "mim")
            XCTAssertEqual(try? ptr.read(&offset), "eli")
        }
        
        offset = 1
        
        data.withUnsafeBytes{ ptr in
            XCTAssertEqual(try? ptr.read(&offset, encoding: .utf8), "im\0eli")
        }
        
    }
    
    
    func testReadUInt32() {
     
        let data = Data([109, 105, 109, 0, 101, 108, 105, 96])
        
        var offset = 0
        
        data.withUnsafeBytes{ ptr in
            let fixed : UInt32? = try? ptr.read(&offset)
            XCTAssertEqual(fixed, 7170413)
        }
        
    }
}
