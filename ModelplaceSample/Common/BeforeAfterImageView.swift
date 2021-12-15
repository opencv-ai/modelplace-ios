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

@propertyWrapper
struct Clamping<Value: Comparable> {
    var value: Value
    let range: ClosedRange<Value>
    
    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        precondition(range.contains(wrappedValue))
        self.value = wrappedValue
        self.range = range
    }
    
    var wrappedValue: Value {
        get { value }
        set { value = min(max(range.lowerBound, newValue), range.upperBound) }
    }
}

class BeforeAfterImageView: UIView {
    var initialImage: UIImage? {
        didSet {
            initialImageView.image = initialImage
            updateFrames()
        }
    }
    var resultImage: UIImage? {
        didSet {
            resultImageView.image = resultImage
            updateFrames()
        }
    }
    
    var isDragged = false
    private var panGestureRecognizer: UIPanGestureRecognizer?
    @Clamping(0...1) public var sliderPosition: CGFloat = 1.0 {
        didSet {
            updateFrames()
            setNeedsDisplay()
        }
    }
    
    private lazy var placeholerView: UIView = {
        let view = UIView(frame: frame)
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16.0
        view.layer.masksToBounds = true
        addSubview(view)
        return view
    }()
    
    var sliderHeight: CGFloat = 112
    private lazy var sliderImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: placeholerView.frame.width - 16, height: sliderHeight)))
        imageView.image = UIImage(named: "sliderImage")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 70))
        imageView.autoresizingMask = [.flexibleWidth]
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var initialLabel: UILabel = {
        let label = UILabel()
        label.text = "BEFORE"
        label.sizeToFit()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        label.frame = CGRect(x: placeholerView.frame.width - label.frame.width - 16, y: 16, width: label.frame.width, height: label.frame.height)
        return label
    }()
    
    let initialLayerMask = CAShapeLayer()
    private lazy var initialImageView: UIImageView = {
        let imageView = UIImageView(frame: placeholerView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.layer.masksToBounds = true
        imageView.layer.mask = initialLayerMask
        return imageView
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "AFTER"
        label.sizeToFit()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        label.frame = CGRect(x: placeholerView.frame.width - label.frame.width - 16, y: placeholerView.frame.height - label.frame.height - 16, width: label.frame.width, height: label.frame.height)
        return label
    }()
    
    let resultLayerMask = CAShapeLayer()
    private lazy var resultImageView: UIImageView = {
        let imageView = UIImageView(frame: placeholerView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.layer.masksToBounds = true
        imageView.layer.mask = resultLayerMask
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        panGestureRecognizer?.minimumNumberOfTouches = 1
        panGestureRecognizer?.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panGestureRecognizer!)
        
        placeholerView.addSubview(initialImageView)
        placeholerView.addSubview(resultImageView)
        placeholerView.addSubview(initialLabel)
        placeholerView.addSubview(resultLabel)
        placeholerView.addSubview(sliderImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }

    private func updateFrames() {
        guard let image = initialImage ?? resultImage else { return }
        
        placeholerView.frame = frame.fitWithRatio(image.ratio)
        
        initialLabel.isHidden = resultImage == nil
        resultLabel.isHidden = resultImage == nil
        sliderImageView.isHidden = resultImage == nil

        initialLabel.alpha = sliderPosition
        resultLabel.alpha = 1 - sliderPosition
        sliderImageView.center.y = resultImageView.bounds.height * sliderPosition
    }
    
    override func draw(_ rect: CGRect) {
        let initialPath = UIBezierPath(rect: CGRect(x: resultImageView.bounds.minX, y: 0, width: resultImageView.bounds.width, height: resultImageView.bounds.height * sliderPosition))
        initialLayerMask.path = initialPath.cgPath
        
        let resultPath = UIBezierPath(rect: CGRect(x: resultImageView.bounds.minX, y: resultImageView.bounds.height * sliderPosition, width: resultImageView.bounds.width, height: resultImageView.bounds.height * (1 - sliderPosition)))
        resultLayerMask.path = resultPath.cgPath
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let location = recognizer.location(in: placeholerView)
            let sliderRect = CGRect(x: placeholerView.bounds.minX, y: placeholerView.bounds.height * sliderPosition, width: placeholerView.bounds.width, height: 0).insetBy(dx: 0, dy: -sliderHeight/2)
            if sliderRect.contains(location) {
                isDragged = true
            }
        case .ended, .cancelled, .failed:
            defer {
                isDragged = false
            }
            fallthrough
        default:
            if isDragged {
                sliderPosition += recognizer.translation(in: placeholerView).y / placeholerView.frame.height
                recognizer.setTranslation(CGPoint.zero, in: placeholerView)
            }
            break
        }
    }
}
