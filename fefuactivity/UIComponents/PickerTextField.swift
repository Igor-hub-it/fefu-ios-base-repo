import UIKit

class PickerTextField: CustomTextField {

    var code: Int = 0

    private let genders: [String] = ["Мужской", "Женский"]

    let pickerIndicator = UIButton(type: .custom)
    let genderPickerView = UIPickerView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        initTextField()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initTextField()
    }

    private func initTextField() {
        genderPickerView.dataSource = self
        genderPickerView.delegate = self

        self.inputView = genderPickerView
        
        pickerIndicator.setImage(UIImage(named: "RightArrow"), for: .normal)
        pickerIndicator.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)

        rightView = pickerIndicator
        rightViewMode = .always
    }
}

extension PickerTextField: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = genders[row]
        self.code = row
        self.resignFirstResponder()
    }
}
