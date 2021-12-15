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
import OAuthSwift

extension Storage {
    static var oauthCredential: OAuthSwiftCredential? {
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                customUserDefaults.set(encoded, forKey: kCredentialUserDefaultsKey)
            }
        } get {
            var credential: OAuthSwiftCredential? = nil

            if let encoded = customUserDefaults.value(forKey: kCredentialUserDefaultsKey) as? Data {
                if let decoded = try? JSONDecoder().decode(OAuthSwiftCredential.self, from: encoded) {
                    credential = decoded
                }
            }
            return credential
        }
    }
}
