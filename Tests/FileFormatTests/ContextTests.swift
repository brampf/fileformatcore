import XCTest
import Reader

final class ContextTests: XCTestCase {

    class MyConfig : Reader.Configuration {
        
        var toggle : Bool = false
    }
    
    class MyContext : Reader.Context {
        
        var randomProperty : String = "Hello World"
        
        var config : MyConfig? = nil
    }
    
    class MyNode : Reader.Node {
        typealias Conf = MyConfig
        typealias Context = MyContext
        
        required init?(_ data: UnsafeRawBufferPointer, context: inout MyContext){
            //
        }
    }
    
    class MyRoot : MyNode, Reader.Root{
        
        static func configure(_ context: ContextTests.MyContext, from config: ContextTests.MyConfig?) {
            context.config = config
        }
        
        required init?(_ data: UnsafeRawBufferPointer, context: inout ContextTests.MyContext) {
            super.init(data, context: &context)
        }
    }
    
    func testInheritance(){
        
    }
    
}
