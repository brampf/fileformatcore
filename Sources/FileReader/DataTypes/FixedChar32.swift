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

public typealias FixedChar8 = UInt8
public typealias FixedChar16 = UInt16
public typealias FixedChar32 = UInt32
public typealias FixedChar64 = UInt64

extension FixedWidthInteger {
    
    public init?(_ from: String, encoding: String.Encoding = .utf8){
        
        if let v = from.data(using: encoding)?.withUnsafeBytes({ ptr in
            ptr.load(as: Self.self)
        }){
            self.init(v)
        } else {
            return nil
        }
    }
    
    func string(_ encoding: String.Encoding = .utf8) -> String? {
        var me = self
        let data = Data(bytes: &me, count: MemoryLayout<Self>.size)
        return String(data: data, encoding: encoding)
    }
}

extension Array where Element : FixedWidthInteger {
    
    public func string(_ encoding: String.Encoding = .utf8) -> String? {
        var me = self
        let data = Data(bytes: &me, count: self.count * MemoryLayout<Element>.size)
        return String(data: data, encoding: encoding)
    }
    
}
