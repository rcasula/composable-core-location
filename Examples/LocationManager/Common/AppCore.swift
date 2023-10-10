import ComposableArchitecture
import ComposableCoreLocation
import MapKit

public struct PointOfInterest: Equatable, Hashable {
  public let coordinate: CLLocationCoordinate2D
  public let subtitle: String?
  public let title: String?

  public init(
    coordinate: CLLocationCoordinate2D,
    subtitle: String?,
    title: String?
  ) {
    self.coordinate = coordinate
    self.subtitle = subtitle
    self.title = title
  }
}

extension LocalSearchClient: DependencyKey {
  static public var liveValue = LocalSearchClient.live
}

extension DependencyValues {
  var localSearchClient: LocalSearchClient {
    get { self[LocalSearchClient.self] }
    set { self[LocalSearchClient.self] = newValue }
  }
  
  var locationManager: LocationManager {
    get { self[LocationManager.self] }
    set { self[LocationManager.self] = newValue }
  }
}

extension LocationManager: DependencyKey {
  public static var liveValue = LocationManager.live
}


private struct LocationManagerId: Hashable {}
private struct CancelSearchId: Hashable {}

public struct AppReducer: Reducer {
  @Dependency(\.localSearchClient) var localSearchClient
  @Dependency(\.locationManager) var locationManager
  public struct State: Equatable {
    public var alert: AlertState<Action>?
    public var isRequestingCurrentLocation = false
    public var pointOfInterestCategory: MKPointOfInterestCategory?
    public var pointsOfInterest: [PointOfInterest] = []
    public var region: CoordinateRegion?

    public init(
      alert: AlertState<Action>? = nil,
      isRequestingCurrentLocation: Bool = false,
      pointOfInterestCategory: MKPointOfInterestCategory? = nil,
      pointsOfInterest: [PointOfInterest] = [],
      region: CoordinateRegion? = nil
    ) {
      self.alert = alert
      self.isRequestingCurrentLocation = isRequestingCurrentLocation
      self.pointOfInterestCategory = pointOfInterestCategory
      self.pointsOfInterest = pointsOfInterest
      self.region = region
    }

    public static let pointOfInterestCategories: [MKPointOfInterestCategory] = [
      .cafe,
      .museum,
      .nightlife,
      .park,
      .restaurant,
    ]
  }

  public enum Action: Equatable {
    case categoryButtonTapped(MKPointOfInterestCategory)
    case currentLocationButtonTapped
    case dismissAlertButtonTapped
    case localSearchResponse(LocalSearchResponse)
    case locationManager(LocationManager.Action)
    case onAppear
    case onDisappear
    case updateRegion(CoordinateRegion?)
  }
  
  public var body: some ReducerOf<Self> {
    return Reduce { state, action in
      switch action {
      case let .categoryButtonTapped(category):
        guard category != state.pointOfInterestCategory else {
          state.pointOfInterestCategory = nil
          state.pointsOfInterest = []
          return .cancel(id: CancelSearchId())
        }
        
        state.pointOfInterestCategory = category
        
        let request = MKLocalSearch.Request()
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category])
        if let region = state.region?.asMKCoordinateRegion {
          request.region = region
        }
        return localSearchClient.search(request).map(Action.localSearchResponse)
        
      case .currentLocationButtonTapped:

        switch locationManager.authorizationStatus() {
        case .notDetermined:
          state.isRequestingCurrentLocation = true
#if os(macOS)
          locationManager
            .requestAlwaysAuthorization()
#else
          locationManager
            .requestWhenInUseAuthorization()
          return .none
#endif
          
        case .restricted:
          state.alert = .init(title: TextState("Please give us access to your location in settings."))
          return .none
          
        case .denied:
          state.alert = .init(title: TextState("Please give us access to your location in settings."))
          return .none
          
        case .authorizedAlways, .authorizedWhenInUse:
          locationManager
            .requestLocation()
          return .none
          
        @unknown default:
          return .none
        }
      case .dismissAlertButtonTapped:
        state.alert = nil
        return .none
      case let .localSearchResponse(response):
        switch response {
        case let .results(_, items):
          state.pointsOfInterest = items.map { item in
            PointOfInterest(
              coordinate: item.placemark.coordinate,
              subtitle: item.placemark.subtitle,
              title: item.name
            )
          }
        case let .error(e):
          state.alert = .init(title: TextState(e.localizedDescription))
          return .none
        }
        
        return .none
      case let .locationManager(action):
        switch action {
        case .didChangeAuthorization(.authorizedAlways), .didChangeAuthorization(.authorizedWhenInUse):
          if state.isRequestingCurrentLocation {
            locationManager.requestLocation()
            return .none
          }
          return .none
        case .didChangeAuthorization(.denied):
          if state.isRequestingCurrentLocation {
            state.alert = .init(title: TextState("No Location"))
            state.isRequestingCurrentLocation = false
          }
          return .none
        case let .didUpdateLocations(locations):
          state.isRequestingCurrentLocation = false
          guard let location = locations.first else { return .none }
          state.region = CoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
          return .none
          
        default:
          return .none
        }
      case .onAppear:
        return locationManager.delegate().map(AppReducer.Action.locationManager)
      case .onDisappear:
        return .none
      case let .updateRegion(region):
        state.region = region
        
        guard
          let category = state.pointOfInterestCategory,
          let region = state.region?.asMKCoordinateRegion
        else { return .none }
        
        let request = MKLocalSearch.Request()
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category])
        request.region = region
        return localSearchClient.search(request).map(Action.localSearchResponse)
      }
    }
  }
}

extension PointOfInterest {
  // NB: CLLocationCoordinate2D doesn't conform to Equatable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.coordinate.latitude == rhs.coordinate.latitude
      && lhs.coordinate.longitude == rhs.coordinate.longitude
      && lhs.subtitle == rhs.subtitle
      && lhs.title == rhs.title
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(coordinate.latitude)
    hasher.combine(coordinate.longitude)
    hasher.combine(title)
    hasher.combine(subtitle)
  }
}
