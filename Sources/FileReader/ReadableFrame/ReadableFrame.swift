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

/// A `ReadableElement` with a default implementation to read all properties wrapped as `ReadableWrapper` and
public protocol ReadableFrame : ReadableElement {
    
    /// defaut initializer used to create new instances
    init()
    
}

//MARK:- Default implementation of ReadableElement
extension ReadableFrame {
    
    /// in frames
    public static func new() -> Self {
        return Self.init()
    }
    
    /// In Frames, the factory methos always returns a new instance of Self by calling the default initializer
    /// in Frames, the size in bytes is initially unbound unless this method is implemtend differentyl
    public static func next<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: C, _ symbol: String?) throws -> (element: ReadableElement.Type?, size: Int?) {
        
        return (Self.self, nil)
    }
    
    /// In Frames, the size in bytes is the sum of the the children stored in `ReadableWrappers`
    public var byteSize : Int {
        let mirror = Mirror(reflecting: self)
        
        return recursiveBytes(mirror)
    }
    
    private func recursiveBytes(_ mirror: Mirror) -> Int {
        
        // memory size of this frame
        let size = mirror.children.reduce(into: 0){ size, child in
            if let mem = child.value as? ReadableWrapper {
                size += mem.byteSize
            }
        }
        
        // traverse through class hierarchie
        if let sup = mirror.superclassMirror {
            return size + recursiveBytes(sup)
        } else {
            return size
        }
        
    }
    
}

extension ReadableFrame {
    
    public  mutating func read<C: Context>(_ bytes: UnsafeRawBufferPointer, context: inout C, _ symbol: String?) throws {
        
        let mirror = Mirror(reflecting: self)
        try recursiveRead(mirror, from: bytes, context: &context)
    }
    
    private func recursiveRead<C: Context>(_ mirror: Mirror, from bytes: UnsafeRawBufferPointer, context: inout C) throws {
        
        // read super readable first
        if let sup = mirror.superclassMirror {
            try recursiveRead(sup, from: bytes, context: &context)
        }
        
        // read this readable
        try mirror.children.forEach{ child in
            if var wrapper = child.value as? ReadableWrapper {
                try wrapper.read(bytes, context: &context, child.label)
            }
        }
    }
    
}
