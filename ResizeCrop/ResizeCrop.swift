import UIKit

public struct ResizeCrop {
    public enum Gravity {
        case center
        case left
        case top
        case right
        case bottom
    }

    private init() {}

    // MARK: - Low Level Functions

    public static func resize(image: CGImage, toPixelSize pixelSize: CGSize, gravity: Gravity, quality: CGInterpolationQuality = .high) -> CGImage {
        let sourceRatio = ratio(width: CGFloat(image.width), height: CGFloat(image.height))
        let drawLocation = calculateDrawLocation(sourceRatio: sourceRatio, rectToFill: pixelSize, gravity: gravity)

        let context = CGContext(data: nil, width: Int(pixelSize.width), height: Int(pixelSize.height), bitsPerComponent: image.bitsPerComponent, bytesPerRow: 0, space: image.colorSpace!, bitmapInfo: image.bitmapInfo.rawValue)!
        context.interpolationQuality = quality

        context.draw(image, in: drawLocation)
        return context.makeImage()!
    }

    public static func resize(image: UIImage, toPixelSize pixelSize: CGSize, gravity: Gravity, quality: CGInterpolationQuality = .high) -> UIImage {
        let resized = resize(image: image.cgImage!, toPixelSize: pixelSize, gravity: gravity, quality: quality)
        return UIImage(cgImage: resized)
    }

    // MARK: - High Level Functions

    public static func resize(image: UIImage, toSize size: CGSize, scaleFactor: CGFloat, gravity: Gravity) -> UIImage {
        let pixelSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let resized = resize(image: image.cgImage!, toPixelSize: pixelSize, gravity: gravity)
        return UIImage(cgImage: resized, scale: scaleFactor, orientation: image.imageOrientation)
    }

    public static func resize(image: UIImage, toSize size: CGSize, gravity: Gravity) -> UIImage {
        return resize(image: image, toSize: size, scaleFactor: image.scale, gravity: gravity)
    }

    public static func resize(image: UIImage, toFillView view: UIView, gravity: Gravity) -> UIImage {
        return resize(image: image, toSize: view.frame.size, scaleFactor: view.window!.screen.scale, gravity: gravity)
    }

    // MARK: - Calculations

    private static func calculateDrawLocation(sourceRatio: CGFloat, rectToFill: CGSize, gravity: Gravity) -> CGRect {
        let targetRatio = ratio(width: rectToFill.width, height: rectToFill.height)
        if sourceRatio == targetRatio {
            return CGRect(origin: .zero, size: rectToFill)
        }
        let (drawWidth, drawHeight) = sourceRatio > targetRatio
            ? (rectToFill.height * sourceRatio, rectToFill.height)
            : (rectToFill.width, rectToFill.width / sourceRatio)

        switch gravity {
        case .center:
            return CGRect(x: (rectToFill.width - drawWidth) / 2,
                          y: (rectToFill.height - drawHeight) / 2,
                          width: drawWidth,
                          height: drawHeight)
        case .left:
            return CGRect(x: 0,
                          y: (rectToFill.height - drawHeight) / 2,
                          width: drawWidth,
                          height: drawHeight)
        case .top:
            return CGRect(x: (rectToFill.width - drawWidth) / 2,
                          y: rectToFill.height - drawHeight,
                          width: drawWidth,
                          height: drawHeight)
        case .right:
            return CGRect(x: rectToFill.width - drawWidth,
                          y: (rectToFill.height - drawHeight) / 2,
                          width: drawWidth,
                          height: drawHeight)
        case .bottom:
            return CGRect(x: (rectToFill.width - drawWidth) / 2,
                          y: 0,
                          width: drawWidth,
                          height: drawHeight)
        }
    }

    private static func ratio(width: CGFloat, height: CGFloat) -> CGFloat {
        return width / height
    }
}
