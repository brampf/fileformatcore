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


extension Optional : ReadableElement where Wrapped : ReadableElement {
    
    public static func new() -> Self {
        return Self.init(nilLiteral: ())
    }

    
    public mutating func read<C: Context>(_ bytes: UnsafeRawBufferPointer, context: inout C, _ symbol: String?) throws {
        
        if var me = self {
            try me.read(bytes, context: &context, symbol)
            // assign back as 'me' is not a reference but a copy
            self = me
        } else {
            // uninitialized Optional
            if let new = try Wrapped.readNext(bytes, with: &context, symbol) as? Wrapped {
                self = new
            }
        }
        
    }

}


extension Optional : Readable where Wrapped : Readable {
    
    public static func next<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: C, _ symbol: String?) throws -> (element: ReadableElement.Type?, size: Int?) {
        
        try Wrapped.next(bytes, with: context, symbol)
    }
    
    public var byteSize: Int {
        self?.byteSize ?? 0
    }
    
}
