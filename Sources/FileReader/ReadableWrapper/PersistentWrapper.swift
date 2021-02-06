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

public struct EmptyFrame : ReadableFrame {
    
    public init() {
        
    }
    
    public var debugDescription: String {
        "EMTPY"
    }
}

@propertyWrapper public class Persistent<Parent: ReadableElement, Value, Meta, Bound : PersistentFrameReader> {
    
    internal var uuid : UUID = UUID()
    
    var bound : Bound
    
    public var wrappedValue : Bound.Value
    
    public init(wrappedValue: Bound.Value, _ bound: Bound){
        self.bound = bound
        self.wrappedValue = wrappedValue
    }
    
}

extension Persistent : ReadableWrapper {
    
    public func read<C: Context>(_ bytes: UnsafeRawBufferPointer, context: inout C, _ symbol: String? = nil) throws {
        
        if let new = try bound.read(symbol, from: bytes, in: &context) {
            wrappedValue = new
        }
    }
    
    public var byteSize: Int {
        return wrappedValue.byteSize
    }
    
    public func debugLayout(_ level: Int) -> String {
        
        return wrappedValue.debugLayout(level+1)
    }
}

