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
public struct CounterBoundedList<Parent: AnyReadable, R: AnyReadable, F: FixedWidthInteger & AnyReadable> : PersistentProperty {
    public  typealias  Value = [R]
    
    public var bound : KeyPath<Parent,F>
    
    public func read<C: Context>(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout C) throws -> Value? {
        
        guard let count = context.seek(for: bound) else {
            
            context.head?.transients.forEach{ t in
                print("\(type(of: context.head?.readable)) : \(t.key) = \(t.value)")
            }
            
            // no idea what to do, syntax is definitely not right
            throw ReaderError.internalError(ErrorStack(symbol, Value.self, context.offset), "Counting index for \(type(of: Parent.self)) not found")
        }
        
        context.head?.index = 0
        
        var new : [R] = .init()
        
        for _ in 0 ..< count {
            
            if let next = try R.read(bytes, with: &context, symbol) {
                new.append(next)
            }
            context.head?.index += 1
        }
        
        context.head?.index = 0
        return new
    }
}

extension Persistent where Parent : AnyReadable, Meta: FixedWidthInteger & AnyReadable, Property == CounterBoundedList<Parent, Value, Meta> {
    
    convenience public init(wrappedValue initialValue: Property.Value, _ path: KeyPath<Parent, Meta>) {
        self.init(wrappedValue: initialValue, CounterBoundedList(bound: path))
    }
}
