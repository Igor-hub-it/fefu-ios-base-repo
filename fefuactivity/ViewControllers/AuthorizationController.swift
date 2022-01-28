import UIKit

class AuthorizationController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var loginField: CustomTextField!
    @IBOutlet weak var passwordField: SecureTextField!

    // MARK: - Mapping
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions
    @IBAction func authorizeDidPress(_ sender: Any) {
        let login = loginField.text ?? ""
        let password = passwordField.text ?? ""

        let loginData = LoginRequestModel(login: login, password: password)

        do {
            let data = try AuthService.encoder.encode(loginData)
            AuthService.login(data) { auth in
                DispatchQueue.main.async {
                    UserDefaults.standard.set(auth.token, forKey: "token")
 
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
