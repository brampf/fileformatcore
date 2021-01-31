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

/**
 A `PersistentFrameReader` to read arrays up to a specific length based on the value of a previously read property

*/
public struct CounterBoundedFrame<Parent: ReadableElement, R: ReadableElement, F: FixedWidthInteger & ReadableElement> : PersistentFrameReader {
    public  typealias  Value = [R]
    
    public var bound : KeyPath<Parent,F>
    
    public func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout Context) throws -> Value? {
        
        guard let count = context.seek(for: bound) else {
            // no idea what to do, syntax is definitely not right
            throw ReaderError.internalError(ErrorStack(#function, Value.self, context.offset), "Counting index not found")
        }
        
        var new : [R] = .init()
        
        for _ in 0 ..< count {
            if let next = try R.readElement(bytes, with: &context, symbol) {
                new.append(next)
            }
        }
        return new
    }
}

