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

/**
 A property who's value is read and thus can be used as counter or condition in other property wrappers but who's value is computed at runtime
 */
@propertyWrapper public final class Transient<Parent: AnyReadable, Meta, Value: AnyReadable, Handler : PropertyHandler> {
    
    public var handler : Handler
    
    public var wrappedValue: Handler.Value
    
    public init(wrappedValue: Handler.Value, _ handler: Handler){
        self.handler = handler
        self.wrappedValue = wrappedValue
    }
}

extension Transient where Handler.Value : AutoReadable {
    
    public convenience init(_ handler: Handler){
        self.init(wrappedValue: Handler.Value(), handler)
    }
}

extension Transient where Handler.Value == Optional<Value> {
    
    public convenience init(_ handler: Handler) {
        self.init(wrappedValue: nil, handler)
    }
    
}

extension Transient where Handler : ReferencedPropertyHandler, Handler.Value == Value, Handler.Parent == Parent{
    
    public func referencedValue(_ instance: Parent) -> Handler.Value {
        handler.referencedValue(instance)
    }
}

extension Transient : ReadableWrapper {

    public var readOperation: ReadOperation {
        Read{ bytes, reader, symbol in
            // ignore the result for transient properties
            if let new = try self.handler.read(symbol, from: bytes, with: reader) {
                self.wrappedValue = new
            }
        }
    }
    
    public var byteSize: Int {
        return wrappedValue.byteSize
    }
    
    public func debugLayout(_ level: Int = 0) -> String {
        wrappedValue.debugLayout(level+1)
    }
    
    
}
