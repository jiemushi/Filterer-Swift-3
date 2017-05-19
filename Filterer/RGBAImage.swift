import UIKit

public struct Pixel {
    public var value: UInt32
    
    public var red: UInt8 {
        get {
            return UInt8(value & 0xFF)
        }
        set {
            value = UInt32(newValue) | (value & 0xFFFFFF00)
        }
    }
    
    public var green: UInt8 {
        get {
            return UInt8((value >> 8) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
        }
    }
    
    public var blue: UInt8 {
        get {
            return UInt8((value >> 16) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
        }
    }
    
    public var alpha: UInt8 {
        get {
            return UInt8((value >> 24) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
        }
    }
}

public struct RGBAImage {
    public var pixels: [Pixel]
    
    public var width: Int
    public var height: Int
    
    var count: Int
    
    var totalRed = 0
    var totalGreen = 0
    var totalBlue = 0
    
    var avgRed:Int {
        get {
            return totalRed/count
        }
        set (newVal){
            avgRed = newVal
        }
    }
    var avgGreen:Int {
        get {
            return totalGreen/count
        }
        set (newVal){
            avgGreen = newVal
        }
    }
    var avgBlue:Int {
        get {
            return totalBlue/count
        }
        set (newVal){
            avgBlue = newVal
        }
    }
    
    public init?(image: UIImage) {
        guard let cgImage = image.cgImage else { return nil }
        
        // Redraw image for correct pixel format
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        width = Int(image.size.width)
        height = Int(image.size.height)
        let bytesPerRow = width * 4
        
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        imageContext.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let bufferPointer = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        pixels = Array(bufferPointer)
        
        imageData.deinitialize()
        imageData.deallocate(capacity: width * height)
        
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                var pixel = pixels[index]
                totalRed += Int((pixel.red))
                totalGreen += Int((pixel.green))
                totalBlue += Int((pixel.blue))
            }
        }
        
        count = width * height
        
    }
    
    public func toUIImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        let bytesPerRow = width * 4
        
        let imageDataReference = UnsafeMutablePointer<Pixel>(mutating: pixels)
        defer {
            imageDataReference.deinitialize()
        }
        let imageContext = CGContext(data: imageDataReference, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        
        guard let cgImage = imageContext?.makeImage() else {return nil}
        let image = UIImage(cgImage: cgImage)
        
        return image
    }
    
    /*private class colorChannel {
     private var val:String
     init(input:String) {
     self.val = input
     }
     }*/
    
    public enum ColorChannel: String {
        case R
        case G
        case B
        case RG
        case RB
        case GB
        case GR
        case BR
        case BG
        case RGB
        case RBG
        case GBR
        case GRB
        case BRG
        case BGR
    }
    
    public mutating func brightenify (_ manipulateValue:Int) {
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                var pixel = pixels[index]
                var diff = 0
                diff = Int(pixel.red) - avgRed
                if (diff > 0) {
                    pixel.red = UInt8(max(0,min(255,avgRed+diff*manipulateValue)))
                    pixels[index] = pixel
                }
                
                diff = Int(pixel.green) - avgGreen
                if (diff > 0) {
                    pixel.green = UInt8(max(0,min(255,avgGreen+diff*manipulateValue)))
                    pixels[index] = pixel
                }
                
                diff = Int(pixel.blue) - avgBlue
                if (diff > 0) {
                    pixel.blue = UInt8(max(0,min(255,avgBlue+diff*manipulateValue)))
                    pixels[index] = pixel
                }
            }
        }
    }
    
    public mutating func sepiafy (_ intensity:Double) {
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                var pixel = pixels[index]
                var diffR = 0
                var diffG = 0
                var diffB = 0
                
                let r = 0.393 * intensity
                let g = 0.769 * intensity
                let b = 0.189 * intensity
                
                let r1 = 0.349 * intensity
                let g1 = 0.686 * intensity
                let b1 = 0.168 * intensity
                
                let r2 = 0.272 * intensity
                let g2 = 0.543 * intensity
                let b2 = 0.131 * intensity
                
                var tone:Double = 0
                
                diffR = Int(pixel.red) - avgRed
                let nAvgRed = avgRed + diffR
                diffG = Int(pixel.green) - avgGreen
                let nAvgGreen = avgGreen + diffG
                diffB = Int(pixel.blue) - avgBlue
                let nAvgBlue = avgBlue + diffB
                
                tone = (Double(nAvgRed) * r) + (Double(nAvgGreen) * g) + (Double(nAvgBlue) * b)
                pixel.red = UInt8(max(0,min(255,tone)))
                
                tone = (Double(nAvgRed) * r1) + (Double(nAvgGreen) * g1) + (Double(nAvgBlue) * b1)
                pixel.green = UInt8(max(0,min(255,tone)))
                
                tone = (Double(nAvgRed) * r2) + (Double(nAvgGreen) * g2) + (Double(nAvgBlue) * b2)
                pixel.blue = UInt8(max(0,min(255,tone)))
                
                pixels[index] = pixel
            }
        }
    }
    
    public mutating func monochromify (_ intensity:Double) {
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                var pixel = pixels[index]
                
                let r = 0.299 * intensity
                let g = 0.587 * intensity
                let b = 0.114 * intensity
                
                var tone:Double = 0
                /*if (diffR > 0) {
                 tone = (Double(pixel.red) * r2) + (Double(pixel.green) * g2) + (Double(pixel.blue) * b2)
                 pixel.red = UInt8(max(0,min(255,tone)))
                 }
                 
                 if (diffG > 0) {
                 tone = (Double(pixel.red) * r2) + (Double(pixel.green) * g2) + (Double(pixel.blue) * b2)
                 pixel.green = UInt8(max(0,min(255,tone)))
                 }
                 
                 if (diffB > 0) {
                 tone = (Double(pixel.red) * r2) + (Double(pixel.green) * g2) + (Double(pixel.blue) * b2)
                 pixel.blue = UInt8(max(0,min(255,tone)))
                 }
                 
                 if (diffR > 0) {
                 tone = (Double(nAvgRed) * r2) + (Double(nAvgGreen) * g2) + (Double(nAvgBlue) * b2)
                 pixel.red = UInt8(max(0,min(255,tone)))
                 }
                 
                 if (diffG > 0) {
                 tone = (Double(nAvgRed) * r2) + (Double(nAvgGreen) * g2) + (Double(nAvgBlue) * b2)
                 pixel.green = UInt8(max(0,min(255,tone)))
                 }
                 
                 if (diffB > 0) {
                 tone = (Double(nAvgRed) * r2) + (Double(nAvgGreen) * g2) + (Double(nAvgBlue) * b2)
                 pixel.blue = UInt8(max(0,min(255,tone)))
                 }*/
                
                tone = (Double(pixel.red) * r) + (Double(pixel.green) * g) + (Double(pixel.blue) * b)
                pixel.red = UInt8(max(0,min(255,tone)))
                pixel.green = UInt8(max(0,min(255,tone)))
                pixel.blue = UInt8(max(0,min(255,tone)))
                
                pixels[index] = pixel
            }
        }
    }
    
    /*public mutating func blurrify (manipulateColor:ColorChannel, manipulateValue:Int) {
     for y in 0..<height {
     for x in 0..<width {
     let index = y * width + x
     var pixel = pixels[index]
     /*let redDiff = Int(pixel.red) - red
     let greenDiff = Int(pixel.green) - green
     let blueDiff = Int(pixel.blue) - blue
     if (redDiff >= 0) {
     pixel.red = UInt8(max(0,min(255,red+redDiff/2)))
     RGBA.pixels[index] = pixel
     }
     if (greenDiff >= 0) {
     pixel.green = UInt8(max(0,min(255,green+greenDiff/2)))
     RGBA.pixels[index] = pixel
     }
     if (blueDiff >= 0) {
     pixel.blue = UInt8(max(0,min(255,blue+blueDiff/2)))
     RGBA.pixels[index] = pixel
     }*/
     
     var index1 = (y-1)*width+(x-1)
     var index2 = (y-1)*width+x
     var index3 = (y-1)*width+(x+1)
     var index4 = (y+1)*width+(x-1)
     var index5 = (y+1)*width+x
     var index6 = (y+1)*width+(x+1)
     
     var pix = [Int]()
     pix.append([[pixel[index1],pixel[index2],pixel[index3]],
     [pixel[index-1],pixel[index],pixel[index+1]],
     [pixel[index6],pixel[index5],pixel[index6]]])
     
     var diff = 0
     diff = Int(pixel.red) - avgRed
     if (diff > 0) {
     pixel.red = UInt8(max(0,min(255,avgRed+diff/manipulateValue)))
     }
     diff = Int(pixel.green) - avgGreen
     if (diff > 0) {
     pixel.green = UInt8(max(0,min(255,avgGreen+diff/manipulateValue)))
     }
     diff = Int(pixel.blue) - avgBlue
     if (diff > 0) {
     pixel.blue = UInt8(max(0,min(255,avgBlue+diff/manipulateValue)))
     }
     pixels[index] = pixel
     }
     }
     }*/
    
    public mutating func negativify (_ intensity: Double) {
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                var pixel = pixels[index]
                
                var diff = 0
                
                diff = Int(pixel.red) - avgRed
                let r:Double = Double(avgRed+diff)*intensity
                pixel.red = UInt8(max(0,min(255,255-r)))
                
                diff = Int(pixel.green) - avgGreen
                let g:Double = Double(avgGreen+diff)*intensity
                pixel.green = UInt8(max(0,min(255,255-g)))
                
                diff = Int(pixel.blue) - avgBlue
                let b:Double = Double(avgBlue+diff)*intensity
                pixel.blue = UInt8(max(0,min(255,255-b)))
                
                pixels[index] = pixel
            }
        }
    }
    
    public mutating func softenify (_ manipulateValue:Int) {
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                var pixel = pixels[index]
                /*let redDiff = Int(pixel.red) - red
                 let greenDiff = Int(pixel.green) - green
                 let blueDiff = Int(pixel.blue) - blue
                 if (redDiff >= 0) {
                 pixel.red = UInt8(max(0,min(255,red+redDiff/2)))
                 RGBA.pixels[index] = pixel
                 }
                 if (greenDiff >= 0) {
                 pixel.green = UInt8(max(0,min(255,green+greenDiff/2)))
                 RGBA.pixels[index] = pixel
                 }
                 if (blueDiff >= 0) {
                 pixel.blue = UInt8(max(0,min(255,blue+blueDiff/2)))
                 RGBA.pixels[index] = pixel
                 }*/
                
                /*
                if (manipulateColor.rawValue.containsString("R")) {
                    diff = Int(pixel.red) - avgRed
                    if (diff > 0) {
                        pixel.red = UInt8(max(0,min(255,avgRed+diff/manipulateValue)))
                    }
                }
                if (manipulateColor.rawValue.containsString("G")) {
                    diff = Int(pixel.green) - avgGreen
                    if (diff > 0) {
                        pixel.green = UInt8(max(0,min(255,avgGreen+diff/manipulateValue)))
                    }
                }
                if (manipulateColor.rawValue.containsString("B")) {
                    diff = Int(pixel.blue) - avgBlue
                    if (diff > 0) {
                        pixel.blue = UInt8(max(0,min(255,avgBlue+diff/manipulateValue)))
                    }
                }
                 */
                
                var diff = 0
                
                diff = Int(pixel.red) - avgRed
                if (diff > 0) {
                    pixel.red = UInt8(max(0,min(255,avgRed+diff/manipulateValue)))
                }
        
                diff = Int(pixel.green) - avgGreen
                if (diff > 0) {
                    pixel.green = UInt8(max(0,min(255,avgGreen+diff/manipulateValue)))
                }
        
                diff = Int(pixel.blue) - avgBlue
                if (diff > 0) {
                    pixel.blue = UInt8(max(0,min(255,avgBlue+diff/manipulateValue)))
                }

                pixels[index] = pixel
            }
        }
    }
    
    public mutating func intensify (_ manipulateColor:ColorChannel, manipulateValue:Int) {
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                var pixel = pixels[index]
                /*let redDiff = Int(pixel.red) - red
                 let greenDiff = Int(pixel.green) - green
                 let blueDiff = Int(pixel.blue) - blue
                 if (redDiff >= 0) {
                 pixel.red = UInt8(max(0,min(255,red+redDiff/2)))
                 RGBA.pixels[index] = pixel
                 }
                 if (greenDiff >= 0) {
                 pixel.green = UInt8(max(0,min(255,green+greenDiff/2)))
                 RGBA.pixels[index] = pixel
                 }
                 if (blueDiff >= 0) {
                 pixel.blue = UInt8(max(0,min(255,blue+blueDiff/2)))
                 RGBA.pixels[index] = pixel
                 }*/
                var diff = 0
                if (manipulateColor.rawValue.contains("R")) {
                    diff = Int(pixel.red) - avgRed
                    if (diff > 0) {
                        pixel.red = UInt8(max(0,min(255,avgRed+diff*manipulateValue)))
                        pixels[index] = pixel
                    }
                }
                if (manipulateColor.rawValue.contains("G")) {
                    diff = Int(pixel.green) - avgGreen
                    if (diff > 0) {
                        pixel.green = UInt8(max(0,min(255,avgGreen+diff*manipulateValue)))
                        pixels[index] = pixel
                    }
                }
                if (manipulateColor.rawValue.contains("B")) {
                    diff = Int(pixel.blue) - avgBlue
                    if (diff > 0) {
                        pixel.blue = UInt8(max(0,min(255,avgBlue+diff*manipulateValue)))
                        pixels[index] = pixel
                    }
                }
            }
        }
    }
}
