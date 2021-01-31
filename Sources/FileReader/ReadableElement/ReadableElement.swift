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

/// A `Readable` element is a container for a serieos of `ReadableValue`
public protocol ReadableElement : Readable {
    
    /// defaut initializer used to create new instances
    init()
    
    /// method to read property values of this `Readable` from raw data
    mutating func read(_ bytes: UnsafeRawBufferPointer, context: inout Context, _ symbol: String?) throws
    
    /**
     Implementation of this function allows to provide a size for the the readable; This allows the parser to check against the resulting upper bound when reading child values
     
     - Parameters:
     -  data: The `UnsafeRawBufferPointer` to read from
     -  context : The `Context` to use for reading the data
     
     - Returns Size of this `Readable`in bytes or `nil` if the only upper bound is EOF
     */
    static func size(_ bytes: UnsafeRawBufferPointer, with context: inout Context) -> Int?
    
}

//MARK:- Reader implementation
extension ReadableElement {
    
    /**
     standard reading method
     */
    public static func readElement(_ bytes: UnsafeRawBufferPointer, with context: inout Context, _ symbol: String? = nil) throws -> Self? {
        
        print("[\(String(describing: context.offset).padding(toLength: 8, withPad: " ", startingAt: 0))] READ \(symbol ?? "") : \(type(of: self))")
        
        // create new instance
        guard var new = try Self.new(bytes, with: &context, symbol) else {
            return nil
        }
        
        // see if the frame size can be determined
        let size = Self.size(bytes, with: &context)
        
        // push this element onto the stack
        context.push(new, size: size)
        
        // read all readable values of this element
        try new.read(bytes, context: &context, symbol)
        
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
    
    mutating public func read(_ bytes: UnsafeRawBufferPointer, context: inout Context, _ symbol: String? = nil) throws {
        
        let mirror = Mirror(reflecting: self)
        try recursiveRead(mirror, from: bytes, context: &context)
    }
    
    private func recursiveRead(_ mirror: Mirror, from bytes: UnsafeRawBufferPointer, context: inout Context) throws {
        
        // read super readable first
        if let sup = mirror.superclassMirror {
            try recursiveRead(sup, from: bytes, context: &context)
        }
        
        // read this readable
        try mirror.children.forEach{ child in
            if var wrapper = child.value as? ReadableWrapper {
                try wrapper.read(bytes, context: &context, child.label)
            }
        }
    }
}

//MARK:- Debug Representations
extension ReadableElement {
    
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

