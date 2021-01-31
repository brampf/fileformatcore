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


extension Optional : Readable, ReadableElement where Wrapped : ReadableElement {
    
    public static func new(_ bytes: UnsafeRawBufferPointer, with context: inout Context, _ symbol: String?) throws -> Optional<Wrapped>? {
 
        // instantaniously try to read the wrapped element
        return try Wrapped.new(bytes, with: &context, symbol)
    }
    
    public mutating func read(_ bytes: UnsafeRawBufferPointer, context: inout Context, _ symbol: String?) throws {
        
        if var me = self {
            try me.read(bytes, context: &context, symbol)
            // assign back as 'me' is not a reference but a copy
            self = me
        } else {
            // uninitialized Optional
            self = nil
        }
        
    }
    
    public var byteSize: Int {
        if let me = self {
            return me.byteSize
        } else {
            return 0
        }
    }
    
    public init() {
        self = nil
    }
    
    public static func size(_ bytes: UnsafeRawBufferPointer, with context: inout Context) -> Int? {
        return Wrapped.size(bytes, with: &context)
    }

}
