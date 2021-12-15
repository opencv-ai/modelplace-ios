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
import SwiftUI

class PickerViewController: UIViewController {
    var models: [ResponseModel]?
    @IBOutlet weak var pickButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var nextButton: UIButton!
    var selectedModel: ResponseModel? {
        didSet {
            pickButton.setTitle(selectedModel?.shortModelName, for: .normal)
            pickButton.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
            
            if selectedModel != nil {
                nextButton.isEnabled = true
                nextButton.backgroundColor = UIColor(named: "activeColor")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadModels()
    }
    
    func loadModels() {
        Modelplace.getModels { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let resultModels):
                self.models = resultModels.items
                if let index = self.models?.firstIndex(where: {$0.id == SettingsManager.selectedModelID}) {
                    self.selectedModel = self.models?[index]
                    self.pickerView.selectRow(index, inComponent: 0, animated: true)
                }
                self.pickerView.reloadAllComponents()
            case .failure(let error):
                let alert = UIAlertController(title: "Can't get models list", message: "Something bad happend", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in}))
                self.present(alert, animated: true, completion: nil)
                print(error)
            }
        }
    }
    
    @IBAction func pickButtonPressed(_ sender: Any) {
        pickerView.isHidden = false
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        let vc = CaptureViewController.instantiateFromStoryboard("Main")
        vc.model = selectedModel
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return models?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return models?[row].shortModelName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedModel = models?[row]
        SettingsManager.selectedModelID = models?[row].id
    }
}

