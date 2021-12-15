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

import UIKit

extension UIViewController {
    class func instantiateFromStoryboard(_ name: String, customVCName: String? = nil) -> Self {
        return instantiateFromStoryboardHelper(name, customVCName: customVCName)
    }
    
    fileprivate class func instantiateFromStoryboardHelper<T>(_ name: String, customVCName: String? = nil) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let identifier = customVCName ?? String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
}

extension CGRect {
    func fitWithRatio(_ ratio: CGFloat) -> CGRect {
        let fitHeight = min(height, width / ratio)
        let fitWidth = min(width, height * ratio)
        let fitSize = CGSize(width: fitWidth, height: fitHeight)
        
        return CGRect(origin: CGPoint(x: (width - fitWidth) / 2, y: (height - fitHeight) / 2), size: fitSize)
    }
}

extension CGSize {
    func fitWithRatio(_ ratio: CGFloat) -> CGSize {
        let fitHeight = min(height, width / ratio)
        let fitWidth = min(width, height * ratio)
        let fitSize = CGSize(width: fitWidth, height: fitHeight)
        
        return fitSize
    }
}

extension UIImage {
    var ratio: CGFloat {
        return size.width / size.height
    }
}
