//
//  TYLocationManagerDelegate.swift
//  TastyImitationKeyboard
//
//  Created by Abdulla Contractor on 10/10/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import Foundation

protocol TYLocationManagerDelegate {
    func LocationManager(locationManager: TYLocationManager, didReceiveSearches searches: [String:String])

    func LocationManager(locationManager: TYLocationManager, didReceiveCoordinates coordinates: [String])
    
}