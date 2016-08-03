//
//  ViewController.swift
//  Cupertino
//
//  Created by Koby Samuel on 12/1/15.
//  Copyright © 2015 Koby Samuel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
	@IBOutlet weak var map: MKMapView!
	@IBOutlet weak var waitView: UIView!
	@IBOutlet weak var distanceView: UIView!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var directionArrow: UIImageView!
	var recentLocation: CLLocation!
	let locMan: CLLocationManager = CLLocationManager()
	let kCupertinoLatitude: CLLocationDegrees = 37.3229978
	let kCupertinoLongitude: CLLocationDegrees = -122.0321823
	let kDeg2Rad: Double = 0.0174532925
	let kRad2Deg: Double = 57.2957795
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		locMan.delegate = self
		locMan.desiredAccuracy = kCLLocationAccuracyThreeKilometers
		locMan.distanceFilter = 1609
		locMan.requestWhenInUseAuthorization()
		locMan.startUpdatingLocation()
		if(CLLocationManager.headingAvailable()) {
			locMan.headingFilter = 10 //degrees
			locMan.startUpdatingHeading()
		}
	}

	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		if(error.code == CLError.Denied.rawValue) {
			locMan.stopUpdatingLocation()
		}
		else {
			waitView.hidden = true
			distanceView.hidden = false
		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let newLocation: CLLocation = locations[0] as CLLocation
		if(newLocation.horizontalAccuracy >= 0) {
			let mapRegion: MKCoordinateRegion = MKCoordinateRegion(center: (newLocation.coordinate), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
			self.map.setRegion(mapRegion, animated: true)
			var mapPlacemark = MKPointAnnotation()
			mapPlacemark.coordinate = newLocation.coordinate			
			self.map.addAnnotation(mapPlacemark)
			recentLocation = newLocation
			let Cupertino: CLLocation = CLLocation(latitude: kCupertinoLatitude, longitude: kCupertinoLongitude)
			let delta: CLLocationDistance = Cupertino.distanceFromLocation(newLocation)
			let miles: Double = (delta * 0.000621371) + 0.5 // meters to rounded miles
			if(miles < 3) {
				locMan.stopUpdatingLocation()
				locMan.stopUpdatingHeading()
				distanceLabel.text = "Enjoy the\nMothership!"
			}
			else {
				let commaDelimited: NSNumberFormatter = NSNumberFormatter()
				commaDelimited.numberStyle = NSNumberFormatterStyle.DecimalStyle
				distanceLabel.text = commaDelimited.stringFromNumber(miles)! + " miles to the Mothership!"
			}
			waitView.hidden = true
			distanceView.hidden = false
		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		if(recentLocation != nil && newHeading.headingAccuracy >= 0) {
			let Cupertino: CLLocation = CLLocation(latitude: kCupertinoLatitude, longitude: kCupertinoLongitude)
			let course: Double = headingToLocation(Cupertino.coordinate, current: recentLocation.coordinate)
			let delta: Double = newHeading.trueHeading - course
			if(abs(delta) <= 10) {
				directionArrow.image = UIImage(named: "up_arrow")
			}
			else {
				switch delta {
				case let delta where delta > 180 || delta > -180:
					directionArrow.image = UIImage(named: "right_arrow")
				default:
					directionArrow.image = UIImage(named: "left_arrow")
				}
			}
			directionArrow.hidden = false
		}
		else {
			directionArrow.hidden = true
		}
	}
	
	func headingToLocation(desired: CLLocationCoordinate2D, current: CLLocationCoordinate2D) -> Double {
		let lat1: Double = current.latitude * kDeg2Rad
		let lon1: Double = current.longitude
		let lat2: Double = desired.latitude * kDeg2Rad
		let lon2: Double = desired.longitude
		let dlon: Double = (lon2 - lon1) * kDeg2Rad
		let x: Double = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlon)
		let y: Double = sin(dlon) * cos(lat2)
		var heading: Double = atan2(y, x)
		heading *= kRad2Deg
		heading += 360.0
		heading = fmod(heading, 360.0)
		return heading
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
}

