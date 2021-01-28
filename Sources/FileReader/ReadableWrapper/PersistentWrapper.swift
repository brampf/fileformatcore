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

public protocol BoundType {
    associatedtype Value : ReadableElement
    associatedtype Bound
    
    var bound : Bound {get}
    
    func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout Context) throws -> Value?
}

public struct Frame<R: ReadableElement> : BoundType {
    public typealias Value = R
    
    public var bound: Void
    
    init() {
        
    }
    
    public func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout Context) throws -> Value? {
        
        return try Value.new(bytes, with: &context, symbol)
    }
}

public struct Repeating<R: ReadableElement> : BoundType {
    public  typealias  Value = [R]
    
    public var bound : Void
    
    init() {
        
    }
    
    public func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout Context) throws -> Value? {
        
        let upperBound = context.head?.endOffset ?? bytes.endIndex
        
        var index = 0
        var new : [R] = .init()
        while context.offset < upperBound {
            if let next = try R.new(bytes, with: &context, symbol ?? ""+"[\(index)]") {
                new.append(next)
            }
            index += 1
        }
        return new
    }
}

public struct Counting<Parent: ReadableElement, R: ReadableElement, F: FixedWidthInteger & ReadableElement> : BoundType {
    public  typealias  Value = [R]
    
    public var bound : KeyPath<Parent,Transient<Parent,F>>
    
    public func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout Context) throws -> Value? {
        
        if let parent = context.head?.readable as? Parent {
            let id = parent[keyPath: bound].uuid
            let count : F = context[id] ?? .zero
            
            var new : [R] = .init()
            
            for _ in 0 ..< count {
                if let next = try R.new(bytes, with: &context, symbol) {
                    new.append(next)
                }
            }
            return new
        } else {
            return []
        }
    }
}

public struct Absolute<R: ReadableElement, F: FixedWidthInteger> : BoundType {
    public typealias Value = [R]
    
    public var bound : F
    
    public func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout Context) throws -> Value? {
        
        var new : [R] = .init()
        
        for _ in 0 ..< bound {
            if let next = try R.new(bytes, with: &context, symbol) {
                new.append(next)
            }
        }
        return new
    }
    
}

public struct Unless<Parent: ReadableElement, R: ReadableElement, Criterion: Equatable> : BoundType {
    public typealias Value = [R]
    
    public var bound : KeyPath<Parent,Criterion>
    public var criterion : Criterion
    
    public func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout Context) throws -> Value? {
        
        if let parent = context.head?.readable as? Parent {
            
            var new : [R] = .init()
            
            while parent[keyPath: bound] != criterion {
                if let next = try R.new(bytes, with: &context, symbol) {
                    new.append(next)
                }
            }
            return new
        } else {
            return []
        }
    }
}

struct Until<R: ReadableElement> : BoundType {
    typealias Value = String
    
    public var bound : [UInt8]
    
    func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout Context) throws -> Value? {
        
        let upperBound = context.head?.endOffset ?? bytes.endIndex
        
        let range = bytes.firstRange(of: bound, in: context.offset..<upperBound)
        let length = (range?.startIndex ?? bytes.endIndex) - context.offset
        
        return try bytes.read(&context.offset, len: length , encoding: .utf8, symbol)
        
    }
}

public struct EmptyFrame : ReadableAutoalignFrame {
    
    public init() {
        
    }
}

@propertyWrapper public class Persistent<Parent: ReadableElement, Value, Meta, Bound : BoundType> : ReadableWrapper {
    
    var bound : Bound? = nil
    
    public var wrappedValue : Bound.Value
    
    public init(wrappedValue: Bound.Value, _ bound: Bound?){
        self.bound = bound
        self.wrappedValue = wrappedValue
    }
    
    func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout Context) throws {
        
        if let frame = bound, let new = try frame.read(symbol, from: bytes, in: &context) {
            wrappedValue = new
        } else if let new = try Bound.Value.new(bytes, with: &context, symbol) {
            wrappedValue = new
        } else {
            // Errro Handling?
        }
        
    }
    
    func debugLayout(_ level: Int) -> String {
        
        return wrappedValue.debugLayout(level+1)
    }
    
}

extension Persistent where Parent : ReadableElement, Meta: FixedWidthInteger & ReadableElement, Bound == Counting<Parent, Value, Meta> {
    
    convenience public init(wrappedValue initialValue: Bound.Value, _ path: KeyPath<Parent, Transient<Parent,Meta>>) {
        self.init(wrappedValue: initialValue, Counting(bound: path))
    }
}

extension Persistent where Parent == EmptyFrame, Value: ReadableElement, Meta == Void, Bound == Frame<Value> {
    
    convenience public init(wrappedValue initialValue: Value) {
        self.init(wrappedValue: initialValue, Frame())
    }
}
