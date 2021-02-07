import XCTest
import FileReader

final class ReaderTests: XCTestCase {

    static var allTests = [
        ("testExample", testExample),
        ("testReadString", testReadString),
        ("testReadUInt32", testReadUInt32),
        ("testReadFrame", testReadFrame)
    ]
    
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
            XCTAssertEqual(try? ptr.read(&offset, upperBound: data.count), "mim")
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
    
    func testReadFrame() throws {
        
        struct TestFrame : ReadableFrame {
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [42]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in            
            try TestFrame.readNext(ptr, with: &context, nil) as? TestFrame
        }
        
        XCTAssertNotNil(frame)
        XCTAssertEqual(frame?.number, 42)
        
    }
    
    func testReadElement() throws {
        
        struct TestFrame : ReadableElement {
            
            static func new() -> TestFrame {
                TestFrame(byteSize: 16)
            }
            
            mutating func read<C>(_ bytes: UnsafeRawBufferPointer, context: inout C, _ symbol: String?) throws where C : Context {
                self.number = try bytes.read(&context.offset, byteSwapped: context.bigEndian, symbol)
            }
            
            static func next<C>(_ bytes: UnsafeRawBufferPointer, with context: C, _ symbol: String?) throws -> (element: ReadableElement.Type?, size: Int?) where C : Context {
                (TestFrame.self,nil)
            }
            
            var byteSize: Int
            
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [42]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.readNext(ptr, with: &context, nil) as? TestFrame
        }
        
        XCTAssertNotNil(frame)
        XCTAssertEqual(frame?.number, 42)
        
    }
}
