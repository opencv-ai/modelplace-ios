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
import Modelplace

class ProcessViewController: UIViewController {
    var model: ResponseModel?
    var image: UIImage?
    var resultImage: UIImage? {
        didSet {
            comparisonView.resultImage = resultImage
            comparisonView.sliderPosition = 0.5
        }
    }

    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var comparisonView: BeforeAfterImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    var currentTask: ResponseTaskModel?
    var currentResults: ResponseResultModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startProcessing()
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let image = resultImage {
            let objectsToShare = [image] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = saveButton
            activityVC.completionWithItemsHandler = { activity, success, items, error in }
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func startProcessing() {
        guard let image = image else { return }
        guard let model = model else { return }
        comparisonView?.initialImage = image
        
        ModelManager.createTask(model: model, withImage: ImageFrame(image: image)).progress { [weak self] progress in
            self?.progressView.progress = progress.value
        }.completion { [weak self] result in
            switch (result) {
            case .success(let taskModel):
                self?.currentTask = taskModel
                self?.getResults(taskModel)
            case .failure(let error):
                self?.progressLabel.text = "Sending Failed"
                print(error)
            }
        }
    }
    
    func getResults(_ taskModel: ResponseTaskModel) {
        progressLabel.text = "Processing..."
        progressView.progress = 0
        
        ModelManager.getResults(model: taskModel).progress { [weak self] progress in
            self?.progressView.progress = progress.value
            self?.progressLabel.text = progress.state.capitalized
        }.completion { [weak self] result in
            switch (result) {
            case .success(let resultsModel):
                self?.progressLabel.text = "Downloading results..."
                self?.currentResults = resultsModel
                self?.updateResults(resultsModel)
            case .failure(let error):
                self?.progressLabel.text = "Downloading Failed"
                print(error)
            }
        }
    }
    
    func updateResults(_ model: ResponseResultModel) {
        DispatchQueue.global().async {
            guard let urlString = model.visualization else { return }
            guard let url = URL(string: urlString) else { return }
            guard let data = try? Data(contentsOf: url) else { return }
            
            DispatchQueue.main.async {
                self.progressView.isHidden = true
                self.saveButton.isHidden = false
                self.progressLabel.text = "Done!"
                self.resultImage = UIImage(data: data)
                self.actionButton.setTitle("Start again", for: .normal)
                self.actionButton.backgroundColor = UIColor(named: "activeColor")
            }
        }
    }
}
