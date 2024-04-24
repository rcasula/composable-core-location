import Combine
import ComposableArchitecture
import MapKit

extension LocalSearchClient {
  public static let live = LocalSearchClient(
    search: { request in
      Effect.run { send in
        do {
          let response = try await MKLocalSearch(request: request).start()
          await send(
            LocalSearchResponse.results(
              response.boundingRegion, response.mapItems.map(MapItem.init)))
        } catch let e {
          await send(LocalSearchResponse.error(e))
        }
      }
    })
}
