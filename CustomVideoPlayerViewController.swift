//
//  CustomVideoPlayerViewController.swift
//  CarStream
//
//  Created by Thomas Dye on 05/08/2024.
//

import UIKit
import AVFoundation
import MediaPlayer


class CustomVideoPlayerViewController: UIViewController {
//    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    private var remoteCommandTargets: [(command: MPRemoteCommand, target: Any)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        setupRemoteCommandCenter()
    }

    func setupPlayer(url: URL) {
        CarStreamVideoShared.shared.VideoPlayerForFile = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player:  CarStreamVideoShared.shared.VideoPlayerForFile )
        guard let playerLayer = playerLayer else { return }

        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        view.layer.insertSublayer(playerLayer, at: 0)

        // Set up Now Playing Info
        setupNowPlayingInfo()
    }

    func setupPlayer(player: AVPlayer) {
        CarStreamVideoShared.shared.VideoPlayerForFile  = player
        playerLayer = AVPlayerLayer(player:  CarStreamVideoShared.shared.VideoPlayerForFile )
        guard let playerLayer = playerLayer else { return }

        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resize
        view.layer.insertSublayer(playerLayer, at: 0)

        // Set up Now Playing Info
        setupNowPlayingInfo()
    }

    func setupPlayerlayer(playerLayer: AVPlayerLayer) {

        self.playerLayer = playerLayer

        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resize
        view.layer.insertSublayer(playerLayer, at: 0)

        // Set up Now Playing Info
        setupNowPlayingInfo()
//        setupRemoteTransportControls()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRemoteCommandCenter()
        CarStreamVideoShared.shared.VideoPlayerForFile?.play()
        updateNowPlayingInfo()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CarStreamVideoShared.shared.VideoPlayerForFile?.pause()
        tearDownRemoteCommandCenter()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }

    func setupRemoteCommandCenter() {
        tearDownRemoteCommandCenter()

        let commandCenter = MPRemoteCommandCenter.shared()

        let playTarget = commandCenter.playCommand.addTarget { [weak self] event in
            guard let self else { return .commandFailed }
            if  CarStreamVideoShared.shared.VideoPlayerForFile?.rate == 0.0 {
                CarStreamVideoShared.shared.VideoPlayerForFile?.play()
                self.updateNowPlayingInfo()
                return .success
            }
            return .commandFailed
        }
        remoteCommandTargets.append((commandCenter.playCommand, playTarget))

        let pauseTarget = commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self else { return .commandFailed }
            if  CarStreamVideoShared.shared.VideoPlayerForFile?.rate != 0.0 {
                CarStreamVideoShared.shared.VideoPlayerForFile?.pause()
                self.updateNowPlayingInfo()
                return .success
            }
            return .commandFailed
        }
        remoteCommandTargets.append((commandCenter.pauseCommand, pauseTarget))

        let toggleTarget = commandCenter.togglePlayPauseCommand.addTarget { [weak self] event in
            guard
                let self,
                CarStreamVideoShared.shared.VideoPlayerForFile != nil
            else { return .commandFailed }

            if  CarStreamVideoShared.shared.VideoPlayerForFile?.rate == 0.0 {
                CarStreamVideoShared.shared.VideoPlayerForFile?.play()
            } else {
                CarStreamVideoShared.shared.VideoPlayerForFile?.pause()
            }
            self.updateNowPlayingInfo()
            return .success
        }
        remoteCommandTargets.append((commandCenter.togglePlayPauseCommand, toggleTarget))

        let skipForwardTarget = commandCenter.skipForwardCommand.addTarget { [weak self] event in
            guard
                let self,
                CarStreamVideoShared.shared.VideoPlayerForFile != nil
            else { return .noSuchContent }

            self.skipForward()
            self.updateNowPlayingInfo()
            return .success
        }
        remoteCommandTargets.append((commandCenter.skipForwardCommand, skipForwardTarget))

        let skipBackwardTarget = commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            guard
                let self,
                CarStreamVideoShared.shared.VideoPlayerForFile != nil
            else { return .noSuchContent }

            self.skipBackward()
            self.updateNowPlayingInfo()
            return .success
        }
        remoteCommandTargets.append((commandCenter.skipBackwardCommand, skipBackwardTarget))

        commandCenter.skipForwardCommand.preferredIntervals = [15] // Skip forward 15 seconds
        commandCenter.skipBackwardCommand.preferredIntervals = [15] // Skip backward 15 seconds

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        let changePositionTarget = commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard
                let self = self,
                let player =  CarStreamVideoShared.shared.VideoPlayerForFile,
                let positionEvent = event as? MPChangePlaybackPositionCommandEvent
            else { return .commandFailed }

            let newTime = CMTimeMakeWithSeconds(positionEvent.positionTime, preferredTimescale: 1)
            player.seek(to: newTime) { _ in
                self.updateNowPlayingInfo()
            }
            return .success
        }
        remoteCommandTargets.append((commandCenter.changePlaybackPositionCommand, changePositionTarget))
    }

    private func tearDownRemoteCommandCenter() {
        remoteCommandTargets.forEach { registration in
            registration.command.removeTarget(registration.target)
        }
        remoteCommandTargets.removeAll()
    }

    func setupNowPlayingInfo() {
        guard let currentItem =  CarStreamVideoShared.shared.VideoPlayerForFile?.currentItem else { return }

        var nowPlayingInfo = [String: Any]()

        // Set title & artist (shows up in Control Center)
        nowPlayingInfo[MPMediaItemPropertyTitle] = "CarStream In Car Player"
        nowPlayingInfo[MPMediaItemPropertyArtist] = ""

        // Duration
        let durationInSeconds = CMTimeGetSeconds(currentItem.asset.duration)
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = durationInSeconds

        // Current playback time & rate
        let currentTimeInSeconds = CMTimeGetSeconds( CarStreamVideoShared.shared.VideoPlayerForFile?.currentTime() ?? .zero)
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTimeInSeconds
        // Rate of 1.0 = normal speed, 0.0 = paused
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] =  CarStreamVideoShared.shared.VideoPlayerForFile?.rate ?? 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }




    func updateNowPlayingInfo() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()

        if let player =  CarStreamVideoShared.shared.VideoPlayerForFile, let currentItem = player.currentItem {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    func skipForward() {
        guard let player =  CarStreamVideoShared.shared.VideoPlayerForFile , let currentItem = player.currentItem else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 15.0
        if newTime < CMTimeGetSeconds(currentItem.duration) {
            let time = CMTimeMakeWithSeconds(newTime, preferredTimescale: currentItem.asset.duration.timescale)
            player.seek(to: time)
        }
    }

    func skipBackward() {
        guard let player =  CarStreamVideoShared.shared.VideoPlayerForFile  else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = max(currentTime - 15.0, 0)
        let time = CMTimeMakeWithSeconds(newTime, preferredTimescale: player.currentItem?.asset.duration.timescale ?? 1)
        player.seek(to: time)
    }

    deinit {
        tearDownRemoteCommandCenter()
    }
}
