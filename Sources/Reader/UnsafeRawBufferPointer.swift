
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

extension UnsafeRawBufferPointer {
    
    public func read<I: FixedWidthInteger>(_ offset: inout Int, byteSwapped : Bool = false) throws -> I {
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset < self.count else {
            throw ParserError.invalidMemoryAddress
        }
        
        /// access the memory
        guard let val = self.baseAddress?.advanced(by: offset).assumingMemoryBound(to: I.self).pointee else {
            throw ParserError.incompatibleDataFormat
        }
        
        /// move the pointer
        offset += MemoryLayout<I>.size
        /// return the requested value
        return byteSwapped ? val.byteSwapped : val
    }
    
    public func read<I: FixedWidthInteger>(_ offset: inout Int, as: I.Type, byteSwapped : Bool = false) throws -> I {
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset < self.count else {
            throw ParserError.invalidMemoryAddress
        }
        
        /// access the memory
        guard let val = self.baseAddress?.advanced(by: offset).assumingMemoryBound(to: I.self).pointee else {
            throw ParserError.incompatibleDataFormat
        }
        
        /// move the pointer
        offset += MemoryLayout<I>.size
        /// return the requested value
        return byteSwapped ? val.byteSwapped : val
    }

}
    
// MARK:- String
extension UnsafeRawBufferPointer {
    
    public func read(_ offset: inout Int) throws -> String {
    
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset < self.count else {
            throw ParserError.invalidMemoryAddress
        }
        
        guard let chars = self.baseAddress?.advanced(by: offset).assumingMemoryBound(to: CChar.self) else {
            throw ParserError.missalignedData
        }
        let string = String(cString: chars)
        
        // move the pointer beyond the null but not beyond the bounds
        offset += Swift.min(string.count + 1, self.count)
        return string
        
    }
    
    public func read(_ offset: inout Int, len: Int? = nil, encoding: String.Encoding = .utf8) throws -> String {
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset < self.count else {
            throw ParserError.invalidMemoryAddress
        }
        
        guard let chars = self.baseAddress?.advanced(by: offset).assumingMemoryBound(to: UInt8.self), let string = String(data: Data(bytes: chars, count: len ?? self.count - offset), encoding: encoding) else {
            throw ParserError.incompatibleDataFormat
        }
        
        // move the pointer beyond the null but not beyond the bounds
        offset += len ?? (count - offset)
        return string
        
    }
}

//MARK:- Enum / RawRepresentable
extension UnsafeRawBufferPointer {
    
    public func read<Raw: RawRepresentable>(_ offset: inout Int) throws -> Raw? {
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset < self.count else {
            throw ParserError.invalidMemoryAddress
        }
        
        guard let raw = self.baseAddress?.advanced(by: offset).assumingMemoryBound(to: Raw.RawValue.self).pointee else {
            throw ParserError.missalignedData
        }
        
        guard let value = Raw(rawValue: raw) else {
            throw ParserError.incompatibleDataFormat
        }
        
        // move the pointer beyond the null but not beyond the bounds
        offset += MemoryLayout<Raw.RawValue>.size
        return value
        
    }
    
    public func read<Raw: RawRepresentable>(_ offset: inout Int, _ byteSwapped : Bool = false) throws -> Raw? where Raw.RawValue : FixedWidthInteger {
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset < self.count else {
            throw ParserError.invalidMemoryAddress
        }
        
        guard let raw = self.baseAddress?.advanced(by: offset).assumingMemoryBound(to: Raw.RawValue.self).pointee else {
            throw ParserError.missalignedData
        }
        
        guard let value = Raw(rawValue: byteSwapped ? raw.byteSwapped : raw) else {
            throw ParserError.incompatibleDataFormat
        }
        
        // move the pointer beyond the null but not beyond the bounds
        offset += MemoryLayout<Raw.RawValue>.size
        return value
        
    }
}

