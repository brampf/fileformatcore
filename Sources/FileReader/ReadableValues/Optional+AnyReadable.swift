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


extension Optional : AnyReadable where Wrapped : AnyReadable {
    
    public static func new<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?) throws -> Self? {
        return Self.init(nilLiteral: ())
    }

    public static func upperBound<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C) throws -> Int? {
        try Wrapped.upperBound(bytes, with: &context)
    }
    
    public mutating func read<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?, upperBound: Int?) throws {
        
        if var me = self {
            try me.read(bytes, with: &context, symbol, upperBound: upperBound)
            // assign back as 'me' is not a reference but a copy
            self = me
        } else {
            // uninitialized Optional
            if let new = try Wrapped.read(bytes, with: &context, symbol) {
                self = new
            }
        }
        
    }
    
    public var byteSize: Int {
        self?.byteSize ?? 0
    }

}
