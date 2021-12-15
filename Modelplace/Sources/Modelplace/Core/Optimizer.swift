//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#if os(iOS)
import UIKit

class Optimizer: NSObject {
    class func optimizedPhoto(_ originalImage: UIImage, targetSize: CGFloat = 600) -> UIImage {
        let minDim = min(originalImage.size.width, originalImage.size.height)
        if minDim <= targetSize {
            return originalImage
        }
        let scale = targetSize / minDim
        let resizedSize = CGSize(width: originalImage.size.width * scale, height: originalImage.size.height * scale)
        
        UIGraphicsBeginImageContext(resizedSize)
        originalImage.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: resizedSize))
        defer {
            UIGraphicsEndImageContext()
        }

        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return originalImage
        }
        
        guard let data = resizedImage.jpegData(compressionQuality: 0.95) else {
            return originalImage
        }
        
        guard let image = UIImage(data: data) else {
            return originalImage
        }
        
        return image
    }
}
#else

import Foundation
import CoreGraphics

class Optimizer: NSObject {
    class func optimizedPhoto(_ originalImage: UIImage, targetSize: CGFloat = 960) -> UIImage {
        return originalImage
    }
}

#endif
