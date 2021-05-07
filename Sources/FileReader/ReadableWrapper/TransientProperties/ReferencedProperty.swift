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


public struct ReferencedProperty<Parent: AnyReadable, Value : AnyReadable> : PropertyHandler {
    
    var reference : KeyPath<Parent,Value>
    
    public func read<C>(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout C) throws -> Value? where C : Context {
     
        // read the value
        let value = try Value.read(bytes, with: &context, symbol)
        // store in context to access later
        context.head?.transients[reference] = value
        
        return value
    }
}


extension Transient where Handler == ReferencedProperty<Parent, Value>, Meta == Void {
    
    convenience public init(wrappedValue initialValue: Handler.Value, _ reference: KeyPath<Parent,Value>){
        
        self.init(wrappedValue: initialValue, ReferencedProperty(reference: reference))
    }
}

extension Transient where Handler == ReferencedProperty<Parent, Value>, Meta == Void, Value: AutoReadable {
    
    convenience public init(_ reference: KeyPath<Parent,Value>){
        
        self.init(ReferencedProperty(reference: reference))
    }
}
