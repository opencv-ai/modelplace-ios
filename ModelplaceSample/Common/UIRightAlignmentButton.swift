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
import UIKit

class UIRightAlignmentButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = imageView {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: bounds.width - titleLabel!.frame.width - 32, bottom: 0, right: 32)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: imageView.frame.width, bottom: 0, right: 0)
        }
    }
}
