import UIKit

class ProfileController: UITableViewController {
    private var user: UserModel? {
        didSet {
            nameLabel?.text = user?.name
            loginLabel?.text = user?.login
            genderLabel?.text = user?.gender.name
        }
    }

    @IBOutlet var profileTable: UITableView! {
        didSet {
            profileTable.delegate = self
        }
    }
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        UserService.profile { user in
            DispatchQueue.main.async {
                self.user = user
            }
        } reject: { err in
            print(err)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Профиль"
    }

    @IBAction func logoutDidPress(_ sender: Any) {
        AuthService.logout() {} reject: { err in
            print(err)
        }
    }
}
