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

public struct EmptyFrame : ReadableAutoFrame {
    
    public init() {
        
    }
    
    public var debugDescription: String {
        "EMTPY"
    }
}

@propertyWrapper public class Persistent<Parent: ReadableElement, Value, Meta, Bound : BoundType> : ReadableWrapper {
    
    var bound : Bound
    
    public var wrappedValue : Bound.Value
    
    public init(wrappedValue: Bound.Value, _ bound: Bound){
        self.bound = bound
        self.wrappedValue = wrappedValue
    }
    
    func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout Context) throws {
        
        if let new = try bound.read(symbol, from: bytes, in: &context) {
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

extension Persistent where Parent : ReadableElement, Meta: FixedWidthInteger & ReadableElement, Bound == CounterBoundedFrame<Parent, Value, Meta> {
    
    convenience public init(wrappedValue initialValue: Bound.Value, _ path: KeyPath<Parent, Transient<Parent,Meta>>) {
        self.init(wrappedValue: initialValue, CounterBoundedFrame(bound: path))
    }
}

extension Persistent where Parent == EmptyFrame, Value: ReadableElement, Meta == Void, Bound == SingleElementFrame<Value> {
    
    convenience public init(wrappedValue initialValue: Value) {
        self.init(wrappedValue: initialValue, SingleElementFrame())
    }
}

extension Persistent where Parent : ReadableElement, Meta: Equatable, Bound == CriterionBoundedFrame<Parent, Value, Meta> {
    
    convenience public init(wrappedValue initialValue: Bound.Value, _ path: KeyPath<Parent, Meta>, equals criterion: Meta) {
        self.init(wrappedValue: initialValue, CriterionBoundedFrame(bound: path, criterion: criterion))
    }
    
}

extension Persistent where Parent: ReadableElement, Meta: Equatable, Bound == ComparisonBoundedFrame<Value, Meta>, Parent == Value {
    
    convenience public init(wrappedValue initialValue: Bound.Value, _ path: KeyPath<Parent, Meta>, equals criterion: Meta) {
        self.init(wrappedValue: initialValue, ComparisonBoundedFrame(bound: path, criterion: criterion))
    }
    
}

extension Persistent where Parent == EmptyFrame, Meta: Equatable, Bound == ValueBoundedFrame<Value>, Meta == Value {
    
    convenience public init(wrappedValue initialValue: Bound.Value, equals criterion: Meta) {
        self.init(wrappedValue: initialValue, ValueBoundedFrame(bound: criterion))
    }
    
}

extension Persistent where Value == String, Bound == StringFrame<Parent, Meta> {
    
    
    convenience public init(wrappedValue initialValue: Bound.Value, _ path: KeyPath<Parent, Transient<Parent,Meta>>? = nil, _ type: StringFrame<Parent,Meta>.StringType = .utf8) {
        
        self.init(wrappedValue : initialValue, StringFrame(bound: path, type: type))
    }
    
}

extension Persistent where Parent == EmptyFrame, Value == String, Meta == UInt8, Bound == StringFrame<Parent, Meta> {
    
    
    convenience public init(wrappedValue initialValue: Bound.Value, _ type: StringFrame<Parent,Meta>.StringType = .utf8) {
        
        self.init(wrappedValue : initialValue, StringFrame(type: type))
    }
    
}
