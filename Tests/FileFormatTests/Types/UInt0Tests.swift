import XCTest

final class UInt0Tests: XCTestCase {

    /*
    func testInit() {
        
        let z1 = UInt0(0)
        
        XCTAssertEqual(z1, 0)
        
        let z2 = UInt0("test")
        
        XCTAssertEqual(z2, nil)
        
        let z3 = UInt0(truncatingIfNeeded: 10000)
        
        XCTAssertEqual(z3, 0)
    }
    
    func testMemorySize() {
        
        XCTAssertEqual(UInt0.bitWidth, 0)
        
        XCTAssertEqual(MemoryLayout<UInt0>.size, 0)
    }
    
    func testUnsafe() {
        
        let bytes : [UInt8] = [0b00000001,0b00000010,0b00000011,0b00000100,0b00000101,0b00000110,0b00000111]
        
        let values = bytes.withUnsafeBytes{ ptr in
            Array(ptr.bindMemory(to: UInt0.self))
        }
        
        XCTAssertNotEqual(values, [0,0,0,0,0,0])
        XCTAssertEqual(values, [1,0,0,0,0,0,0])
        XCTAssertEqual(values, [1,0,0,0,0,0,0])
    }
    
    func testReader() {
        
        let bytes : [UInt8] = [0b00000001,0b00000010,0b00000011,0b00000100,0b00000101,0b00000110,0b00000111]
        
        var offset = 3
        let zero : UInt0 = try! bytes.withUnsafeBytes{ ptr in
            try ptr.read(&offset)
            
        }
        
        XCTAssertEqual(zero,0)
    }
    */
}

