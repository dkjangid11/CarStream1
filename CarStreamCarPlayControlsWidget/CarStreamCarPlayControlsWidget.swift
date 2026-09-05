//
//  CarStreamControlsWidget.swift
//  CarStreamControlsWidget
//
//  Created by Codex on 24/06/2026.
//

import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct CarStreamControlIntent: AppIntent {
    static var title: LocalizedStringResource = "CarPlay Control"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Command")
    var command: String

    init() {
        command = CarStreamControlCommand.fitVideo.rawValue
    }

    init(_ command: CarStreamControlCommand) {
        self.command = command.rawValue
    }

    func perform() async throws -> some IntentResult {
        if let command = CarStreamControlCommand(rawValue: command) {
            CarStreamControlBridge.post(command)
        }

        return .result()
    }
}

struct CarStreamControlsWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CarStreamControlsAttributes.self) { context in
            LockScreenControlsView()
                .activityBackgroundTint(.black.opacity(0.88))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ControlButton(command: .viewLeft, systemImage: "chevron.left", title: "Left")
                    ControlButton(command: .viewRight, systemImage: "chevron.right", title: "Right")
                }

                DynamicIslandExpandedRegion(.trailing) {
                    ControlButton(command: .viewUp, systemImage: "chevron.up", title: "Up")
                    ControlButton(command: .viewDown, systemImage: "chevron.down", title: "Down")
                }

                DynamicIslandExpandedRegion(.center) {
                    HStack(spacing: 8) {
                        ControlButton(command: .fitVideo, systemImage: "rectangle.inset.filled", title: "Fit")
                        ControlButton(command: .fitVideoZoomIn, systemImage: "plus.magnifyingglass", title: "Video +")
                        ControlButton(command: .fitVideoZoomOut, systemImage: "minus.magnifyingglass", title: "Video -")
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 8) {
                        ControlButton(command: .contentZoomIn, systemImage: "textformat.size.larger", title: "Content +")
                        ControlButton(command: .contentZoomOut, systemImage: "textformat.size.smaller", title: "Content -")
                        ControlButton(command: .viewZoomIn, systemImage: "arrow.up.left.and.arrow.down.right", title: "View +")
                        ControlButton(command: .viewZoomOut, systemImage: "arrow.down.right.and.arrow.up.left", title: "View -")
                    }
                }
            } compactLeading: {
                ControlButton(command: .fitVideo, systemImage: "rectangle.inset.filled", title: "Fit")
            } compactTrailing: {
                ControlButton(command: .contentZoomIn, systemImage: "plus.magnifyingglass", title: "Zoom")
            } minimal: {
                Image(systemName: "car")
            }
        }
    }
}

private struct LockScreenControlsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("CarPlay Controls")
                    .font(.headline)
                Spacer()
                ControlButton(command: .reloadBrowser, systemImage: "arrow.clockwise", title: "Reload")
            }

            HStack(spacing: 8) {
                ControlButton(command: .fitVideo, systemImage: "rectangle.inset.filled", title: "Fit")
                ControlButton(command: .fitVideoZoomIn, systemImage: "plus.magnifyingglass", title: "Video +")
                ControlButton(command: .fitVideoZoomOut, systemImage: "minus.magnifyingglass", title: "Video -")
                ControlButton(command: .contentZoomIn, systemImage: "textformat.size.larger", title: "Content +")
                ControlButton(command: .contentZoomOut, systemImage: "textformat.size.smaller", title: "Content -")
                ControlButton(command: .viewZoomIn, systemImage: "arrow.up.left.and.arrow.down.right", title: "View +")
                ControlButton(command: .viewZoomOut, systemImage: "arrow.down.right.and.arrow.up.left", title: "View -")
            }

//            HStack(spacing: 8) {
//              
//            }

            HStack(spacing: 8) {
                ControlButton(command: .viewLeft, systemImage: "chevron.left", title: "Left")
                ControlButton(command: .viewUp, systemImage: "chevron.up", title: "Up")
                ControlButton(command: .viewDown, systemImage: "chevron.down", title: "Down")
                ControlButton(command: .viewRight, systemImage: "chevron.right", title: "Right")
                ControlButton(command: .applyLayout, systemImage: "rectangle.and.hand.point.up.left", title: "Apply")
                ControlButton(command: .saveLayout, systemImage: "square.and.arrow.down", title: "Save")
            }
        }
        .foregroundStyle(.white)
        .padding(.vertical, 2)
    }
}

private struct ControlButton: View {
    let command: CarStreamControlCommand
    let systemImage: String
    let title: String

    var body: some View {
        Button(intent: CarStreamControlIntent(command)) {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.bordered)
        .tint(.white.opacity(0.18))
    }
}

@main
struct CarStreamControlsWidgetBundle: WidgetBundle {
    var body: some Widget {
        CarStreamControlsWidget()
    }
}

#if DEBUG
@available(iOS 16.2, *)
private extension CarStreamControlsAttributes {
    static var preview: CarStreamControlsAttributes {
        CarStreamControlsAttributes(title: "CarPlay Controls")
    }
}

@available(iOS 16.2, *)
private extension CarStreamControlsAttributes.ContentState {
    static var preview: CarStreamControlsAttributes.ContentState {
        CarStreamControlsAttributes.ContentState(lastUpdated: Date())
    }
}

@available(iOS 17.0, *)
#Preview("Live Activity", as: .content, using: CarStreamControlsAttributes.preview) {
    CarStreamControlsWidget()
} contentStates: {
    CarStreamControlsAttributes.ContentState.preview
}

@available(iOS 17.0, *)
#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: CarStreamControlsAttributes.preview) {
    CarStreamControlsWidget()
} contentStates: {
    CarStreamControlsAttributes.ContentState.preview
}

@available(iOS 17.0, *)
#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: CarStreamControlsAttributes.preview) {
    CarStreamControlsWidget()
} contentStates: {
    CarStreamControlsAttributes.ContentState.preview
}
#endif
