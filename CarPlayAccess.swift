//
//  CarPlayAccess.swift
//  CarStream
//
//  Created by Thomas Dye on 16/04/2025.
//


import UIKit

class CarStreamAccess {
    static var shared = CarStreamAccess()

    private let settingsKey = "ShowCarStreamSettings"

    var ShowCarStreamSettings: Bool = true
    var DisableIsStationary: Bool {
        get {
            UserDefaults.standard.bool(forKey: settingsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: settingsKey)
        }
    }


    private init() {
        ShowCarStreamSettings = true
        UserDefaults.standard.set(true, forKey: settingsKey)
    }

    func CheckIfShowCarPlaySettings() {
        ShowCarStreamSettings = true
        UserDefaults.standard.set(true, forKey: settingsKey)
    }

}

struct CarplaySettingsResponse: Decodable {
    let showCarplaySettings: Bool?
}
