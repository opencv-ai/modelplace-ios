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

let kServerAddress: String = "https://api.modelplace.ai/v3/"

let kAuthorizeURL: String = "\(kServerAddress)o/authorize/"
let kTokenURL: String = "\(kServerAddress)o/token/"

let kLoginURL: String = "\(kServerAddress)login"

let kModelsURL: String = "\(kServerAddress)models?page_size=1000&sort_key=id"
let kModelURL: ((ResponseModel)->String) = {"\(kServerAddress)process?model_id=\($0.id)"}
let kResultsURL: String = "\(kServerAddress)task"

let kGrantType: String = "client_credentials"

/// `Modelplace` is used to initialize SDK and `authorize` user.
public class Modelplace: NSObject {
    static var oauthSwift: OAuth2Swift?
    static var sessionManager: Session?

    //MARK: Initialize

    /// Should be called first to initialize and handle the configuration of Modelplace SDK. After this call you can use the SDK for other purposes.
    /// Is used to authorize user. Will be automatically called again in the case of 401 (Unauthorized) http error.
    /// TODO: use OAuth2.0 for authorize user purposes
    ///
    /// - parameter consumerKey: Consumer key provided by Modelplace.
    /// - parameter consumerSecret: Consumer secret provided by Modelplace.
    /// - parameter modelFolderName: Path to folder in Documents (standard iOS folder) which will be used to store the models and temporary files.
    ///
    /// - parameter completion: Closure to be executed once the request has finished.
    
    public class func with(consumerKey: String, consumerSecret: String, modelFolderName: String = "models", completion: @escaping CompletionHandler<Bool, Error>) {
        modelFolder = modelFolderName

        let oauthSwift = OAuth2Swift.init(consumerKey: consumerKey, consumerSecret: consumerSecret, authorizeUrl: kAuthorizeURL, accessTokenUrl: kTokenURL, responseType: "token")

        if let credential = Storage.oauthCredential {
            oauthSwift.client.credential.oauthToken = credential.oauthToken
            oauthSwift.client.credential.oauthTokenExpiresAt = credential.oauthTokenExpiresAt
        }
        self.oauthSwift = oauthSwift

        let configuration = URLSessionConfiguration.default
        configuration.headers = HTTPHeaders.default
        sessionManager = Session(configuration: configuration, interceptor: OAuthSwiftRequestInterceptor(oauthSwift), redirectHandler: OAuthSwiftRedirectHandler())
        
        if !isAuthorized() {
            oauthSwift.authorize(deviceToken: "", grantType: kGrantType, completionHandler: { result in
                switch result {
                case .success:
                    Storage.oauthCredential = oauthSwift.client.credential
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        } else {
            completion(.success(true))
        }
    }
    
    /// Should be called first to initialize and handle the configuration of Modelplace SDK. After this call you can use the SDK for other purposes.
    /// Is used to authorize user.
    /// TODO: should be removed
    ///
    /// - parameter login: Consumer login provided by Modelplace.
    /// - parameter consumerSecret: Consumer password provided by Modelplace.
    /// - parameter modelFolderName: Path to folder in Documents (standard iOS folder) which will be used to store the models and temporary files.
    ///
    /// - parameter completion: Closure to be executed once the request has finished.
    public class func with(login: String, password: String, modelFolderName: String = "models", completion: @escaping CompletionHandler<Bool, Error>) {
        modelFolder = modelFolderName
        
        let oauthSwift = OAuth2Swift(consumerKey: "", consumerSecret: "", authorizeUrl: kAuthorizeURL, accessTokenUrl: kTokenURL, responseType: "")
        if let credential = Storage.oauthCredential {
            oauthSwift.client.credential.oauthToken = credential.oauthToken
            oauthSwift.client.credential.oauthRefreshToken = credential.oauthRefreshToken
            oauthSwift.client.credential.oauthTokenExpiresAt = credential.oauthTokenExpiresAt
        }
        self.oauthSwift = oauthSwift
        
        let configuration = URLSessionConfiguration.default
        configuration.headers = HTTPHeaders.default
        sessionManager = Session(configuration: configuration, interceptor: OAuthSwiftRequestInterceptor(oauthSwift), redirectHandler: OAuthSwiftRedirectHandler())
        
        if !isAuthorized() {
            let parameters: [String: String] = [
                "email": login,
                "password": password,
            ]
            
            let url = kLoginURL
            sessionManager?.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).validate().responseDecodable(of: ResponseLoginModel.self) { response in
                switch response.result {
                case .success(let loginModel):
                    oauthSwift.client.credential.oauthToken = loginModel.access_token
                    oauthSwift.client.credential.oauthRefreshToken = loginModel.refresh_token
                    oauthSwift.client.credential.oauthTokenExpiresAt = Date(timeInterval: TimeInterval(loginModel.expires_in), since: Date())
                    
                    Storage.oauthCredential = oauthSwift.client.credential
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(true))
        }
    }

    /// Is used to determine the authorization status.
    public class func isAuthorized() -> Bool {
        return (oauthSwift?.client.credential.oauthTokenExpiresAt != nil) && !(oauthSwift?.client.credential.isTokenExpired() ?? true)
    }
    
    public class func getModels(completion: @escaping CompletionHandler<ResponseModels, AFError>) {
        let url = kModelsURL
        sessionManager?.request(url).validate().responseDecodable(of: ResponseModels.self) { response in
            completion(response.result)
        }
    }
    
    internal class func sendImage(image: ImageFrame, model: ResponseModel, uploadingProgress: @escaping (Double) -> Void, completion: @escaping CompletionHandler<ResponseTaskModel, AFError>) {
        if let data = image.serialized() {
            let url = kModelURL(model)
            sessionManager?.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(data, withName: "upload_data", fileName: "photo.png", mimeType: "image/png")
                }, to: url).validate()
                .uploadProgress { progress in
                    uploadingProgress(progress.fractionCompleted)
                }
                .responseDecodable(of: ResponseTaskModel.self) { response in
                    completion(response.result)
                }
        }
    }
    
    internal class func getResults(taskID: String, completion: @escaping CompletionHandler<ResponseResultModel, AFError>) {
        let url = kResultsURL
        let parameters: [String: String] = [
            "task_id": taskID,
            "visualize": "true",
        ]
        sessionManager?.request(url, parameters: parameters).validate().responseDecodable(of: ResponseResultModel.self) { response in
            completion(response.result)
        }
    }
}
