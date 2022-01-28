import UIKit

struct ActivityCollectionCellModel: Decodable {
    let id: Int
    let name: String
}

class ActivityCollectionCellController: UICollectionViewCell {

    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        unfocus()
    }

    func bind(_ model: ActivityCollectionCellModel) {
        unfocus()
        typeLabel.text = model.name
        typeImage.image = UIImage(named: "PeopleBicycles") ?? UIImage()
    }

    func focus() {
        typeView.layer.borderColor = UIColor.systemBlue.cgColor
        typeView.layer.borderWidth = 2
    }

    func unfocus() {
        typeView?.layer.cornerRadius = 14
        typeView?.layer.borderColor = UIColor.lightGray.cgColor
        typeView?.layer.borderWidth = 1
    }
}
