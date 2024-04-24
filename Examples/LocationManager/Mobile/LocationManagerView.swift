import Combine
import ComposableArchitecture
import ComposableCoreLocation
import MapKit
import SwiftUI

private let readMe = """
  This application demonstrates how to work with CLLocationManager for getting the user's current \
  location, and MKLocalSearch for searching points of interest on the map.

  Zoom into any part of the map and tap a category to search for points of interest nearby. The \
  markers are also updated live if you drag the map around.
  """

struct LocationManagerView: View {
  @Environment(\.colorScheme) var colorScheme
  let store: StoreOf<AppReducer>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ZStack {
        MapView(
          pointsOfInterest: viewStore.pointsOfInterest,
          region: viewStore.binding(get: { $0.region }, send: { .updateRegion($0) })
        )
        .edgesIgnoringSafeArea([.all])

        VStack(alignment: .trailing) {
          Spacer()

          Button(action: {
            viewStore.send(.currentLocationButtonTapped)
          }) {
            Image(systemName: "location")
              .foregroundColor(Color.white)
              .frame(width: 60, height: 60)
              .background(Color.secondary)
              .clipShape(Circle())
              .padding([.trailing], 16)
              .padding([.bottom], 16)
          }

          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
              ForEach(AppReducer.State.pointOfInterestCategories, id: \.rawValue) { category in
                Button(category.displayName) { viewStore.send(.categoryButtonTapped(category)) }
                  .padding([.all], 16)
                  .background(
                    category == viewStore.pointOfInterestCategory ? Color.blue : Color.secondary
                  )
                  .foregroundColor(.white)
                  .cornerRadius(8)
              }
            }
            .padding([.leading, .trailing])
            .padding([.bottom], 32)
          }
        }
      }.onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

struct ContentView: View {
  var body: some View {
    NavigationView {
      Form {
        Section(
          header: Text(readMe)
            .font(.body)
            .padding([.bottom])
        ) {
          NavigationLink(
            "Go to demo",
            destination: LocationManagerView(
              store: Store(initialState: AppReducer.State()) { AppReducer() }
            )
          )
        }
      }
      .navigationBarTitle("Location Manager")
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
