import UIKit

class RegistrationController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: SecureTextField!
    @IBOutlet weak var passwordConfirmField: SecureTextField!
    @IBOutlet weak var genderField: PickerTextField!

    // MARK: - Mapping
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions
    @IBAction func registerDidPress(_ sender: Any) {
        let login = loginField.text ?? ""
        let name = nameField.text ?? ""
        let password = passwordField.text ?? ""
        let passwordConfirm = passwordConfirmField.text ?? ""
        let gender = genderField.code

        if password != passwordConfirm {
            print("Пароли не совпадают")
            return
        }
        let data = RegisterRequestModel(login: login, password: password, name: name, gender: gender)

        do {
            let reqBody = try AuthService.encoder.encode(data)
            AuthService.register(reqBody) { user in
                DispatchQueue.main.async {
                    UserDefaults.standard.set(user.token, forKey: "token")

                    self.performSegue(withIdentifier: "ActivityTabBar", sender: nil)
                }
            } reject: { err in
                print(err)
            }
        } catch {
            print(error)
        }
    }
}
