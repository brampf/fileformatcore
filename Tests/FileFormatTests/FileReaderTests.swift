import XCTest
import FileFormat

final class ReaderTests: XCTestCase {

    static var allTests = [
        ("testExample", testExample),
        ("testReadString", testReadString),
        ("testReadUInt32", testReadUInt32),
        ("testReadFrame", testReadFrame),
    ]
    
    func testExample() {

        print(Error("Something went wrong"))
        print(Error("Something went wrong", 23, 42))
        print(Error("Something went wrong", node: Self.self))
        print(Error("Something went wrong", 23, node: Self.self))
        print(Error("Something went wrong", 23, 42, node: Self.self))
    }
    
    func testReadUInt32() throws {
     
        let bytes : [UInt8] = [109, 105, 109, 0, 101, 108, 105, 96]
        
        let reader = bytes.withUnsafeBytes{ ptr in
            FileReader(data: ptr, configuration: DefaultConfiguraiton())
        }
        
        let result : UInt32 = try reader.read()
        
        XCTAssertEqual(result, 7170413)
    }
    
    func testReadString() throws {
        
        let bytes : [UInt8] = [116,101,115,116]
        
        let reader : FileReader = bytes.withUnsafeBytes{ ptr in
            return FileReader(data: ptr, configuration: DefaultConfiguraiton())
        }
                
        let text : String = try reader.read(.ascii, upperBound: bytes.count)
        
        print(text)
        
        XCTAssertEqual(text, "test")
        
    }
    
    
    func testReadFrame() throws {
        
        let bytes : [UInt8] = [42]
        
        let frame = try TestFrame.read(from: bytes, with: DefaultConfiguraiton())
        
        XCTAssertNotNil(frame)
        XCTAssertEqual(frame?.number, 42)
        
    }
    
    func testReadOperation() throws {
        
        let bytes : [UInt8] = [5,0,1,2,3,4,5,6,7,8,9,116,101,115,116]
        
        let reader = FileReader(data: bytes)
        let result : [(UInt8,UInt8)] = try reader.read{ reader in
            
            let count : UInt8 = try reader.read()
            
            var out : [(UInt8,UInt8)] = []
            
            for _ in 0..<count {
                let new1 : UInt8 = try reader.read()
                let new2 : UInt8 = try reader.read()
                out.append((new1,new2))
            }
            
            return out
        }
        
        XCTAssertEqual(result[0].0, 0)
        XCTAssertEqual(result[0].1, 1)
        XCTAssertEqual(result[1].0, 2)
        XCTAssertEqual(result[1].1, 3)
        XCTAssertEqual(result[2].0, 4)
        XCTAssertEqual(result[2].1, 5)
        XCTAssertEqual(result[3].0, 6)
        XCTAssertEqual(result[3].1, 7)
        XCTAssertEqual(result[4].0, 8)
        XCTAssertEqual(result[4].1, 9)
    }
    
    func testNested() throws {
        
        let bytes : [UInt8] = [42,42,0,0,0,116,101,115,116]
        
        let reader = FileReader(data: bytes)
        
        let result : OuterFrame = try reader.read()
        
        XCTAssertEqual(result.number, 42)
        XCTAssertEqual(result.inner.number, 42)
        XCTAssertEqual(result.text, "test")
    }
    
    func testOpenFrame() throws {
    
        let bytes : [UInt8] = [42,116,101,115,116,116,101,115,116]
        
        let reader = FileReader(data: bytes)
        
        let first : DemoFrame = try reader.read()
        let second : DemoFrame = try reader.read()
        
        XCTAssertTrue(first is DemoFrameA)
        XCTAssertTrue(second is DemoFrameB)
    }
}


//MARK:- Test classes

struct TestFrame : BaseFrame {
    
    var number : UInt8 = 0
    
    init(_ reader: FileReader) throws {
        
        self.number = try reader.read()
    }
}

class DemoFrame : OpenFrame, Readable {
    
    typealias Bound = DemoFrame
    
    static var toggle : Bool = false
    
    var id : UInt8
    
    required init(_ reader: FileReader) throws {
        
        self.id = try reader.read()
    }
    
    static func new(_ reader: FileReader) throws -> DemoFrame.Type {
        
        toggle.toggle()
        
        if toggle {
            return DemoFrameA.self
        } else {
            return DemoFrameB.self
        }
        
    }
}

class DemoFrameA : DemoFrame {
    
    var number : UInt32

    required init(_ reader: FileReader) throws {
        
        self.number = try reader.read()
        
        try super.init(reader)
    }
    
}

class DemoFrameB : DemoFrame {
    
    var text : String
    
    required init(_ reader: FileReader) throws {
        
        self.text = try reader.read()
        
        try super.init(reader)
    }
}


struct OuterFrame : Readable {
    
    var number : UInt8
    
    var inner : InnerFrame
    
    var text : String
    
    public init(_ reader: FileReader) throws {
        self.number = try reader.read()
        self.inner = try reader.read()
        self.text = try reader.read()
    }
    
}

struct InnerFrame : Readable {
    
    var number : UInt32
    
    init(_ reader: FileReader) throws {
        
        self.number = try reader.read()
    }
    
}
