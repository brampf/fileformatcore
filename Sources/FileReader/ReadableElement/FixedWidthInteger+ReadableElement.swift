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

extension FixedWidthInteger {
    
    /// Read `FixedWidthInteger`
    public static func new(_ bytes: UnsafeRawBufferPointer, with context: inout Context, _ name: String?) throws -> Self? {
        
        print("[\(String(describing: context.offset).padding(toLength: 8, withPad: " ", startingAt: 0))] READ \(name ?? "") : \(type(of: self))")
        
        // make sure that the offset is within the allowed bounds
        guard context.offset >= 0 && context.offset <= bytes.count - MemoryLayout<Self>.size else {
            throw ReaderError.invalidMemoryAddress(ErrorStack(name, Self.self, context.offset), bytes.count - MemoryLayout<Self>.size)
        }
        
        /// access the memory
        guard let val = bytes.baseAddress?.advanced(by: context.offset).assumingMemoryBound(to: Self.self).pointee else {
            throw ReaderError.incompatibleDataFormat(ErrorStack(name, Self.self, context.offset))
        }
        
        /// move the pointer
        context.offset += MemoryLayout<Self>.size
        /// return the requested value
        return context.bigEndian ? val.byteSwapped : val
    }
    
    public var byteSize: Int {
        MemoryLayout<Self>.size
    }
}

extension Int64 : ReadableElement {
    
}

extension Int32 : ReadableElement {
    
}

extension Int16 : ReadableElement {
    
}

extension Int8 : ReadableElement {
    
}

extension UInt64 : ReadableElement {
    
}

extension UInt32 : ReadableElement {
    
}

extension UInt16 : ReadableElement {
    
}

extension UInt8 : ReadableElement {
    
}
