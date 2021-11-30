import UIKit

struct ActivityCellModel {
    let distance: String
    let duration: String
    let type: String
    let icon: UIImage
    let startTime: String
    let stopTime: String
    let timeAgo: String
}

class ActivityCellController: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var typeIcon: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        cellView.layer.cornerRadius = 10
    }

    func bind(_ model: ActivityCellModel) {
        distanceLabel.text = model.distance
        durationLabel.text = model.duration
        typeIcon.image = model.icon
        typeLabel.text = model.type
        timeAgoLabel.text = model.timeAgo
    }
}
