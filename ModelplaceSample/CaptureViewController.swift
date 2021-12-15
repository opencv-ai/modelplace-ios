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

class CaptureViewController: UIViewController {
    var model: ResponseModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func libraryButtonPressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.image"]
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.mediaTypes = ["public.image"]
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func photoSelected(_ image: UIImage) {
        let vc = ProcessViewController.instantiateFromStoryboard("Main")
        vc.model = model
        vc.image = image
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CaptureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            photoSelected(image)
        }
    }
}
