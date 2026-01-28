import SwiftUI
import AppKit

class FloatingWindowController: ObservableObject {
    private var window: NSWindow?
    private var hostingView: NSHostingView<AnyView>?

    private let positionKey = "focusfriend.floatingWindowPosition"

    @Published var isVisible: Bool = false

    func show<Content: View>(content: Content) {
        DispatchQueue.main.async {
            if self.window == nil {
                self.createWindow(content: content)
            }
            self.window?.orderFront(nil)
            self.isVisible = true
        }
    }

    func hide() {
        DispatchQueue.main.async {
            self.savePosition()
            self.window?.orderOut(nil)
            self.isVisible = false
        }
    }

    func toggle<Content: View>(content: Content) {
        if isVisible {
            hide()
        } else {
            show(content: content)
        }
    }

    private func createWindow<Content: View>(content: Content) {
        let hostingView = NSHostingView(rootView: AnyView(content))
        hostingView.setFrameSize(hostingView.fittingSize)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 50),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.contentView = hostingView
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.hasShadow = false

        // Restore or set default position
        if let savedPosition = loadPosition() {
            window.setFrameOrigin(savedPosition)
        } else {
            // Default: top center of main screen
            if let screen = NSScreen.main {
                let screenFrame = screen.visibleFrame
                let x = screenFrame.midX - 150
                let y = screenFrame.maxY - 80
                window.setFrameOrigin(NSPoint(x: x, y: y))
            }
        }

        self.window = window
        self.hostingView = hostingView
    }

    func updateContent<Content: View>(content: Content) {
        hostingView?.rootView = AnyView(content)
        if let fittingSize = hostingView?.fittingSize, fittingSize.width > 0, fittingSize.height > 0 {
            hostingView?.setFrameSize(fittingSize)
            // Also update the window frame to match, preserving position
            if let window = window {
                var frame = window.frame
                frame.size = fittingSize
                window.setFrame(frame, display: true)
            }
        }
    }

    private func savePosition() {
        guard let window = window else { return }
        let origin = window.frame.origin
        let dict = ["x": origin.x, "y": origin.y]
        UserDefaults.standard.set(dict, forKey: positionKey)
    }

    private func loadPosition() -> NSPoint? {
        guard let dict = UserDefaults.standard.dictionary(forKey: positionKey),
              let x = dict["x"] as? CGFloat,
              let y = dict["y"] as? CGFloat else {
            return nil
        }

        let point = NSPoint(x: x, y: y)

        // Validate position is on a visible screen
        let isOnScreen = NSScreen.screens.contains { screen in
            screen.frame.contains(point)
        }

        return isOnScreen ? point : nil
    }
}
