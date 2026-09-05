//
//  CarStreamControlsLiveActivityManager.swift
//  CarStream
//
//  Created by Codex on 24/06/2026.
//

import ActivityKit
import Foundation

@available(iOS 16.1, *)
enum CarStreamControlsLiveActivityManager {
    @MainActor
    static func start() throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw LiveActivityError.notAllowed
        }

        guard Activity<CarStreamControlsAttributes>.activities.isEmpty else { return }

        let attributes = CarStreamControlsAttributes(title: "CarPlay Controls")
        let content = ActivityContent(
            state: CarStreamControlsAttributes.ContentState(lastUpdated: Date()),
            staleDate: nil
        )

        _ = try Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )
    }

    @MainActor
    static func stopAll() async {
        for activity in Activity<CarStreamControlsAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    enum LiveActivityError: LocalizedError {
        case notAllowed

        var errorDescription: String? {
            "Live Activities are not enabled for this app."
        }
    }
}
