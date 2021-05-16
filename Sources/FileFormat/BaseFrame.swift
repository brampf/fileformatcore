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

public protocol BaseFrame : Frame {
    
}


extension BaseFrame {
    
    /**
     Reads a `BaseFile` from the bytes provided
     
     - Parameters:
     -  data: the raw data to read from
     -  configuration: the `FileConfiguraiton`to use
     -  out: the output handler to use
     
     */
    public static func read(from data: ContiguousBytes, with configuration: FileConfiguration, out: ((Output) -> ())? = nil) throws -> Self? {
        
        return try data.withUnsafeBytes { ptr in
            let reader = FileReader(data: ptr, configuration: configuration)
            return try reader.read()
        }
        
    }
    
    /**
     Reads ta `BaseFile` from the url provided
     
     - Parameters:
     -  url: the file ULR to read the raw data from
     -  configuration: the `FileConfiguraiton`to use
     -  out: the output handler to use
     
     */
    public static func read(from url: URL, with configuration: FileConfiguration, out: ((Output) -> ())? = nil) throws -> Self? {
        
        let data = try Data(contentsOf: url)
        
        return try data.withUnsafeBytes { ptr in
            let reader = FileReader(data: ptr, configuration: configuration)
            return try reader.read()
        }
        
    }
    
}
