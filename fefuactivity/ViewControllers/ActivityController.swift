import UIKit

struct ActivitiesTableModel {
    let date: String
    let activities: [ActivityCellModel]
}

class ActivityController: UIViewController {
    
    private var selectedSection: Int!
    private var selectedRow: Int!

    private let tableData: [ActivitiesTableModel] = [
        ActivitiesTableModel(
            date: "Вчера",
            activities: [ActivityCellModel(
                distance: "14.32 км",
                duration: "2 часа 46 минут",
                type: "Велосипед",
                icon: UIImage(systemName: "bicycle.circle.fill") ?? UIImage(),
                startTime: "14:49",
                stopTime: "16:31",
                timeAgo: "14 часов назад")
            ]),
        ActivitiesTableModel(
            date: "Май 2020 года",
            activities: [ActivityCellModel(
                distance: "14.32 км",
                duration: "2 часа 46 минут",
                type: "Велосипед",
                icon: UIImage(systemName: "bicycle.circle.fill") ?? UIImage(),
                startTime: "14:49",
                stopTime: "16:31",
                timeAgo: "14 часов назад")
            ])	
    ]

    @IBOutlet weak var activityTableView: UITableView!
    @IBOutlet weak var emptyStateView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        emptyStateView.isHidden = false
        activityTableView.isHidden = true

        activityTableView.dataSource = self
        activityTableView.delegate = self
    }

    @IBAction func startButtonDidPressed(_ sender: Any) {
        emptyStateView.isHidden = true
        activityTableView.isHidden = false
    }
}

extension ActivityController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITextView()
        header.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 0)
        header.font = .boldSystemFont(ofSize: 20)
        header.text = tableData[section].date
        header.backgroundColor = .clear
        return header
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].activities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let activityData = self.tableData[indexPath.section].activities[indexPath.row]
        
        let reusableCell = activityTableView.dequeueReusableCell(withIdentifier: "ActivityTableCell", for: indexPath)
        
        guard let cell = reusableCell as? ActivityCellController else {
            return UITableViewCell()
        }

        cell.bind(activityData)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.selectedSection = indexPath.section
        self.selectedRow = indexPath.row
        performSegue(withIdentifier: "ActivityDetailsView", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ActivityDetailsView":
            let destination = segue.destination as! ActivityDetailsController
            destination.model = self.tableData[self.selectedSection].activities[self.selectedRow]
        default:
            break
        }
    }
}
