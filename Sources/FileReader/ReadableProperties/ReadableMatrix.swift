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

import Foundation

@propertyWrapper public final class Readable3x3Matrix<F: FixedWidthInteger> {
    
    public var wrappedValue : (F,F,F,F,F,F,F,F,F)
    
    public init(wrappedValue initialValue: (F,F,F,F,F,F,F,F,F)) {
        self.wrappedValue = initialValue
    }
    

}

extension Readable3x3Matrix : ReadableProperty {
    
    public func read(_ data: UnsafeRawBufferPointer, context: inout Context, _ symbol: String?) throws {
        let m1 : F = try data.read(&context.offset, byteSwapped: context.bigEndian, symbol)
        let m2 : F = try data.read(&context.offset, byteSwapped: context.bigEndian, symbol)
        let m3 : F = try data.read(&context.offset, byteSwapped: context.bigEndian, symbol)
        let m4 : F = try data.read(&context.offset, byteSwapped: context.bigEndian, symbol)
        let m5 : F = try data.read(&context.offset, byteSwapped: context.bigEndian, symbol)
        let m6 : F = try data.read(&context.offset, byteSwapped: context.bigEndian, symbol)
        let m7 : F = try data.read(&context.offset, byteSwapped: context.bigEndian, symbol)
        let m8 : F = try data.read(&context.offset, byteSwapped: context.bigEndian, symbol)
        let m9 : F = try data.read(&context.offset, byteSwapped: context.bigEndian, symbol)
        
        wrappedValue = (m1,m2,m3,m4,m5,m6,m7,m8,m9)
    }
    
    public var byteSize: Int {
        9 * MemoryLayout<F>.size
    }
    
}
