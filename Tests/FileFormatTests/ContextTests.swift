import XCTest
import FileReader
/*
final class ContextTests: XCTestCase {

    final class MyConfig : FileReader.Configuration {
        
        public static var `default`: ContextTests.MyConfig = .init()
        
        var toggle : Bool = false
    }
    
    class MyContext : FileReader.Context<MyConfig> {
        
        var randomProperty : String = "Hello World"
        
        var config : MyConfig? = nil
    }
    
    class MyNode : FileReader.Node {
        typealias Conf = MyConfig
        typealias Context = MyContext
        
        required init?(_ data: UnsafeRawBufferPointer, context: inout MyContext){
            //
        }
    }
    
    class MyRoot : MyNode, FileReader.Root{
        
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
*/
