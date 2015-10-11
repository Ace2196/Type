//
//  LocationManagerDelegate.swift
//  TastyImitationKeyboard
//
//  Created by Li Jia'En, Nicholette on 10/10/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import Foundation

protocol LocationManagerDelegate {
    func LocationManager(
        locationManager: LocationManager, didReceiveSearches searches: [String:String]
    )
    
    func LocationManager(
        locationManager: LocationManager, didReceiveCoordinates coordinates: [String]
    )
}