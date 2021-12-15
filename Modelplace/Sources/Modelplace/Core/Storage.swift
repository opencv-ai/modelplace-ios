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

let kCredentialUserDefaultsKey: String = "client_auth_credential"
let kUserDefaultsKey: String = "user_id"

public var customUserDefaults = UserDefaults.standard

internal class Storage {
    private static var _user: ResponseUserModel? = nil
    static var user: ResponseUserModel? {
        set {
            _user = newValue
            if let encoded = try? JSONEncoder().encode(newValue) {
                customUserDefaults.set(encoded, forKey: kUserDefaultsKey)
            }
        } get {
            if let value = _user {
                return value
            }

            if let encoded = customUserDefaults.value(forKey: kUserDefaultsKey) as? Data {
                if let decoded = try? JSONDecoder().decode(ResponseUserModel.self, from: encoded) {
                    _user = decoded
                }
            }

            return _user
        }
    }
}
