/*
 
 Copyright (c) <2020>
 
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

public struct OptionalReferencedProperty<Parent: AnyReadable, Meta: Equatable, Value: AnyReadable> : PropertyHandler {
    
    var reference : KeyPath<Parent,Meta>
    var condition : Meta
    
    public func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, with reader: FileReader) throws -> Value? {
        
        if reader.seek(for: reference) == condition {
            
            // read the value
            let value : Value? = try reader.parse(bytes, symbol)
            // store in context to access later
            reader.head?.transients[reference] = value
            
            return value
        } else {
            return nil
        }
    }
}


extension Transient where Meta: Equatable, Handler == OptionalReferencedProperty<Parent, Meta, Value> {

    
    convenience public init(wrappedValue initialValue: Value, _ reference: KeyPath<Parent,Meta>, equals: Meta){
        
        self.init(wrappedValue: initialValue, OptionalReferencedProperty(reference: reference, condition: equals))
    }
}
