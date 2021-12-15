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

@IBDesignable
class ProgressView: UIView {
    private var progressView = UIView()
    
    @IBInspectable public var progress: Float = 0 {
        didSet {
            progressWidth = frame.width * min(CGFloat(progress), 1)
        }
    }
    
    private var progressWidth: CGFloat {
        get {
            return frame.width * min(CGFloat(progress), 1)
        }
        set {
            progressView.frame = CGRect(x: 0, y: 0, width: newValue, height: frame.height)
        }
    }
    
    override func awakeFromNib() {
        backgroundColor = UIColor(named: "secondaryButtonColor")
        progressView.backgroundColor = UIColor(named: "activeColor")
        addSubview(progressView)
    }
}
