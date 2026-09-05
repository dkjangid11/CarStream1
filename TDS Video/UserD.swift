//
//  UserD.swift
//  CarStream
//
//  Created by Thomas Dye on 25/03/2025.
//



extension UserDefaults {
    @objc dynamic var TDVideoSharedURL: String {
        return string(forKey: "TDVideo-SharedURL")!
    }
}



import UIKit

class CarStreamVideoURlFromOutSideOFAppListener {
    static let shared = CarStreamVideoURlFromOutSideOFAppListener()

    private  let notificationName = "group.net.thomasdye.CarStream-docs.TDVideo-SharedURL"
    private  let sharedDefaults = UserDefaults(suiteName: "group.net.thomasdye.CarStream-docs")

    var onUpdate: ((String) -> Void)?

    private init() {
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            { (_, observer, _, _, _) in
                guard let observer = observer else { return }
                let instance = Unmanaged<CarStreamVideoURlFromOutSideOFAppListener>.fromOpaque(observer).takeUnretainedValue()
                instance.defaultsChanged()
            },
            notificationName as CFString,
            nil,
            .deliverImmediately
        )
    }

    deinit {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            CFNotificationName(notificationName as CFString),
            nil
        )
    }

    private func defaultsChanged() {
        let newValue = sharedDefaults?.string(forKey: "TDVideo-SharedURL") ?? ""
        DispatchQueue.main.async {
            self.onUpdate?(newValue)
        }
    }
}
