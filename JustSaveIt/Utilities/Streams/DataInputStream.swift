
import Foundation

class DataInputStream {
    public static let DEFAULT_BUFFER_SIZE = DataSize(KB: 1)
    
    let stream: InputStream
    
    private (set) var position: Int = 0
    
    private var isOpen: Bool = false
    
    init(ofData data: Data) {
        self.stream = InputStream(data: data)
    }
    
    init(ofFileURL url: URL) throws {
        guard let stream = InputStream(url: url) else {
            throw DataInputStreamError.badURL
        }
        
        self.stream = stream
    }
    
    deinit {
        close()
    }
    
    var isAtEOF: Bool {
        return self.stream.streamStatus == .atEnd
    }
    
    func open() {
        if !self.isOpen {
            self.stream.open()
            
            self.isOpen = true
        }
    }
    
    func close() {
        if self.isOpen {
            self.stream.close()
            
            self.isOpen = false
        }
    }
    
    // Reads a chunk of the specified @size from the stream.
    // The contents of the stream are returned, if they are smaller than the specified @size.
    func read(bufferOfSize size: DataSize) throws -> Data {
        if size.isZero {
            return Data()
        }
        
        var data = Data()

        let bufferSize = Int(size.inBytes)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        
        open()
        
        defer {
            buffer.deallocate()
        }
        
        let result = self.stream.read(buffer, maxLength: bufferSize)
        
        if result < 0 {
            throw self.stream.streamError ?? DataInputStreamError.unknown
        } else if result == 0 {
            // EOF
            close()
        } else {
            self.position += result
            
            data.append(buffer, count: result)
        }
        
        return data
    }
    
    // Stream is always closed once operation finishes.
    func readAll(maxSize: DataSize) throws -> Data {
        if maxSize.isZero {
            close()
            return Data()
        }
        
        var data = Data()
        
        let maxSizeInBytes = Int(maxSize.inBytes)
        let defaultBufferSize = Int(DataInputStream.DEFAULT_BUFFER_SIZE.inBytes)
        let bufferSize = maxSizeInBytes > defaultBufferSize ? defaultBufferSize : maxSizeInBytes
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        
        open()
        
        defer {
            close()
            buffer.deallocate()
        }
        
        while true {
            var maxLength = bufferSize
            
            if data.count + maxLength > maxSizeInBytes {
                maxLength = maxSizeInBytes - data.count
            }
            
            let result = self.stream.read(buffer, maxLength: maxLength)
            
            if result < 0 {
                throw self.stream.streamError ?? DataInputStreamError.unknown
            } else if result == 0 {
                // EOF
                break
            } else {
                self.position += result
                
                data.append(buffer, count: result)
            }
        }
        
        return data
    }
    
    func skip(to position: Int) throws {
        var bytesToSkip = position
        
        if bytesToSkip == 0 {
            return
        }
        
        let bufferSize = Int(DataInputStream.DEFAULT_BUFFER_SIZE.inBytes)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        
        open()
        
        defer {
            buffer.deallocate()
        }
        
        while bytesToSkip > 0 {
            var result: Int = 0
            
            if bytesToSkip >= bufferSize {
                result = self.stream.read(buffer, maxLength: bufferSize)
            } else {
                result = self.stream.read(buffer, maxLength: bytesToSkip)
            }
            
            if result < 0 {
                throw self.stream.streamError ?? DataInputStreamError.unknown
            } else if result == 0 {
                // EOF
                break
            } else {
                self.position += result
                
                bytesToSkip -= result
            }
        }
    }
}
