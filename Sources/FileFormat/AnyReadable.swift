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

public protocol AnyReadable {
    
    /// crate a new Instance and initialize with default values without moving the offset
    static func new<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?) throws -> Self?
    
    
    /// reads the content of the frame
    mutating func read(_ bytes: UnsafeRawBufferPointer, with reader: FileReader, _ symbol: String?) throws
    
    /// size of this readable in bytes
    @available(*, deprecated, message: "FALSE!")
    var byteSize : Int { get }
    
    
    /// returns as textual tree representation of  this `Readable` and its children
    var debugLayout : String { get }
}

extension AnyReadable {

    static func read<C: Context>(from data: ContiguousBytes, with context: inout C) throws -> Self? {
    
        return try data.withUnsafeBytes { ptr in
            try context.parse(ptr, "\(type(of: self))")
        }
        
    }
    
}

//MARK:- Debug Representations
extension AnyReadable {
    
    public var debugLayout : String {
        return self.debugLayout(0)
    }
    
    func debugLayout(_ level: Int = 0) -> String {
        var ret = String(repeating: " ", count: level)+"⎿"+" (\(Self.self)) [\(self.byteSize) bytes]"
        
        let mirror = Mirror(reflecting: self)
        mirror.children.forEach{ child in
            
            if let mem = child.value as? ReadableWrapper {
                ret += "\n"
                ret += mem.debugLayout(level+1)
            }
        }
        return ret
    }
}
