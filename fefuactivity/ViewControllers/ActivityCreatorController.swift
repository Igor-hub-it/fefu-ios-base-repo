import UIKit
import MapKit
import CoreLocation

class ActivityCreatorController: ViewController {
    
    private var userLocationIdentifier: String = "DeviceLocation"
    private var started: Bool = false
    private var previousRoute: MKOverlay?
    private var startDate: Date = Date()
    private var distance: CLLocationDistance = CLLocationDistance()

    private let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        return manager
    }()

    private var userLocation: CLLocation? {
        didSet {
            if let deviceLocation = userLocation {
                let region = MKCoordinateRegion(center: deviceLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                
                mapView.setRegion(region, animated: true)

                guard started else {
                    return
                }
                userLocationHistory.append(deviceLocation)
                if oldValue != nil {
                    distance += deviceLocation.distance(from: oldValue!)
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Новая активность"
        self.tabBarController?.tabBar.isHidden = true

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        mapView.delegate = self
        mapView.showsUserLocation = true

        started = true
        startDate = Date()
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
            let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: userLocationIdentifier)

            let view = dequedView ?? MKAnnotationView(annotation: annotation, reuseIdentifier: userLocationIdentifier)

            view.image = UIImage(named: "UserLocation")
            return view
        }
        return nil
    }
}
