import UIKit

/**
 Functions for resizing an image to fill a specific `CGSize` or `UIView`'s frame.
 - Important: Aspect ratio is always maintained.

 **Examples**
 ````
 ResizeCrop.resize(
     image: myImage,
     toFillView: myView,
     gravity: .bottom)
 ````
 ````
 ResizeCrop.resize(
     image: cgImage,
     toPixelSize: CGSize(width: 100, height: 100),
     gravity: .center,
     quality: .default)
 ````

 Generally, you provide two things besides the image:
 - *Gravity*: determines which part of the image will be cropped
 - *Target*: an area the image should fill

 There are a couple of other resizing options:
 - *Scale* (e.g. 1x, 2x). Implied or specified explicitly
 - *Interpolation quality*. `.high` by default

 ---------------------------------------------------------------

 - Note: As the name of the library implies, images are cropped.
 Specifically, the library does almost the same thing as `UIImageView`
 with content mode set to **Aspect Fill** except that *you can choose
 which part of the image to crop*, and the image is actually resampled
 therefore consuming less memory.
 */
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

    /**
     Resizes an image to the specified size in pixels

     - Parameters:
       - image: Source image
       - pixelSize: Desired size of the resulting image in pixels
       - gravity: Which part of the `image` to crop
       - quality: Interpolation quality for a graphics context
     */
    public static func resize(image: CGImage, toPixelSize pixelSize: CGSize, gravity: Gravity, quality: CGInterpolationQuality = .high) -> CGImage {
        let sourceRatio = ratio(width: CGFloat(image.width), height: CGFloat(image.height))
        let drawLocation = calculateDrawLocation(sourceRatio: sourceRatio, rectToFill: pixelSize, gravity: gravity)

        let context = CGContext(data: nil, width: Int(pixelSize.width), height: Int(pixelSize.height), bitsPerComponent: image.bitsPerComponent, bytesPerRow: 0, space: image.colorSpace!, bitmapInfo: image.bitmapInfo.rawValue)!
        context.interpolationQuality = quality

        context.draw(image, in: drawLocation)
        return context.makeImage()!
    }

    /**
     Resizes an image to the specified size in pixels

     - Parameters:
       - image: Source image
       - pixelSize: Desired size of the resulting image in pixels
       - gravity: Which part of the `image` to crop
       - quality: Interpolation quality for a graphics context
     */
    public static func resize(image: UIImage, toPixelSize pixelSize: CGSize, gravity: Gravity, quality: CGInterpolationQuality = .high) -> UIImage {
        let resized = resize(image: image.cgImage!, toPixelSize: pixelSize, gravity: gravity, quality: quality)
        return UIImage(cgImage: resized)
    }

    // MARK: - High Level Functions

    /**
     Resizes an image given a target size in points and a scaleFactor

     - Parameters:
       - image: Source image
       - size: Desired size of the resulting image in points
       - scaleFactor: Scale factor of the resulting image. Used in conjunction with `size` to determine the size of the result
       - gravity: Which part of the `image` to crop
     */
    public static func resize(image: UIImage, toSize size: CGSize, scaleFactor: CGFloat, gravity: Gravity) -> UIImage {
        let pixelSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let resized = resize(image: image.cgImage!, toPixelSize: pixelSize, gravity: gravity)
        return UIImage(cgImage: resized, scale: scaleFactor, orientation: image.imageOrientation)
    }

    /**
     Resizes an image to the specified size

     - Parameters:
       - image: Source image
       - size: Desired size of the resulting image. Units depend on the `image` scale
       - gravity: Which part of the `image` to crop
     */
    public static func resize(image: UIImage, toSize size: CGSize, gravity: Gravity) -> UIImage {
        return resize(image: image, toSize: size, scaleFactor: image.scale, gravity: gravity)
    }


    /**
     Resizes an image to the size of a view's frame

     - Parameters:
       - image: Source image
       - view: The view whose size is used for the result
       - gravity: Which part of the `image` to crop

     - Requires:
     `view.window != nil`

     - Note:
       Pixel size of the result is determined by the scale factor the `view`'s screen
     */
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
