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

public protocol ReadableAutoFrame : ReadableFrame {
    
}

extension ReadableAutoFrame {
    
    public var byteSize : Int {
        let mirror = Mirror(reflecting: self)
        
        return recursiveBytes(mirror)
    }
    
    private func recursiveBytes(_ mirror: Mirror) -> Int {
        
        // memory size of this frame
        let size = mirror.children.reduce(into: 0){ size, child in
            if let mem = child.value as? ReadableElement {
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

extension ReadableAutoFrame {
    
    /// method to actually fill the readable properties
    public mutating func read(_ data: UnsafeRawBufferPointer, context: inout Context) throws {
        
        let mirror = Mirror(reflecting: self)
        
        try recursiveRead(mirror, from: data, context: &context)
    }
    
    private func recursiveRead(_ mirror: Mirror, from data: UnsafeRawBufferPointer, context: inout Context) throws {
        
        // read super readable first
        if let sup = mirror.superclassMirror {
            try recursiveRead(sup, from: data, context: &context)
        }
        
        // read this readable
        try mirror.children.forEach{ child in
            if var wrapper = child.value as? ReadableWrapper {
                try wrapper.read(child.label, from: data, in: &context)
            }
        }
    }
    
}

extension ReadableAutoFrame {
    
    /// By default, the frame size is unknown
    public static func size(_ data: UnsafeRawBufferPointer, with context: inout Context) -> Int? {
        
        nil
    }
    
}

