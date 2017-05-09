//
//  iOSDevCenters+GIF.swift
//  GIF-Swift
//
//  Created by iOSDevCenters on 11/12/15.
//  Copyright © 2016 iOSDevCenters. All rights reserved.
//
import UIKit
import ImageIO
import MobileCoreServices

typealias GIFProperties = [String: Double]
let defaultDuration: Double = 0

/// Retruns the duration of a frame at a specific index using an image source (an `CGImageSource` instance).
///
/// - returns: A frame duration.
func CGImageFrameDuration(with imageSource: CGImageSource, atIndex index: Int) -> TimeInterval {
    if !imageSource.isAnimatedGIF { return 0.0 }
    
    guard let GIFProperties = imageSource.properties(at: index),
        let duration = frameDuration(with: GIFProperties),
        let cappedDuration = capDuration(with: duration)
        else { return defaultDuration }
    
    return cappedDuration
}

/// Ensures that a duration is never smaller than a threshold value.
///
/// - returns: A capped frame duration.
func capDuration(with duration: Double) -> Double? {
    if duration < 0 { return .none }
    let threshold = 0.02 - Double.ulpOfOne
    let cappedDuration = duration < threshold ? 0.1 : duration
    return cappedDuration
}

/// Returns a frame duration from a `GIFProperties` dictionary.
///
/// - returns: A frame duration.
func frameDuration(with properties: GIFProperties) -> Double? {
    guard let unclampedDelayTime = properties[String(kCGImagePropertyGIFUnclampedDelayTime)],
        let delayTime = properties[String(kCGImagePropertyGIFDelayTime)]
        else { return .none }
    
    return duration(withUnclampedTime: unclampedDelayTime, andClampedTime: delayTime)
}

/// Calculates frame duration based on both clamped and unclamped times.
///
/// - returns: A frame duration.
func duration(withUnclampedTime unclampedDelayTime: Double, andClampedTime delayTime: Double) -> Double {
    let delayArray = [unclampedDelayTime, delayTime]
    return delayArray.filter({ $0 >= 0 }).first ?? defaultDuration
}

/// An extension of `CGImageSourceRef` that add GIF introspection and easier property retrieval.
extension CGImageSource {
    /// Returns whether the image source contains an animated GIF.
    ///
    /// - returns: A boolean value that is `true` if the image source contains animated GIF data.
    var isAnimatedGIF: Bool {
        let isTypeGIF = UTTypeConformsTo(CGImageSourceGetType(self) ?? "" as CFString, kUTTypeGIF)
        let imageCount = CGImageSourceGetCount(self)
        return isTypeGIF != false && imageCount > 1
    }
    
    /// Returns the GIF properties at a specific index.
    ///
    /// - parameter index: The index of the GIF properties to retrieve.
    /// - returns: A dictionary containing the GIF properties at the passed in index.
    func properties(at index: Int) -> GIFProperties? {
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as? [String: AnyObject] else { return nil }
        return imageProperties[String(kCGImagePropertyGIFDictionary)] as? GIFProperties
    }
}


extension UIImage {
    
    public class func gifImageWithData(data: NSData) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source: source)
    }
    
    public class func gifImageWithURL(gifUrl:String) -> UIImage? {
        guard let bundleURL = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = NSData(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    public class func gifImageWithName(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = NSData(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        return CGImageFrameDuration(with: source, atIndex: index)
    }
    
    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(a: val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(index: Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(array: delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                                        duration: Double(duration) / 1000.0)
        
        return animation
    }
}
