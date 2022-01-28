import UIKit
import MapKit
import CoreLocation

protocol ActivityCreatorDelegate: AnyObject {
    func activityDidCreate()
}

class ActivityCreatorController: ViewController {

    var delegate: ActivityCreatorDelegate?
    
    private var activityCollectionData: [ActivityCollectionCellModel] = []
    private var activityType: ActivityCollectionCellModel?
    private var previousRoute: MKOverlay?
    private var partialDuration: TimeInterval = TimeInterval()
    private var timer: Timer = Timer()
    private var timerStart: Date?
    private var startDate: Date = Date()
    private var distance: CLLocationDistance = CLLocationDistance()
    private var duration: TimeInterval = TimeInterval()

    private let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        return manager
    }()

    private var userLocation: CLLocation? {
        didSet {
            if let userLocation = userLocation {
                let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                
                mapView.setRegion(region, animated: true)

                userLocationHistory.append(userLocation)
                if oldValue != nil {
                    distance += userLocation.distance(from: oldValue!)
                }
            }
        }
    }
    private var userLocationHistory: [CLLocation] = [] {
        didSet {
            let coordinates = userLocationHistory.map { $0.coordinate }

            let route = MKPolyline(coordinates: coordinates, count: coordinates.count)
            route.title = "Ваш маршрут"

            if previousRoute != nil {
                mapView.removeOverlay(previousRoute!)
            }
            mapView.addOverlay(route)
            previousRoute = route
        }
    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var typesCollection: UICollectionView!
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var proccessView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        typesCollection.delegate = self
        typesCollection.dataSource = self
        
        startView.layer.cornerRadius = 25
        startView.isHidden = false
        proccessView.layer.cornerRadius = 25
        proccessView.isHidden = true
        
        loadTypes()
    }
    
    @IBAction func startDidPress(_ sender: Any) {
        locationManager.startUpdatingLocation()

        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
        timer.tolerance = 0.1

        startDate = Date()
        timerStart = Date()

        startView.isHidden = true
        proccessView.isHidden = false
    }
    @IBAction func stopDidPress(_ sender: Any) {
        locationManager.stopUpdatingLocation()

        timer.invalidate()

        let coreData = FEFUCoreDataContainer.instance
        let activity = CDActivity(context: coreData.context)
        activity.duration = durationLabel.text!
        activity.distance = distanceLabel.text!
        activity.startDate = startDate
        activity.stopDate = Date()
        activity.type = activityType?.name ?? ""
        coreData.saveContext()

        delegate?.activityDidCreate()

        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func toggleDidPress(_ sender: UIButton) {
        if (sender.isSelected) {
            sender.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .normal)

            locationManager.startUpdatingLocation()

            timerStart = Date()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        } else {
            sender.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            
            locationManager.stopUpdatingLocation()
            userLocationHistory = []
            userLocation = nil

            duration += partialDuration
            partialDuration = TimeInterval()
            timer.invalidate()
        }
        sender.isSelected.toggle()
    }
    
    private func loadTypes() {
        ActivityService.types() { types in
            DispatchQueue.main.async {
                self.activityCollectionData = types
                self.typesCollection.reloadData()
            }
        } reject: { err in
            print(err)
        }
    }
    
    @objc func updateTimer() {
        let currentTime = Date().timeIntervalSince(timerStart!)

        partialDuration = currentTime

        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.zeroFormattingBehavior = .pad

        durationLabel.text = timeFormatter.string(from: currentTime + duration)
    }
}

extension ActivityCreatorController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else {
            return
        }

        userLocation = currentLocation
    }
}

extension ActivityCreatorController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.fillColor = UIColor.blue
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKUserLocation {
            let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: "DeviceLocationActive")

            let view = dequedView ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "DeviceLocationActive")

            view.image = UIImage(named: "UserLocation")
            return view
        }
        return nil
    }
}

extension ActivityCreatorController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activityCollectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellData = activityCollectionData[indexPath.row]

        let dequeuedCell = typesCollection.dequeueReusableCell(withReuseIdentifier: "ActivityCollectionCell", for: indexPath)

        guard let cell = dequeuedCell as? ActivityCollectionCellController else {
            return UICollectionViewCell()
        }

        cell.bind(cellData)
        if (cellData.id == activityType?.id) {
            cell.focus()
        }

        return cell
    }
}

extension ActivityCreatorController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as?
            ActivityCollectionCellController {
            cell.focus()
        }

        activityType = activityCollectionData[indexPath.row]
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ActivityCollectionCellController {
            cell.unfocus()
        }
    }
}
