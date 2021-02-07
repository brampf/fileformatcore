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

public class AnyTransient<Parent: AnyReadable> {
    
    var instance : Parent!
}

/**
 A property who's value is read and thus can be used as counter or condition in other property wrappers but who's value is computed at runtime
 */
@propertyWrapper public final class Transient<Parent: AnyReadable, Value: AnyReadable> : AnyTransient<Parent> {
    
    var bound : KeyPath<Parent,Value>
    
    public var wrappedValue: Value
    
    public init(wrappedValue: Value, _ bound: KeyPath<Parent,Value>){
        self.bound = bound
        self.wrappedValue = wrappedValue
    }
}

extension Transient : ReadableWrapper {

    public func read<C: Context>(_ bytes: UnsafeRawBufferPointer, context: inout C, _ symbol: String? = nil) throws {
        
        let value = try Value.read(bytes, with: &context)
        // store in context to access later
        context.head?.transients[bound] = value
    }
    
    public var byteSize: Int {
        return wrappedValue.byteSize
    }
    
    public func debugLayout(_ level: Int = 0) -> String {
        wrappedValue.debugLayout(level+1)
    }
    
    
}
