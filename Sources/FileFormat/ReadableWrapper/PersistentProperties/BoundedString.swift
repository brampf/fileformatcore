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

public struct BoundedString<Parent: AnyReadable, F: FixedWidthInteger & AnyReadable> : PersistentProperty {
    
    public typealias Value = String
    
    public enum StringType {
        case utf8
        case utf16
        case cstring
    }
    
    public var bound : KeyPath<Parent,ReadableWrapper>?
    public var type : StringType
    
    public init(bound: KeyPath<Parent,ReadableWrapper>? = nil, type: StringType){
        self.bound = bound
        self.type = type
    }
    
    public func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, with reader: FileReader) throws -> Value? {

        switch type {
        case .cstring:
            return try bytes.read(&reader.offset, upperBound: reader.head?.endOffset ?? bytes.count, symbol)

        default:
            return try bytes.read(&reader.offset, len: reader.head?.endOffset ?? bytes.count, symbol)
        }
        
    }
    
}

extension Persistent where Parent == EmptyReadable, Value == String, Meta == UInt8, Property == BoundedString<Parent, Meta> {
    
    
    convenience public init(wrappedValue initialValue: Property.Value, _ type: BoundedString<Parent,Meta>.StringType = .utf8) {
        
        self.init(wrappedValue : initialValue, BoundedString(type: type))
    }
    
}


extension Persistent where Value == String, Property == BoundedString<Parent, Meta> {
    
    
    convenience public init(wrappedValue initialValue: Property.Value, _ path: KeyPath<Parent, ReadableWrapper>? = nil, _ type: BoundedString<Parent,Meta>.StringType = .utf8) {
        
        self.init(wrappedValue : initialValue, BoundedString(bound: path, type: type))
    }
    
}
