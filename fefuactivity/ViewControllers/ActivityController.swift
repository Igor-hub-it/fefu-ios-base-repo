import UIKit

struct ActivitiesTableModel {
    let date: String
    let activities: [ActivityCellModel]
}

class ActivityController: UIViewController {

    private var selectedSection: Int!
    private var selectedRow: Int!

    private var tableData: [ActivitiesTableModel] = []
    private var activitiesGroup: Int = 0 {
        didSet {
            fetch()
        }
    }

    @IBOutlet weak var activityTableView: UITableView!
    @IBOutlet weak var emptyStateView: UIStackView!
    @IBOutlet weak var segmentContainerView: UIView!
    @IBOutlet weak var segmentControlView: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        emptyStateView.isHidden = false
        activityTableView.isHidden = true

        activityTableView.dataSource = self
        activityTableView.delegate = self
        
        segmentContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        segmentContainerView.layer.borderWidth = 1
        
        fetch()
    }

    @IBAction func startButtonDidPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ActivityCreatorView", sender: self)
    }
    
    @IBAction func segmentControlDidChange(_ sender: Any) {
        activitiesGroup = segmentControlView.selectedSegmentIndex
    }
    
    private func fetch() {
        if activitiesGroup == 0 {
            fetchUserActivities()
        } else {
            fetchSocialActivities()
        }
    }
    
    private func fetchSocialActivities() {
        ActivityService.activities { activities in
            let activities: [ActivityCellModel] = activities.items.map { activity in
                let image = UIImage(systemName: "bicycle.circle.fill") ?? UIImage()
                let duration = activity.endsAt.timeIntervalSinceReferenceDate - activity.startsAt.timeIntervalSinceReferenceDate
                let distance = activity.geoTrack.distance(from: 0, to: activity.geoTrack.count)

                return ActivityCellModel(distance: String(distance),
                                         name: activity.user.name,
                                         duration: String(duration),
                                         type: activity.activityType.name,
                                         icon: image,
                                         startDate: activity.startsAt,
                                         stopDate: activity.endsAt)
            }
            let sortedActivities = activities.sorted { $0.startDate > $1.startDate }
            
            let grouppedActivities = Dictionary(grouping: sortedActivities, by: { self.callendarDate($0.startDate) }).sorted(by: {
                $0.key > $1.key
            })
            
            self.tableData = grouppedActivities.map { (date, activities) in
                return ActivitiesTableModel(date: date, activities: activities)
            }
            self.reloadTable()
        } reject: { err in
            DispatchQueue.main.async {
                self.segmentControlView.selectedSegmentIndex = 0
            }
        }
    }
    
    private func callendarDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM y"

        return formatter.string(from: date)
    }
    
    private func fetchUserActivities() {
        let context = FEFUCoreDataContainer.instance.context
        let request = CDActivity.fetchRequest()

        do {
            let rawActivities = try context.fetch(request)
            let activities: [ActivityCellModel] = rawActivities.map { activity in
                let image = UIImage(systemName: "bicycle.circle.fill") ?? UIImage()
                return ActivityCellModel(distance: activity.distance,
                                         name: "",
                                         duration: activity.duration,
                                         type: activity.type,
                                         icon: image,
                                         startDate: activity.startDate,
                                         stopDate: activity.stopDate)
            }
            let sortedActivities = activities.sorted { $0.startDate > $1.startDate }
            
            let grouppedActivities = Dictionary(grouping: sortedActivities, by: { callendarDate($0.startDate) }).sorted(by: {
                $0.key < $1.key
            })
            
            tableData = grouppedActivities.map { (date, activities) in
                return ActivitiesTableModel(date: date, activities: activities)
            }
            reloadTable()
        } catch {
            print(error)
        }
    }

    private func reloadTable() {
        DispatchQueue.main.async {
            self.activityTableView.reloadData()
            self.activityTableView.isHidden = self.tableData.isEmpty
            self.emptyStateView.isHidden = !self.tableData.isEmpty
        }
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
        self.performSegue(withIdentifier: "ActivityDetailsView", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ActivityDetailsView":
            let destination = segue.destination as! ActivityDetailsController
            destination.model = self.tableData[self.selectedSection].activities[self.selectedRow]
        case "ActivityCreatorView":
            let destination = segue.destination as! ActivityCreatorController
            destination.delegate = self
        default:
            break
        }
    }
}

extension ActivityController: ActivityCreatorDelegate {
    func activityDidCreate() {
        fetch()
    }
}
