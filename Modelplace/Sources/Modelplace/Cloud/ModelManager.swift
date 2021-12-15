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

/// `ModelManager` is used to handle all operations with models in cloud version of SDK.
public class ModelManager {
    static var loaderDict = [String: ModelLoader]()

    /// Is used create task to compute model on the server.
    ///
    /// - parameter image:            Image frame which will be used for the model computation.
    ///
    /// - returns: Task handler object which can be used for subscription on progress and completion callbacks.
    public class func createTask(model: ResponseModel, withImage image: ImageFrame) -> TaskHandler<ResponseTaskModel> {
        let sender = ModelSender(model: model)
        return sender.sendImage(image: image)
    }

    /// Is used to download task result files from the server.
    ///
    /// - parameter taskModel: The task model which files should be downloaded.
    ///
    /// - returns: Task handler object which can be used for subscription on progress and completion callbacks.
    public class func getResults(model: ResponseTaskModel) -> TaskHandler<ResponseResultModel> {
        if let loader = loaderDict[model.task_id] {
            return loader.tryDownloadResults()
        }

        let loader = ModelLoader(model: model)
        loaderDict[model.task_id] = loader
        return loader.tryDownloadResults()
    }
}
