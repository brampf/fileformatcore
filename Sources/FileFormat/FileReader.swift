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

public class FileReader {
    
    private var rawData : UnsafeRawBufferPointer
    public var config : FileConfiguration
    
    /// global byte offset
    public internal(set) var offset : Int = 0

    public internal(set) var frameBound : Int? = nil
    
    public var upperBound : Int {
        frameBound ?? rawData.count
    }
    
    /// Handler for providing parser output
    var notify: ((Output) -> Void)?

    var stack : [FileReaderContext] = []
    
    public init(data: UnsafeRawBufferPointer, configuration: FileConfiguration){
        self.rawData = data
        self.config = configuration
    }
    
    public init(data: ContiguousBytes){
        self.rawData = data.withUnsafeBytes{ ptr in
            return ptr
        }
        self.config = DefaultConfiguraiton()
    }
    
}

//MARK:- Frames
extension FileReader {
    
    /// Reads the `FrameLiteral` and moves the offset
    public func read<R>(_ operation: ReadOperation<R>) rethrows -> R {
        return try operation(self)
    }
    
    public func read<R: Readable>() throws -> R {
        
        return try R(self)
    }
    
    public func advance(bytes: Int) {
        self.offset += bytes
    }
}

//MARK:- FixedWidthInteger
extension FileReader {
    
    public func seek<F: FixedWidthInteger>() throws -> F {
        
        if config.bigEndian {
            return self.rawData.baseAddress!.advanced(by: self.offset).assumingMemoryBound(to: F.self).pointee.bigEndian
        } else {
            return self.rawData.baseAddress!.advanced(by: self.offset).assumingMemoryBound(to: F.self).pointee.littleEndian
        }
        
    }
    
    public func read<F: FixedWidthInteger>(fromByteOffset: Int) throws -> F {
        self.advance(bytes: MemoryLayout<F>.size+offset)
        return try self.seek(fromByteOffset: fromByteOffset)
    }
    
    public func seek<F: FixedWidthInteger>(fromByteOffset: Int) throws -> F {
        
        if config.bigEndian {
            return self.rawData.load(fromByteOffset: self.offset+fromByteOffset, as: F.self).bigEndian
        } else {
            return self.rawData.load(fromByteOffset: self.offset+fromByteOffset, as: F.self).littleEndian
        }
        
    }
    
}

// Mark:- Arrays
extension FileReader {
    
    public func read<R: Readable>(upperBound: Int) throws -> [R] {
        
        var result : [R] = []
        
        while offset < upperBound {
            let new : R = try self.read()
            result.append(new)
        }
        return result
    }
    
    public func read<F: Frame>(_ operation: ReadOperation<F>, upperBound: Int) throws -> [F] {
        
        var result : [F] = []
        
        while offset < upperBound {
            let new : F = try self.read(operation)
            result.append(new)
        }
        return result
    }
    
    public func read<R: Readable>(length: Int) throws -> [R] {
        
        var result : [R] = []
        
        while result.count < length {
            let new : R = try self.read()
            result.append(new)
        }
        return result
    }
    
    public func read<F: Frame>(_ operation: ReadOperation<F>, length: Int) throws -> [F] {
        
        var result : [F] = []
        
        while result.count < length {
            let new : F = try self.read(operation)
            result.append(new)
        }
        return result
    }
}

// Mark:- String {

extension FileReader {
    
    public func read(_ encoding: String.Encoding = .utf8) throws -> String {
        
        try self.read(upperBound: self.upperBound)
    }
    
    public func read(_ encoding: String.Encoding = .utf8, upperBound: Int) throws -> String {
        
        let bytes = Data(rawData[self.offset..<upperBound])
        let new = String(data: bytes, encoding: encoding)
        
        self.advance(bytes: bytes.count)
        return new ?? ""
    }
    
    public func read(length: Int) throws -> String {
        
        return try self.read(.utf8, upperBound: self.offset+length)
    }
    
    public func read(terminating: Character) throws -> String {
        
        let new = String(cString: rawData.baseAddress!.advanced(by: self.offset).assumingMemoryBound(to: CChar.self) , encoding: .utf8) ?? ""
        
        self.advance(bytes: new.count)
        return new
    }
}
