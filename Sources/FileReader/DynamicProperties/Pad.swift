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

@propertyWrapper public final class Pad : ReadableProperty {
    
    public var toSize : Int = 0
    
    public var wrappedValue : UInt8
    
    public init(_ size: Int, wrappedValue initialValue: UInt8) {
        self.toSize = size
        self.wrappedValue = initialValue
    }
    
}

extension Pad {
    
    public func read(_ data: UnsafeRawBufferPointer, context: inout Context, _ symbol: String?) throws {
        
        let factor : Double = Double(context.offset) / Double(toSize)
        context.offset = toSize * Int(factor.rounded(.up))
    }
    
    public var byteSize: Int {
        0
    }
}