import UIKit

class ActivityTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        initTabBar()
    }
        
    func initTabBar() {
        let activityNC = UINavigationController(rootViewController: ActivityController())
        let profileNC = UINavigationController(rootViewController: ProfileController())

        activityNC.tabBarItem.title = "Активности"
        activityNC.tabBarItem.image = UIImage(systemName: "circle")

        profileNC.tabBarItem.title = "Профиль"
        profileNC.tabBarItem.image = UIImage(systemName: "circle")

        self.setViewControllers([activityNC, profileNC], animated: true)

        modalPresentationStyle = .overFullScreen
    }
}
