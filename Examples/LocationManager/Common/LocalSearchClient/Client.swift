import ComposableArchitecture
import MapKit

public enum LocalSearchResponse: Equatable {
  public static func == (lhs: LocalSearchResponse, rhs: LocalSearchResponse) -> Bool {
    switch (lhs, rhs) {
    case (.results(let lhsRegion, let lhsItems), .results(let rhsRegion, let rhsItems)):
      return lhsRegion.center.latitude == rhsRegion.center.latitude
        && lhsRegion.center.longitude == rhsRegion.center.longitude
        && lhsRegion.span.latitudeDelta == rhsRegion.span.latitudeDelta
        && lhsRegion.span.longitudeDelta == rhsRegion.span.longitudeDelta
        && lhsItems == rhsItems
    case (.error, .error): return true
    case (_, _): return false
    }
  }

  case results(MKCoordinateRegion, [MapItem])
  case error(Error)
}

public struct LocalSearchClient: Sendable {
  public var search: @Sendable (MKLocalSearch.Request) -> Effect<LocalSearchResponse>

  public struct Error: Swift.Error, Equatable {
    public init() {}
  }
}
