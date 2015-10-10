//
//  LocationManagerDelegate.swift
//  TastyImitationKeyboard
//
//  Created by Li Jia'En, Nicholette on 10/10/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import Foundation

protocol LocationManagerDelegate {
    func LocationtManager(
        locationManager: LocationManager, didReceiveSearches searches: [String:String]
    )
}