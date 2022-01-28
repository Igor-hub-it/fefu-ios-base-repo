import UIKit

class ChangePasswordController: UITableViewController {

    @IBAction func saveDidPress(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
