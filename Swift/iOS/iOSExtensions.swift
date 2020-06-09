//
//  iOSExtensions.swift
//
//  Created by Will Cook on 3/12/20.
//
//  A collection of useful Swift extensions I have either found
//  on Stack Overflow/GitHub or created myself.  All of these
//  work on iOS/Mac Catalyst.

import UIKit

//  Extension that allows you to access the red, green, blue, and
//  alpha components of a UIColor using dot syntax.  For example:
//  view.layer.backgroundColor = myColor.rgba.red

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
}

//  Extension that allows you to calculate the numerical difference
//  between any two dates you pass in.  Useful for any views that
//  display date labels.  For example:
//  if Calendar.autoupdatingCurrent.roundedDays(from: oldDate, to: Date()) <= 7...

extension Calendar {
    func roundedDays(from a: Date, to b: Date) -> Int {
        let aymd = dateComponents([.year, .month, .day], from: a)
        let bymd = dateComponents([.year, .month, .day], from: b)
        let diff = dateComponents([.day], from: aymd, to: bymd).day!
        return diff
    }
}

//  Three useful extensions for UIImages.  The first, cropSquare, does
//  what its name implies; it crops the specified image into a square.
//  The second, to CompressedJpegData, returns the raw jpeg data
//  representation of the specified UIImage using the quality passed in
//  as a parameter.  Useful for storing the image in a database.  The third,
//  resized(toSize) resizes the image it is called on to the specified size
//  in the CGSize parameter.  For example:
//  imageView.image = myImage.cropSquare()
//  imageData = myImage.toCompressedJpegData(.mediumLow)
//  imageView.image = myImage.resized(to size: CGSize(width: 650, height: 400)

extension UIImage {
    func cropSquare() -> UIImage {

        let cgimage = self.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = self.size.width
        var cgheight: CGFloat = self.size.height

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)

        return image
    }
    
    enum JPEGQuality: CGFloat {
        case lowest = 0
        case lower = 0.125
        case low = 0.25
        case mediumLow = 0.375
        case medium = 0.5
        case mediumHigh = 0.675
        case high = 0.75
        case higher = 0.875
        case highest = 1
    }
    
    func toCompressedJpegData(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
    
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image {_ in
            self.draw(in: CGRect(origin: .zero, size: size)
        )}
    }
}

//  Extension that allows you to set both the font style
//  and the font weight for the system font.  For example:
//  myLabel.text = UIFont.preferredFont(for: .caption1, weight: .semibold)

extension UIFont {
    static func preferredFont(for style: TextStyle, weight: Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
}

//  Three useful extensions on the Data type itself.
//  The first returns a compressed version of the passed-in
//  data using a cross-platform compression algorithm.  The
//  second decompresses any data that was compressed with
//  the same algorithm.  The third returns a string that
//  is the size of the specified data in megabytes or
//  kilobytes, depending on the size of the data.  For example:
//  let compressedImage = myImage.toCompressedData()
//  let decompressedData = myImage.toDecompressedData()
//  print("Size of data:\(decompressedData.sizeInMegabytes())")

extension Data {
    func toCompressedData() -> Data {
        do {
            let compressedData = try (self as NSData).compressed(using: .zlib)
            return compressedData as Data
        } catch {
            print(error.localizedDescription)
        }
        return self
    }
    
    func toDecompressedData() -> Data {
        do {
            let decompressedData = try (self as NSData).decompressed(using: .zlib)
            return decompressedData as Data
        } catch {
            print(error.localizedDescription)
        }
        return self
    }
    
    func sizeInMegabytes() -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB, .useKB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(self.count))
    }
}

//  Extension that allows you to initialize a regex (regular expression, a shorthand way to search/parse
//  strings) with the required try/catch statements in the initializer.  For example:
//  let regexPattern = "\\[|(drawing=[A-Za-z0-9-]+)|\\]"
//  let regex = NSRegularExpression(regexPattern)

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}

