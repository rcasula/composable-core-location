import ComposableArchitecture
import CoreLocation
import XCTestDynamicOverlay

extension LocationManager {
  /// The failing implementation of the ``LocationManager`` interface. By default this
  /// implementation stubs all of its endpoints as functions that are unimplemented.
  ///
  /// This allows you to test an even deeper property of your features: that they use only the
  /// location manager endpoints that you specify and nothing else. This can be useful as a
  /// measurement of just how complex a particular test is. Tests that need to stub many endpoints
  /// are in some sense more complicated than tests that only need to stub a few endpoints. It's not
  /// necessarily a bad thing to stub many endpoints. Sometimes it's needed.
  ///
  /// As an example, to create a failing manager that simulates a location manager that has already
  /// authorized access to location, and when a location is requested it immediately responds
  /// with a mock location we can do something like this:
  ///
  /// ```swift
  /// // Send actions to this subject to simulate the location manager's delegate methods
  /// // being called.
  /// let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
  ///
  /// // The mock location we want the manager to say we are located at
  /// let mockLocation = Location(
  ///   coordinate: CLLocationCoordinate2D(latitude: 40.6501, longitude: -73.94958),
  ///   // A whole bunch of other properties have been omitted.
  /// )
  ///
  /// var manager = LocationManager.failing
  ///
  /// // Override any CLLocationManager endpoints your test invokes:
  /// manager.authorizationStatus = { .authorizedAlways }
  /// manager.delegate = { locationManagerSubject.eraseToEffect() }
  /// manager.locationServicesEnabled = { true }
  /// manager.requestLocation = {
  ///   .fireAndForget { locationManagerSubject.send(.didUpdateLocations([mockLocation])) }
  /// }
  /// ```
  public static let failing = Self(
    accuracyAuthorization: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.accuracyAuthorization'")
    },
    authorizationStatus: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.authorizationStatus'")
    },
    delegate: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.delegate'")
    },
    dismissHeadingCalibrationDisplay: {
      unimplemented(
        "A failing endpoint was accessed: 'LocationManager.dismissHeadingCalibrationDisplay'")
    },
    heading: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.heading'")
    },
    headingAvailable: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.headingAvailable'")
    },
    isRangingAvailable: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.isRangingAvailable'")
    },
    location: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.location'")
    },
    locationServicesEnabled: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.locationServicesEnabled'")
    },
    maximumRegionMonitoringDistance: {
      unimplemented(
        "A failing endpoint was accessed: 'LocationManager.maximumRegionMonitoringDistance'")
    },
    monitoredRegions: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.monitoredRegions'")
    },
    requestAlwaysAuthorization: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.requestAlwaysAuthorization'")
    },
    requestLocation: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.requestLocation'")
    },
    requestWhenInUseAuthorization: {
      unimplemented(
        "A failing endpoint was accessed: 'LocationManager.requestWhenInUseAuthorization'")
    },
    requestTemporaryFullAccuracyAuthorization: { _ in
      unimplemented(
        "A failing endpoint was accessed: 'LocationManager.requestTemporaryFullAccuracyAuthorization'"
      )
    },
    set: { _ in
      unimplemented("A failing endpoint was accessed: 'LocationManager.set'")
    },
    significantLocationChangeMonitoringAvailable: {
      unimplemented(
        "A failing endpoint was accessed: 'LocationManager.significantLocationChangeMonitoringAvailable'"
      )
    },
    startMonitoringForRegion: { _ in
      unimplemented("A failing endpoint was accessed: 'LocationManager.startMonitoringForRegion'")
    },
    startMonitoringSignificantLocationChanges: {
      unimplemented(
        "A failing endpoint was accessed: 'LocationManager.startMonitoringSignificantLocationChanges'"
      )
    },
    startMonitoringVisits: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.startMonitoringVisits'")
    },
    startUpdatingHeading: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.startUpdatingHeading'")
    },
    startUpdatingLocation: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.startUpdatingLocation'")
    },
    stopMonitoringForRegion: { _ in
      unimplemented("A failing endpoint was accessed: 'LocationManager.stopMonitoringForRegion'")
    },
    stopMonitoringSignificantLocationChanges: {
      unimplemented(
        "A failing endpoint was accessed: 'LocationManager.stopMonitoringSignificantLocationChanges'"
      )
    },
    stopMonitoringVisits: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.stopMonitoringVisits'")
    },
    stopUpdatingHeading: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.stopUpdatingHeading'")
    },
    stopUpdatingLocation: {
      unimplemented("A failing endpoint was accessed: 'LocationManager.stopUpdatingLocation'")
    }
  )
}
