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

public typealias CompletionHandler<T, E: Error> = (Result<T, E>) -> Void

/// `TaskHandler` is used for subscription on task progress and completion callbacks.
public class TaskHandler<Model> {

    public typealias ProgressHandler = (TaskProgress) -> Void
    
    /// `TaskProgress` is used to provide the task progress
    open class TaskProgress {
        public var state: String
        public var value: Float

        internal init(state: String, value: Float) {
            self.state = state
            self.value = value
        }
    }

    var inProgress = false
    var progressHandler: ProgressHandler?
    var completionHandler: CompletionHandler<Model, Error>?

    /// Sets a closure to be called periodically during the lifecycle.
    ///
    /// - parameter handler: Closure to be executed periodically.
    ///
    /// - returns: The task handler.
    @discardableResult
    public func progress(handler: @escaping ProgressHandler) -> Self {
        progressHandler = handler
        return self
    }

    /// Adds a handler to be called once the task has finished.
    ///
    /// - parameter handler: Closure to be executed once the model downloading has finished.
    ///
    /// - returns: The task handler.
    @discardableResult
    public func completion(handler: @escaping CompletionHandler<Model, Error>) -> Self {
        completionHandler = handler
        return self
    }

    func updateProgress(state: String, value: Float) {
        progressHandler?(TaskProgress(state: state, value: value))
    }

    func taskComplete(withResult result: Result<Model, Error>) {
        inProgress = false
        completionHandler?(result)
    }
}
