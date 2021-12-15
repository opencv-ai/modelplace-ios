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

let requestFrequency = 2.0

internal class ModelSender: TaskHandler<ResponseTaskModel> {
    let model: ResponseModel
    init(model: ResponseModel) {
        self.model = model
    }
    
    internal func sendImage(image: ImageFrame) -> Self {
        let resizedImage = image.optimizedFrame()
        Modelplace.sendImage(image: resizedImage, model: model, uploadingProgress: { (progress) in
            self.updateProgress(state: "Sending", value: Float(progress))
        }) { (result) in
            switch (result) {
            case .success(let value):
                self.taskComplete(withResult: Result.success(value))
            case .failure(let error):
                self.taskComplete(withResult: Result.failure(MPError.sendingFailed(error: error)))
            }
        }

        return self
    }
}

internal class ModelLoader: TaskHandler<ResponseResultModel> {
    var taskModel: ResponseTaskModel
    var resultModel: ResponseResultModel?
    var needsVisualization: Bool = true

    internal init(model: ResponseTaskModel) {
        self.taskModel = model
    }

    @objc private func retriveStatus() {
        let successHandler: (ResponseResultModel) -> Void = { [unowned self] model in
            self.updateProgress(state: model.status, value: 0)
            resultModel = model
            
            if (model.computed() && !needsVisualization) || (needsVisualization && model.visualizationСomputed()) {
                self.taskComplete(withResult: Result.success(model))
            } else if model.failed() || (needsVisualization && model.visualizationFailed()) {
                self.taskComplete(withResult: Result.failure(MPError.computingFailed))
            } else {
                Timer.scheduledTimer(timeInterval: requestFrequency, target: self, selector: #selector(self.retriveStatus), userInfo: nil, repeats: false)
            }
        }

        Modelplace.getResults(taskID: taskModel.task_id, completion: { [unowned self] (result) in
            switch (result) {
            case .success(let model):
                successHandler(model)
            case .failure(let error):
                self.taskComplete(withResult: Result.failure(MPError.downloadingFailed(reason: .retriveStatusFailed(error: error))))
            }
        })
    }

    @discardableResult
    func tryDownloadResults() -> Self {
        if !inProgress {
            inProgress = true
            retriveStatus()
        }
        return self
    }
}
