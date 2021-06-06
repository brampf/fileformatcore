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


public protocol AutoReadable : AnyReadable {
    
    init()
    
}

// default implementations
extension AutoReadable {
    
    public static func new<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?) throws -> Self? {
        Self()
    }
    
    public func read(_ bytes: UnsafeRawBufferPointer, with reader: FileReader, _ symbol: String?) throws {
        try reader.parseProperties(of: self, bytes, symbol)
    }
    
    public func readWrapper(_ bytes: UnsafeRawBufferPointer, _ reader: FileReader, _ symbol: String?) throws {
        
        let mirror = Mirror(reflecting: self)
        return try readWrapperRecursive(mirror, from: bytes, reader, symbol)
    }
    
    private func readWrapperRecursive(_ mirror: Mirror, from bytes: UnsafeRawBufferPointer, _ reader: FileReader, _ symbol: String?) throws {
        
        // read super readable first
        if let sup = mirror.superclassMirror {
            try readWrapperRecursive(sup, from: bytes, reader, symbol)
        }
        
        // read this readable
        try mirror.children.forEach{ child in
            if let wrapper = child.value as? ReadableWrapper {
                try wrapper.readOperation.read(from: bytes, with: reader, child.label)
            }
        }
    }
}


extension AutoReadable {
    
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
