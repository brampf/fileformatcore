/*
 
 Copyright (c) <2021>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

public protocol AnyReadable {
    
    /// crate a new Instance and initialize with default values without moving the offset
    static func new<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?) throws -> Self?
    
    /// determines an upper bound of the entity
    static func upperBound<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C) throws -> Int?
    
    /// Read all readable values
    mutating func read<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?, upperBound: Int?) throws
    
    /// size of this readable in bytes
    var byteSize : Int { get }
    
    /// returns as textual tree representation of  this `Readable` and its children
    var debugLayout : String { get }
    
}

//MARK:- Reader implementation
extension AnyReadable {
    
    /**
     standard reading method
     */
    public static func read<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String? = nil) throws -> Self? {
        
        try Self.read(bytes, with: &context, symbol, upperBound: nil)
    }
    
    /**
     standard reading method
     */
    public static func read<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String? = nil, upperBound: Int? = nil) throws -> Self? {
        
        print("[\(String(describing: context.offset).padding(toLength: 8, withPad: " ", startingAt: 0))] READ \(symbol ?? "") : \(type(of: self))")
        
        // create new instance
        guard var new = try Self.new(bytes, with: &context, symbol) else {
            return nil
        }
        
        var endOffset : Int? = nil
        if let bound = try Self.upperBound(bytes, with: &context) {
            endOffset = bound
        }
        if let bound =  upperBound {
            endOffset = bound
        }
         
        // push this element onto the stack
        context.push(new, upperBound: endOffset)
        
        // read all readable values of this element
        try new.read(bytes, with: &context, symbol, upperBound: endOffset)
        
        // pop the stack
        let closing = try context.pop()
        
        // check that we popped the correct element
        guard closing is Self else {
            // if not, continuing makes no sense as we don't know where we acutally are
            throw ReaderError.internalError(ErrorStack(nil, Self.self, context.offset), "Closing the wrong Element")
        }
        
        // return new freshly read element
        return new
        
    }
    
}

//MARK:- Debug Representations
extension AnyReadable {
    
    public var debugLayout : String {
        return self.debugLayout(0)
    }
    
    func debugLayout(_ level: Int = 0) -> String {
        var ret = String(repeating: " ", count: level)+"⎿"+" (\(Self.self)) [\(self.byteSize) bytes]"
        
        let mirror = Mirror(reflecting: self)
        mirror.children.forEach{ child in
            
            if let mem = child.value as? ReadableWrapper {
                ret += "\n"
                ret += mem.debugLayout(level+1)
            }
        }
        return ret
    }
}
