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

extension Array : Readable, ReadableElement, ReadableFrame where Element : ReadableElement {
    
    public mutating func read<C: Context>(_ bytes: UnsafeRawBufferPointer, context: inout C, _ symbol: String? = nil) throws {
        
        let upperBound = context.head?.endOffset ?? bytes.endIndex
        
        var new = [Element]()
        
        
        while context.offset < upperBound {
            if let next = try Element.readElement(bytes, with: &context, symbol) {
                new.append(next)
            }
        }
        
        self = new
    }
    
    public var byteSize: Int {
        self.reduce(into: 0) { $0 += $1.byteSize }
    }
    
}

extension Array where Element : ReadableElement {
    
    public var count8 : UInt8 {
        UInt8(count)
    }
    
    public var count16 : UInt16 {
        UInt16(count)
    }
    
    public var count32 : UInt32 {
        UInt32(count)
    }
    
    public var count64 : UInt64 {
        UInt64(count)
    }
    
}
