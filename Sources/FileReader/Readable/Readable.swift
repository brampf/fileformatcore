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

/**
 Marker protocol for a struct or object which can (and shall) be read by the parser
 */
public protocol Readable : AnyReadable, CustomDebugStringConvertible {
    
    mutating func read(_ data: UnsafeRawBufferPointer, context: inout Context, _ symbol: String?) throws
    
    var byteSize : Int {get}
}

extension Readable {
    
    public var byteSize : Int {
        let mirror = Mirror(reflecting: self)
        
        return recursiveBytes(mirror)
    }
    
    private func recursiveBytes(_ mirror: Mirror) -> Int {
        
        // memory size of this reflectabel
        let size = mirror.children.reduce(into: 0){ size, child in
            if let mem = child.value as? Readable {
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
    
    /// method to actually fill the readable properties
    public mutating func read(_ data: UnsafeRawBufferPointer, context: inout Context, _ symbol: String? = nil) throws {
        
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
            if var mem = child.value as? Readable {
                try mem.read(data, context: &context, child.label)
            }
        }
    }
    
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
            if let mem = child.value as? Readable {
                out[child.label ?? "N/A"] = String(describing: mem)
            }
        }
    }
}

extension Readable {
    
    public static func read(_ data: UnsafeRawBufferPointer, context: inout Context) throws -> AnyReadable? {
        
        // only read as long as the offset hasn't reached EOF
        guard context.offset < data.count else {
            return nil
        }
        
        // fetch next node and expected size
        let next = try context.next(data)
            
        // check if there is a next node to parse
        guard let node = next.new else {
            return nil
        }
        
        #if PARSER_TRACE
        let padSize = max(5,String(describing: data.count).count)
        let startOffset = String(describing: context.offset).padding(toLength: padSize, withPad: " ", startingAt: 0)
        let endOffset = (next.upperBound == nil ? "???" : String(context.offset + next.upperBound!)).padding(toLength: padSize, withPad: " ", startingAt: 0)
        let symbol = "\(node.debugSymbol)".padding(toLength: 12, withPad: " ", startingAt: 0)
        let type = "\(Swift.type(of: node))".padding(toLength: 12, withPad: " ", startingAt: 0)
        
        print("\n[\(startOffset)..<\(endOffset)] \(symbol) : \(type)")
        #endif
        
        // push the next node on the stack
        context.push(node, size: next.upperBound )
        
        // read the nodes values
        if var custom = node as? CustomReadable {
            // use the typed reading function instead of the supertype
            try custom.readManually(data, context: &context)
        } else if var readable = node as? Readable {
            // default reading function of all other boxes
            try readable.read(data, context: &context, node.debugSymbol)
        }
        
        // pop the last element from the stack
        return try context.pop()
    }
}

// MARK:- CustomDebugStringConvertible
extension Readable  {
    
    public var debugDescription: String {
        var ret = "\n--- \(type(of: self)) ---------------------------- Size: \(byteSize) ---"
        dump.forEach{ field in
            ret += "\n\(field.key.padding(toLength: 12, withPad: " ", startingAt: 0)): \(field.value)"
        }
        return ret
    }
    
    public var debugLayout : String {
        
        self.debugLayout(0)
    }
    
    func debugLayout(_ level: Int = 0) -> String {
        var ret = String(repeating: " ", count: level)+"⎿"+" \(self.debugSymbol) (\(Self.self)) [\(self.byteSize) bytes]"
        
        let mirror = Mirror(reflecting: self)
        mirror.children.forEach{ child in
            if let mem = child.value as? Readable {
                ret += "\n"
                ret += mem.debugLayout(level+1)
            }
            if let mem = child.value as? [Readable] {
                mem.forEach{ readable in
                    ret += "\n"
                    ret += readable.debugLayout(level+1)
                }
            }
        }
        return ret
    }
    
}

extension Sequence where Element : AnyReadable {
    
    var byteSize : Int {
        self.reduce(into: 0, {$0 += $1.byteSize})
    }
    
}


