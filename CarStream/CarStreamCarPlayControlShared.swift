//
//  CarStreamControlShared.swift
//  CarStream
//
//  Created by Codex on 24/06/2026.
//

import ActivityKit
import CoreFoundation
import Foundation

enum CarStreamControlCommand: String, Codable, CaseIterable {
    case openYouTube
    case scrollPageUp
    case scrollPageDown
    case fitVideo
    case fitVideoZoomIn
    case fitVideoZoomOut
    case playPause
    case youtubePreviousItem
    case youtubeNextItem
    case youtubeSelectItem
    case contentZoomIn
    case contentZoomOut
    case viewZoomIn
    case viewZoomOut
    case viewLeft
    case viewRight
    case viewUp
    case viewDown
    case applyLayout
    case saveLayout
    case reloadBrowser
    case bringBrowserToCarPlay
}

enum CarStreamControlBridge {
    static let appGroupIdentifier = "group.net.thomasdye.CarStream-docs"
    static let commandKey = "CarStreamControlCommand"
    static let commandTimestampKey = "CarStreamControlCommandTimestamp"
    static let notificationName = "group.net.thomasdye.CarStream-docs.CarStreamControlCommand"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    static func post(_ command: CarStreamControlCommand) {
        let defaults = sharedDefaults
        defaults?.set(command.rawValue, forKey: commandKey)
        defaults?.set(Date().timeIntervalSince1970, forKey: commandTimestampKey)
        defaults?.synchronize()

        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(notificationName as CFString),
            nil,
            nil,
            true
        )
    }

    static func consumePendingCommand() -> CarStreamControlCommand? {
        guard let rawValue = sharedDefaults?.string(forKey: commandKey),
              let command = CarStreamControlCommand(rawValue: rawValue) else {
            return nil
        }

        sharedDefaults?.removeObject(forKey: commandKey)
        return command
    }
}

struct CarStreamControlsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var lastUpdated: Date
    }

    var title: String
}
