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

import Foundation
import CoreImage

#if os(iOS)
import UIKit
#else
import Cocoa
public typealias UIImage = NSImage
#endif

let kPhotoFileName: String = "photo.jpg"

/// Wrapper for image used in Modelplace.
public class ImageFrame {
    public var image: UIImage
    
    public init(image: UIImage) {
        self.image = image
    }
    
    func optimizedFrame() -> ImageFrame {
        return ImageFrame(image: Optimizer.optimizedPhoto(image))
    }
    
    func serialized() -> Data? {
        do {
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let photoURL = documentsURL.appendingPathComponent(kPhotoFileName)
            try image.jpegData(compressionQuality: 1.0)?.write(to: photoURL)
            return try Data(contentsOf: photoURL)
        } catch {
            return nil
        }
    }
}
