import XCTest
import FileReader

final class ReaderTests: XCTestCase {

    static var allTests = [
        ("testExample", testExample),
        ("testReadString", testReadString),
        ("testReadUInt32", testReadUInt32),
        ("testReadFrame", testReadFrame),
        ("testCustomAnyReadable", testCustomAnyReadable)
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
        
        struct TestFrame : AutoReadable {
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [42]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in            
            try TestFrame.read(ptr, with: &context, nil)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertEqual(frame?.number, 42)
        
    }
    
    func testCustomAnyReadable() throws {
        
        struct TestFrame : AnyReadable {
            
            static func new<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?) throws -> TestFrame? {
                TestFrame(byteSize: 16)
            }
            
            static func upperBound<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C) throws -> Int? {
                nil
            }
            
            mutating func read<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?, upperBound: Int?) throws {
                self.number = try bytes.read(&context.offset, byteSwapped: context.bigEndian, symbol)
            }
        
            var byteSize: Int
            
            
            @Persistent var number : UInt8 = 0
            
        }
        
        let bytes : [UInt8] = [42]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestFrame.read(ptr, with: &context, nil)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertEqual(frame?.number, 42)
        
    }
    
    func testAbstractReadable() throws {

        struct TestReadable : AutoReadable {
            
            @Persistent var children : [TestClass] = []
            
        }
        
        class TestClass : AbstractReadable, AutoReadable {
            static var toggle: Bool = true
            
            static func next<C>(_ bytes: UnsafeRawBufferPointer, with context: C, _ symbol: String?) throws -> TestClass? where C : Context {
                
                defer {
                    Self.toggle.toggle()
                }
                
                if toggle {
                    return TestClassA()
                } else {
                    return TestClassB()
                }
                
            }
            
            @Persistent var number : UInt8 = 0
            
            
            required init() {
                
            }
            
            
            static func upperBound<C>(_ bytes: UnsafeRawBufferPointer, with context: inout C) throws -> Int? where C : Context {
                nil
            }
            
            var byteSize: Int {
                1
            }
            
        }
        
        
        class TestClassA : TestClass {
            
            @Persistent var value : UInt32 = 0
            
        }
        
        class TestClassB : TestClass {
            
            @Persistent(UInt32.self) var value : String = ""
            
        }



        let bytes : [UInt8] = [
            1,116,101,115,116,
            2,116,101,115,116
        ]
        
        var context = DefaultContext()
        let frame = try bytes.withUnsafeBytes{ ptr in
            try TestReadable.read(ptr, with: &context, nil)
        }
        
        XCTAssertNotNil(frame)
        XCTAssertEqual(frame?.children.count, 2)
        XCTAssertTrue(frame?.children[0] is TestClassA)
        XCTAssertTrue(frame?.children[1] is TestClassB)
        XCTAssertEqual((frame?.children[0] as? TestClassA)?.value, 1952805748)
        XCTAssertEqual((frame?.children[1] as? TestClassB)?.value, "test")
        
        
    }
}
