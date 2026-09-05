//
//  CarStreamControlCommandCenter.swift
//  CarStream
//
//  Created by Codex on 24/06/2026.
//

import CoreFoundation
import Foundation
import UIKit

final class CarStreamControlCommandCenter {
    static let shared = CarStreamControlCommandCenter()

    private var isStarted = false
    private let viewMoveStep: CGFloat = 16
    private let pageScrollStep: CGFloat = 220
    private let fitZoomStep = 0.03
    private var lastPlayPauseRunTime: CFAbsoluteTime = 0

    private init() {}

    func start() {
        guard !isStarted else { return }
        isStarted = true

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            { _, observer, _, _, _ in
                guard let observer else { return }
                let commandCenter = Unmanaged<CarStreamControlCommandCenter>
                    .fromOpaque(observer)
                    .takeUnretainedValue()
                commandCenter.handlePendingCommand()
            },
            CarStreamControlBridge.notificationName as CFString,
            nil,
            .deliverImmediately
        )

        handlePendingCommand()
    }

    func run(_ command: CarStreamControlCommand) {
        DispatchQueue.main.async {
            let webController = CustomWebViewController.shared

            switch command {
            case .openYouTube:
                webController.loadURL(CustomWebViewController.youtubeURL)
                CarStreamVideoShared.shared.CarPlayComp?(
                    .init(type: .web, URL: CustomWebViewController.youtubeURL, reloadWeb: false)
                )
            case .scrollPageUp:
                webController.scrollBy(x: 0, y: -self.pageScrollStep)
            case .scrollPageDown:
                webController.scrollBy(x: 0, y: self.pageScrollStep)
            case .fitVideo:
                webController.fitYouTubeVideoToCurrentView()
            case .fitVideoZoomIn:
                webController.adjustYouTubeFitScale(by: self.fitZoomStep)
                webController.fitYouTubeVideoToCurrentView()
            case .fitVideoZoomOut:
                webController.adjustYouTubeFitScale(by: -self.fitZoomStep)
                webController.fitYouTubeVideoToCurrentView()
            case .playPause:
                let now = CFAbsoluteTimeGetCurrent()
                guard now - self.lastPlayPauseRunTime > 0.6 else {
                    print("CarStream CarPlay ignored repeated play/pause command")
                    return
                }
                self.lastPlayPauseRunTime = now
                webController.toggleCurrentPageVideoPlayback()
            case .youtubePreviousItem:
                webController.focusPreviousYouTubeItem()
            case .youtubeNextItem:
                webController.focusNextYouTubeItem()
            case .youtubeSelectItem:
                webController.selectFocusedYouTubeItem()
            case .contentZoomIn:
                webController.resizeContent(by: 1.1)
            case .contentZoomOut:
                webController.resizeContent(by: 0.9)
            case .viewZoomIn:
                webController.resize(by: 1.05)
            case .viewZoomOut:
                webController.resize(by: 0.95)
            case .viewLeft:
                webController.moveHorizontally(by: -self.viewMoveStep)
            case .viewRight:
                webController.moveHorizontally(by: self.viewMoveStep)
            case .viewUp:
                webController.moveVertically(by: -self.viewMoveStep)
            case .viewDown:
                webController.moveVertically(by: self.viewMoveStep)
            case .applyLayout:
                _ = webController.applySavedSettingsForCurrentDomain()
            case .saveLayout:
                webController.saveViewSettings()
            case .reloadBrowser:
                webController.reloadPage()
            case .bringBrowserToCarPlay:
                CarStreamVideoShared.shared.CarPlayComp?(.init(type: .web, URL: webController.webView?.url, reloadWeb: false))
            }
        }
    }

    private func handlePendingCommand() {
        guard let command = CarStreamControlBridge.consumePendingCommand() else { return }
        run(command)
    }

    deinit {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            CFNotificationName(CarStreamControlBridge.notificationName as CFString),
            nil
        )
    }
}
