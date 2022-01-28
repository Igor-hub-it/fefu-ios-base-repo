import UIKit

struct ActivityCellModel {
    let distance: String
    let name: String
    let duration: String
    let type: String
    let icon: UIImage
    let startDate: Date
    let stopDate: Date
    
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        return formatter.localizedString(for: startDate, relativeTo: Date())
    }
    func startTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        return formatter.string(from: startDate)
    }
    func stopTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        return formatter.string(from: stopDate)
    }
}

class ActivityCellController: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var typeIcon: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        cellView.layer.cornerRadius = 10
    }

    func bind(_ model: ActivityCellModel) {
        distanceLabel.text = model.distance
        durationLabel.text = model.duration
        typeIcon.image = model.icon
        typeLabel.text = model.type
        timeAgoLabel.text = model.timeAgo()
        nameLabel.text = model.name.count != 0 ? "@\(model.name)" : ""
    }
}
