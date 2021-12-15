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
import Alamofire
import OAuthSwift

internal class OAuthSwiftRedirectHandler: RedirectHandler {
    func task(_ task: URLSessionTask, willBeRedirectedTo request: URLRequest, for response: HTTPURLResponse, completion: @escaping (URLRequest?) -> Void) {
        var redirectedRequest = request

        if let originalRequest = task.originalRequest, let headers = originalRequest.allHTTPHeaderFields, let authorizationHeaderValue = headers["Authorization"] {
            var mutableRequest = request
            mutableRequest.setValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
            redirectedRequest = mutableRequest
        }

        completion(redirectedRequest)
    }
}

internal class OAuthSwiftRequestInterceptor: RequestInterceptor {
    fileprivate let oauthSwift: OAuth2Swift

    fileprivate let lock = NSLock()
    fileprivate var isRefreshing = false
    fileprivate var requestsToRetry: [(RetryResult) -> Void] = []

    public init(_ oauthSwift: OAuth2Swift) {
        self.oauthSwift = oauthSwift
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var config = OAuthSwiftHTTPRequest.Config(
            urlRequest: urlRequest,
            paramsLocation: .authorizationHeader,
            dataEncoding: .utf8
        )
        config.updateRequest(credential: oauthSwift.client.credential)

        do {
            let request = try OAuthSwiftHTTPRequest.makeRequest(config: config)
            completion(.success(request))
        } catch (let error) {
            completion(.failure(error))
        }
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        lock.lock() ; defer { lock.unlock() }

        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)

            if !isRefreshing {
                refreshTokens { [weak self] succeeded in
                    guard let strongSelf = self else { return }

                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }

                    strongSelf.requestsToRetry.forEach { $0(.retry) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(.doNotRetry)
        }
    }

    fileprivate typealias RefreshCompletion = (_ succeeded: Bool) -> Void

    fileprivate func refreshTokens(_ completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }

        isRefreshing = true
        oauthSwift.authorize(deviceToken: "", grantType: kGrantType, completionHandler: { [weak self] (result) in
            switch result {
            case .success(let token):
                Storage.oauthCredential = token.credential
                completion(true)
                self?.isRefreshing = false
            case .failure:
                completion(false)
                self?.isRefreshing = false
            }
        })
    }
}
