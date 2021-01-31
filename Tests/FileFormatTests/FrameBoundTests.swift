import XCTest
@testable import FileReader

final class FrameBoundTests: XCTestCase {

    struct TestConfig : FileConfiguration {
        
        var bigEndian: Bool = true
        
        var ignoreRecoverableErrors: Bool = true
    }
    
 
    func testSequentialFrame() throws {
        
        let bytes = "Hallo World,42,\"Hello, World!\",test,\"Hully\r\nGully\",test,23\r\ntest,\"next\",23,44"
        
        let frame = SequentialFrame(bound: [0x0D, 0x0A], divider: 0x2C, escape: 0x22) { (idx, slice) -> String in
            //print("\(idx) : \(slice)")
            
            let data = Data(Array(slice))
            
            return String(data: data, encoding: .utf8) ?? "ERROR"
        }
        
        var context : Context = ReaderContext(using: TestConfig()) { msg in
            print(msg)
        }
        
        let new = try bytes.data(using: .utf8)?.withUnsafeBytes{ ptr in
            try frame.read("Seq", from: ptr, in: &context)
        }
        
        new?.forEach{ e in
            print(e)
        }
        
        
    }
    
}
