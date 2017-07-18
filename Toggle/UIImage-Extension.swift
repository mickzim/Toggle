import Foundation
import UIKit

extension UIImage {
    class func combine(images: UIImage..., width: CGFloat = 0.0) -> UIImage {
        var contextSize = CGSize.zero

        var maxImageWidth: CGFloat = 0.0

        var w: CGFloat = 0.0
        for image in images {
            w = w + image.size.width
            maxImageWidth = max(maxImageWidth, image.size.width)
            contextSize.height = max(contextSize.height, image.size.height)
        }
        let totalWidth = max(width/UIScreen.main.scale, w)
        contextSize.width = max(contextSize.width, totalWidth)

        UIGraphicsBeginImageContextWithOptions(contextSize, false, UIScreen.main.scale)

        var originX: CGFloat = 0.0
//        var originY: CGFloat = 0.0
        let xOffset: CGFloat = (totalWidth - maxImageWidth) / CGFloat(images.count - 1)

        for image in images {
//            let originX = (contextSize.width - image.size.width) / 2
            let originY = (contextSize.height - image.size.height) / 2
            image.draw(in: CGRect(x: originX, y: originY, width: image.size.width, height: image.size.height))
            originX += xOffset
        }

        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return combinedImage!
    }
}
