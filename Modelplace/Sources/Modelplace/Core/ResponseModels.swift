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

/// `ResponseModel` is used for mapping server response.
open class ResponseModel: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case shortModelName = "short_model_name"
    }
    
    public var id : Int
    public var shortModelName : String
}

/// `ResponseModels` is used for mapping server response.
open class ResponseModels: Codable {
    public var items : [ResponseModel]
    public var total : Int
}

/// `ResponseUserModel` is used for mapping server response.
open class ResponseUserModel: Codable {
    private enum CodingKeys: String, CodingKey {
        case url
        case code
        case createdTime = "created_on"
        case comment
    }

    public var url         : URL?
    public var code        : String!
    public var createdTime : Date?
    public var comment     : String?
}

/// `ResponseAccessTokenModel` is used for mapping server response.
open class ResponseLoginModel: Codable {
    public var access_token : String
    public var refresh_token : String
    public var expires_in : Int
    public var refresh_expires_in : Int
}

/// `ResponseTaskModel` is used for mapping server response.
open class ResponseTaskModel: Codable {
    public var task_id : String
}

/// `ResponseResultModel` is used for mapping server response.
open class ResponseResultModel: Codable {//TODO: add progress
    private enum CodingKeys: String, CodingKey {
        case status
        case visualizationStatus = "visualization_status"
        case visualization
        case visualizationType = "visualization_type"
    }
    
    public var status: String
    public var visualizationStatus: String?
    public var visualization: String?
    public var visualizationType: String?

    internal func visualizationСomputed() -> Bool {
        return visualizationStatus == "finished"
    }
    
    internal func visualizationFailed() -> Bool {
        return visualizationStatus == "failed" || visualizationStatus == "timed out"
    }
    
    internal func computed() -> Bool {
        return status == "finished"
    }
    
    internal func failed() -> Bool {
        return status == "failed" || status == "timed out"
    }
}
