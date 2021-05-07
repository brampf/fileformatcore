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

/// A property wrapper for just one single `Readable`
public struct ConditionalChild<Parent: AnyReadable, Meta : Equatable, R: AnyReadable> : PersistentProperty {
    
    public typealias Value = R?
    
    public var bound: KeyPath<Parent, Meta>
    public var criterion : Meta
    
    init(path: KeyPath<Parent, Meta>, equals: Meta) {
        self.bound = path
        self.criterion = equals
    }
    
    public func read<C: Context>(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout C) throws -> Value? {
        
        if let match = context.seek(for: bound), match == criterion {
            return try Value.read(bytes, with: &context, symbol)
        } else {
            return nil
        }
    }
}


extension Persistent where Parent: AnyReadable, Value: AnyReadable, Meta: Equatable, Property == ConditionalChild<Parent, Meta, Value> {
    
    convenience public init(wrappedValue initialValue: Value,_ path: KeyPath<Parent, Meta>, equals: Meta) {
        self.init(wrappedValue: initialValue, ConditionalChild(path: path, equals: equals))
    }
}


extension Persistent where Parent: AnyReadable, Value: AutoReadable, Meta: Equatable, Property == ConditionalChild<Parent, Meta, Value>{
    
    convenience public init(_ path: KeyPath<Parent, Meta>, equals: Meta) {
        self.init(wrappedValue: Value.init(), ConditionalChild(path: path, equals: equals))
    }
}
