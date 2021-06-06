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

public final class FileReader : Context {
    
    public var config : FileConfiguration
    
    /// Node Stack
    var stack : [LocalContext] = []
    /// Stack of transient values
    var transients : [UUID: Any] = [:]
    
    /// reader position in the raw data
    public var offset: Int = 0
    
    public var bigEndian: Bool {
        return config.bigEndian
    }
    
    public var notify: ((Output) -> Void)? = nil
    
    public required init(using configuration: FileConfiguration, out: ((Output) -> Void)? = nil){
        self.config = configuration
        self.notify = out
        
    }
    
    // creates a nw local context for a new element and pushes it on the stack
    public final func push(_ node: AnyReadable){

        stack.append(.init(node, offset, head?.endOffset))
    }
    
    public final func pop() throws -> AnyReadable? {
        
        if let element = stack.popLast(){
            
            if let end = element.endOffset {
                
                // end was expected
                
                if offset < end {
                    
                    // offset before expected end - that is recoverable
                    if !config.ignoreRecoverableErrors {
                        // throw error as we are missing data
                        throw ReaderError.missalignedData(ErrorStack(nil, type(of: element.readable), offset), end)
                        
                    } else {
                        notify?(Warning("Offset \(offset) too small", element.startOffset, element.endOffset, node: type(of: element.readable)))
                        print("WARN: Offset \(offset) < \(end) on \(type(of: element.readable))")
                        // move offset to expected end of box
                        //offset = end
                    }
                }
                
                if offset > end {
                    // offset behind expected end - that is never good
                    throw ReaderError.missalignedData(ErrorStack(nil, type(of: element.readable), offset), end)
                }
                
            } else {
                // no end was expected, so just keep the offset where it is
            }

            return element.readable
        } else {
            return nil
        }
    }

    public var root : LocalContext? {
        return stack.first
    }
    
    public var head : LocalContext? {
        get {
            return stack.last
        }
        set {
            stack.removeLast()
            if let new = newValue {
                stack.append(new)
            }
        }
    }
    
    public var parent : LocalContext? {
        return stack.count > 1 ? stack[stack.count-2] : nil
        
    }
    
    /// seeks for a specific, previously read value in the file hierachy by looking for the first match for the `Root.Type` from top to down of the reader stack
    public func seek<Root: AnyReadable,Value>(for path: KeyPath<Root,Value>) -> Value? {
        
        for idx in stride(from: stack.count-1, through: 0, by: -1) {
            if let root = stack[idx].readable as? Root {
                
                // First try to find as transient
                if let val = stack[idx].transients[path] as? Value {
                    return val
                } else {
                    return root[keyPath: path]
                }
            }
        }
        return nil
    }
    
    /// stored the provided value as transient
    public func transientStore<Root: AnyReadable,Value>(for path: KeyPath<Root,Value>) -> Value? {
        
        for idx in stride(from: stack.count-1, through: 0, by: -1) {
            
            if let root = stack[idx].readable as? Root {
                
                return root[keyPath: path]
            }
        }
        return nil
    }
    
    public func lookup<Root, Value>(path: KeyPath<Root,Value>) -> Value? {
        
        for idx in stride(from: stack.count-1, through: 0, by: -1) {
            
            if stack[idx].readable is Root {
                
                return stack[idx].transients[path] as? Value
            }
        }
        // not found
        return nil
    }
    
    public subscript<V>(dynamicMember member: String) -> V {
        
        let mirror = Mirror(reflecting: config)
        let child = mirror.children.first(where: {$0.label == member})
        if let value = child?.value as? V {
            return value
        }
        fatalError("\(type(of: FileConfiguration.self)).\(member) not found")
    }
    
    
}

extension FileReader {
    
     convenience init(out: ((Output) -> Void)? = nil){
        self.init(using: DefaultConfiguration(), out: out)
    }
}

extension FileReader : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return stack.reduce(into: "OFFSET \(offset)\n") { out, context in
            out.append(context.debugDescription+"\n")
        }
    }
    
}

//MARK:- Parser Implementation
extension FileReader {
    
    public func parse<Result : AnyReadable>(_ bytes: UnsafeRawBufferPointer, _ symbol: String? = nil) throws -> Result? {
        
        // Hack until proper solutio in sight
        var context = self
        
        #if PARSER_TRACE
        let offset = String(self.offset).padding(toLength: 13, withPad: " ", startingAt: 0)
        let symbol = "\(symbol ?? "???")".padding(toLength: 12, withPad: " ", startingAt: 0)
        let typ = "\(String(describing: Self.self))".padding(toLength: 12, withPad: " ", startingAt: 0)
        
        print("[\(offset)] READ \(symbol) : \(typ)")
        #endif
        
        // create new instance
        guard var new = try Result.new(bytes, with: &context, symbol) else {
            return nil
        }
        
        // push this element onto the stack
        self.push(new)
        
        // read all readable values of this element
        try new.read(bytes, with: self, symbol)
        //try parseProperties(of: new, bytes, symbol)
        
        // pop the stack
        let closing = try self.pop()
        
        // check that we popped the correct element
        guard closing is Result else {
            // if not, continuing makes no sense as we don't know where we acutally are
            throw ReaderError.internalError(ErrorStack(nil, Result.self, self.offset), "Closing the wrong Element")
        }
        
        // return new freshly read element
        return new
    }
    
    public func parseProperties<Frame>(of frame: Frame, _ bytes: UnsafeRawBufferPointer, _ symbol: String?) throws {
        
        let mirror = Mirror(reflecting: frame)
        return try parseRecursive(mirror, from: bytes, symbol)
    }
    
    private func parseRecursive(_ mirror: Mirror, from bytes: UnsafeRawBufferPointer, _ symbol: String?) throws {
        
        // read super readable first
        if let sup = mirror.superclassMirror {
            try parseRecursive(sup, from: bytes, symbol)
        }
        
        // read this readable
        try mirror.children.forEach{ child in
            if let wrapper = child.value as? ReadableWrapper {
                try wrapper.readOperation.read(from: bytes, with: self, child.label)
            }
        }
    }
}
