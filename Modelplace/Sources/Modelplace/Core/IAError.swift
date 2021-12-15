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

/// `MPError` is the error type returned by Modelplace. It encompasses a few different types of errors, each with its own associated reasons.
///
/// - sendingFailed:               Returned when sending process fails.
/// - emptyCacheError:         Returned when cache for the requested object is empty.
public enum MPError: Error {

    /// `DownloadingError` is the error type returned in the case of file downloading error.
    ///
    /// - networkError:         The error URL request finished with.
    /// - unzipError:           The error unzipping process failed with.
    public enum DownloadingError: Error {
        case networkError(error: Error)
        case unzipError(error: Error)
    }

    /// The underlying reason of model downloading error.
    ///
    /// - retriveStatusFailed:         The error status retriving process finished with.
    /// - downloadingFailed:         The error files downloading process finished with.
    public enum DownloadingFailureReason {
        case retriveStatusFailed(error: Error)
        case downloadingFailed(error: DownloadingError)
    }

    case sendingFailed(error: Error)
    case computingFailed
    case downloadingFailed(reason: DownloadingFailureReason)
    case emptyCacheError
}

extension MPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .sendingFailed(let error):
            return "Sending error: " + error.localizedDescription
        case .computingFailed:
            return "Computing error: " + "Sorry, we can't compute . Please try another."
        case .downloadingFailed(let reason):
            return "Downloading model error: " + reason.localizedDescription
        case .emptyCacheError:
            return "Cache is empty."
        }
    }
    
    public var underlyingError: Error? {
        switch self {
        case .sendingFailed(let error):
            return error
        case .computingFailed:
            return nil
        case .downloadingFailed(let reason):
            return reason.underlyingError
        case .emptyCacheError:
            return nil
        }
    }
}

extension MPError.DownloadingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Problem with network: " + error.localizedDescription
        case .unzipError(let error):
            return "Problem with data: " + error.localizedDescription
        }
    }
    
    public var underlyingError: Error? {
        switch self {
        case .networkError(let error):
            return error
        case .unzipError(let error):
            return error
        }
    }
}

public extension MPError.DownloadingFailureReason {
    var localizedDescription: String {
        switch self {
        case .retriveStatusFailed(let error):
            return "" + error.localizedDescription
        case .downloadingFailed(let error):
            return "" + error.errorDescription!
        }
    }
    
    var underlyingError: Error? {
        switch self {
        case .retriveStatusFailed(let error):
            return error
        case .downloadingFailed(let error):
            return error.underlyingError
        }
    }
}
