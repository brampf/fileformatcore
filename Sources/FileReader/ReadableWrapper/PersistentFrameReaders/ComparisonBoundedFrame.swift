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
 Reads child elements into an array until a child matches the comparion provided
 */
public struct ComparisonBoundedFrame<R: AnyReadable, Criterion: Equatable> : PersistentFrameReader {
    public typealias Value = [R]
    
    public var bound : KeyPath<R,Criterion>
    public var criterion : Criterion
    
    public func read<C: Context>(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout C) throws -> Value? {
        
        context.head?.index = 0
        
        var new : [R] = .init()
        
        var condition = false
        repeat {
            if let next = try R.read(bytes, with: &context, symbol) {
                new.append(next)
                
                condition = next[keyPath: bound] != criterion
            }
            
            context.head?.index += 1
            
        } while context.offset < (context.head?.endOffset ?? bytes.endIndex) && condition
        
        context.head?.index = 0
        
        return new
        
    }
    
}


extension Persistent where
    Meta: Equatable,
    Value == [Parent],
    Parent : AnyReadable,
    Bound == ComparisonBoundedFrame<Parent, Meta>
{
    
    convenience public init(wrappedValue initialValue: Bound.Value, _ path: KeyPath<Parent, Meta>, equals criterion: Meta) {
        
        self.init(wrappedValue: initialValue, ComparisonBoundedFrame(bound: path, criterion: criterion))
    }
    
}
