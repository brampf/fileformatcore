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


public protocol ReadableElement : CustomDebugStringConvertible {
    
    static func new(_ bytes: UnsafeRawBufferPointer, with context: inout Context, _ name: String?) throws -> Self?
    
    var byteSize : Int {get}
    
    func debugLayout(_ level: Int) -> String
}

extension Optional : ReadableElement where Wrapped : ReadableElement {
    
    public static func new(_ bytes: UnsafeRawBufferPointer, with context: inout Context, _ name: String?) throws -> Self? {
        
        if let value : Wrapped = try? Wrapped.new(bytes, with: &context, name) {
            return value
        } else {
            return nil
        }
    }

    public var byteSize: Int {
        self?.byteSize ?? 0
    }
    
    public func debugLayout(_ level: Int = 0) -> String {
        if let me = self {
            return me.debugLayout(level)
        } else {
            return String(repeating: " ", count: level)+"⎿"+" (\(Self.self)) [\(self.byteSize) bytes]"
        }
    }
}

extension ReadableElement {
    
    var dump : [String : String] {
        
        let mirror = Mirror(reflecting: self)
        var out = [String : String]()
        
        dumpRecursive(mirror, &out)
        
        return out
    }
    
    func dumpRecursive(_ mirror : Mirror, _ out: inout [String : String]) {
        
        // read super box first
        if let sup = mirror.superclassMirror {
            dumpRecursive(sup, &out)
        }
        
        // read this box
        mirror.children.forEach{ child in
            if let mem = child.value as? ReadableElement {
                out[child.label ?? "N/A"] = String(describing: mem)
            }
        }
    }
    
    public var debugDescription: String {
        var ret = "\n--- \(type(of: self)) ---------------------------- Size: \(byteSize) ---"
        dump.forEach{ field in
            ret += "\n\(field.key.padding(toLength: 12, withPad: " ", startingAt: 0)): \(field.value)"
        }
        return ret
    }
    
    public var debugLayout : String {
        return self.debugLayout(0)
    }
    
    public func debugLayout(_ level: Int = 0) -> String {
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

