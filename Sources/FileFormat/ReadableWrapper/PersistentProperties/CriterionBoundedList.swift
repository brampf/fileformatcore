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

public struct CriterionBoundedList<Parent: BaseFile, R: AnyReadable, Criterion: Equatable> : PersistentProperty {
    
    public typealias Value = [R]
    
    public var bound : KeyPath<Parent,Criterion>
    public var criterion : Criterion
    
    public func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, with reader: FileReader) throws -> Value? {
        
        /// reset local index counter
        reader.head?.index = 0
        
        var new : [R] = .init()
        
        let parent = reader.root?.readable as? Parent
        repeat {
            if let next : R = try reader.parse(bytes, symbol) {
                new.append(next)
            }
            
            reader.head?.index += 1
            
        } while reader.offset < (reader.head?.endOffset ?? bytes.endIndex) && parent != nil && parent![keyPath: bound] != criterion
         
        reader.head?.index = 0
        
        return new
    }
}

extension Persistent where Parent : AnyReadable, Meta: Equatable, Property == CriterionBoundedList<Parent, Value, Meta> {
    
    convenience public init(wrappedValue initialValue: Property.Value, _ path: KeyPath<Parent, Meta>, equals criterion: Meta) {
        self.init(wrappedValue: initialValue, CriterionBoundedList(bound: path, criterion: criterion))
    }
}
