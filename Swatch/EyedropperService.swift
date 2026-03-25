import AppKit
import Foundation

class EyedropperService {
    static let shared = EyedropperService()

    private var overlayWindow: NSWindow?
    private var magnifierView: MagnifierView?
    private var mouseMonitor: Any?
    private var keyMonitor: Any?
    private var onColorPicked: ((SwatchColor) -> Void)?
    private var onCancel: (() -> Void)?

    private init() {}

    func startPicking(onColorPicked: @escaping (SwatchColor) -> Void, onCancel: @escaping () -> Void) {
        self.onColorPicked = onColorPicked
        self.onCancel = onCancel

        guard let mainScreen = NSScreen.main else {
            onCancel()
            return
        }

        let overlayWindow = NSWindow(
            contentRect: mainScreen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        overlayWindow.level = .screenSaver
        overlayWindow.isOpaque = false
        overlayWindow.backgroundColor = NSColor.black.withAlphaComponent(0.001)
        overlayWindow.ignoresMouseEvents = false
        overlayWindow.acceptsMouseMovedEvents = true
        overlayWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let magnifierView = MagnifierView(frame: NSRect(x: 0, y: 0, width: 110, height: 110))
        overlayWindow.contentView = magnifierView
        self.magnifierView = magnifierView

        overlayWindow.makeKeyAndOrderFront(nil)
        self.overlayWindow = overlayWindow

        updateMagnifier(at: NSEvent.mouseLocation)

        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged]) { [weak self] event in
            self?.handleMouseMoved(event)
        }

        keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 {
                self?.cancel()
            }
        }
    }

    private func handleMouseMoved(_ event: NSEvent) {
        let point = NSEvent.mouseLocation
        updateMagnifier(at: point)
    }

    private func updateMagnifier(at point: NSPoint) {
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(point, $0.frame, false) }) ?? NSScreen.main else {
            return
        }

        let screenHeight = screen.frame.height
        let flippedY = screenHeight - point.y

        let captureRect = CGRect(
            x: point.x - 5,
            y: flippedY - 5,
            width: 11,
            height: 11
        )

        guard let cgImage = CGWindowListCreateImage(
            captureRect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.bestResolution]
        ) else {
            return
        }

        let pickedColor = extractCenterColor(from: cgImage)
        magnifierView?.update(with: cgImage, pickedColor: pickedColor, point: point)
    }

    private func extractCenterColor(from cgImage: CGImage) -> RGB? {
        let width = cgImage.width
        let height = cgImage.height
        guard width > 0, height > 0 else { return nil }

        let centerX = width / 2
        let centerY = height / 2

        guard let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let bytes = CFDataGetBytePtr(data) else {
            return nil
        }

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow

        let offset = centerY * bytesPerRow + centerX * bytesPerPixel
        guard offset + 2 < CFDataGetLength(data) else { return nil }

        let b = Int(bytes[offset])
        let g = Int(bytes[offset + 1])
        let r = Int(bytes[offset + 2])

        return RGB(r: r, g: g, b: b)
    }

    @objc private func handleClick(_ event: NSEvent) {
        let point = NSEvent.mouseLocation

        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(point, $0.frame, false) }) ?? NSScreen.main else {
            cancel()
            return
        }

        let screenHeight = screen.frame.height
        let flippedY = screenHeight - point.y

        let captureRect = CGRect(x: point.x, y: flippedY, width: 1, height: 1)

        guard let cgImage = CGWindowListCreateImage(captureRect, .optionOnScreenOnly, kCGNullWindowID, [.bestResolution]),
              let rgb = extractCenterColor(from: cgImage) else {
            cancel()
            return
        }

        stop()
        let color = SwatchColor(rgb: rgb)
        onColorPicked?(color)
    }

    func cancel() {
        stop()
        onCancel?()
    }

    private func stop() {
        if let monitor = mouseMonitor {
            NSEvent.removeMonitor(monitor)
            mouseMonitor = nil
        }
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
        overlayWindow?.orderOut(nil)
        overlayWindow = nil
        magnifierView = nil
    }
}

class MagnifierView: NSView {
    private var cgImage: CGImage?
    private var pickedColor: RGB?
    private var cursorPoint: NSPoint = .zero

    private let gridSize = 11
    private let cellSize: CGFloat = 10

    override var acceptsFirstResponder: Bool { true }

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupClickGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupClickGesture() {
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        clickGesture.numberOfClicksRequired = 1
        addGestureRecognizer(clickGesture)
    }

    @objc private func handleClick() {
        guard let window = window else { return }
        let location = NSEvent.mouseLocation
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(location, $0.frame, false) }) ?? NSScreen.main else { return }

        let screenHeight = screen.frame.height
        let flippedY = screenHeight - location.y

        let captureRect = CGRect(x: location.x, y: flippedY, width: 1, height: 1)

        guard let cgImage = CGWindowListCreateImage(captureRect, .optionOnScreenOnly, kCGNullWindowID, [.bestResolution]),
              let rgb = extractCenterColor(from: cgImage) else { return }

        EyedropperService.shared.cancel()
        let color = SwatchColor(rgb: rgb)
        Task { @MainActor in
            ColorStore.shared.selectColor(color)
        }
    }

    func update(with image: CGImage, pickedColor: RGB?, point: NSPoint) {
        self.cgImage = image
        self.pickedColor = pickedColor
        self.cursorPoint = point
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let centerX = bounds.midX
        let centerY = bounds.midY

        let viewSize = CGFloat(gridSize) * cellSize

        if let img = cgImage {
            let srcWidth = CGFloat(img.width)
            let srcHeight = CGFloat(img.height)
            let srcRect = CGRect(x: 0, y: 0, width: srcWidth, height: srcHeight)
            let dstRect = CGRect(x: centerX - viewSize / 2, y: centerY - viewSize / 2, width: viewSize, height: viewSize)
            context.interpolationQuality = .none
            context.saveGState()
            context.clip(to: srcRect)
            context.draw(img, in: dstRect)
            context.restoreGState()
        }

        let halfGrid = gridSize / 2
        for x in 0..<gridSize {
            for y in 0..<gridSize {
                let cellX = centerX - viewSize / 2 + CGFloat(x) * cellSize
                let cellY = centerY - viewSize / 2 + CGFloat(y) * cellSize
                let cellRect = CGRect(x: cellX, y: cellY, width: cellSize, height: cellSize)
                context.setStrokeColor(NSColor.white.withAlphaComponent(0.4).cgColor)
                context.setLineWidth(0.5)
                context.stroke(cellRect)
            }
        }

        let crossX = centerX
        let crossY = centerY
        let crossHalf: CGFloat = cellSize / 2 + 2
        context.setStrokeColor(NSColor.white.cgColor)
        context.setLineWidth(1.5)
        context.move(to: CGPoint(x: crossX - crossHalf, y: crossY))
        context.addLine(to: CGPoint(x: crossX + crossHalf, y: crossY))
        context.move(to: CGPoint(x: crossX, y: crossY - crossHalf))
        context.addLine(to: CGPoint(x: crossX, y: crossY + crossHalf))
        context.strokePath()

        let outerFrame = CGRect(
            x: centerX - viewSize / 2 - 1,
            y: centerY - viewSize / 2 - 1,
            width: viewSize + 2,
            height: viewSize + 2
        )
        context.setStrokeColor(NSColor.white.cgColor)
        context.setLineWidth(2)
        context.stroke(outerFrame)

        if let rgb = pickedColor {
            let nsColor = NSColor(
                red: CGFloat(rgb.r) / 255.0,
                green: CGFloat(rgb.g) / 255.0,
                blue: CGFloat(rgb.b) / 255.0,
                alpha: 1.0
            )
            let swatchSize: CGFloat = 24
            let swatchX = centerX - swatchSize / 2
            let swatchY = centerY - viewSize / 2 - swatchSize - 4
            let swatchRect = CGRect(x: swatchX, y: swatchY, width: swatchSize, height: swatchSize)

            let bgRect = swatchRect.insetBy(dx: -2, dy: -2)
            NSColor.white.withAlphaComponent(0.9).setFill()
            let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: 4, yRadius: 4)
            bgPath.fill()

            nsColor.setFill()
            let path = NSBezierPath(roundedRect: swatchRect, xRadius: 3, yRadius: 3)
            path.fill()

            nsColor.setStroke()
            path.lineWidth = 1
            path.stroke()

            let hexStr = String(format: "#%02X%02X%02X", rgb.r, rgb.g, rgb.b)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: 9, weight: .medium),
                .foregroundColor: NSColor.black
            ]
            let attrStr = NSAttributedString(string: hexStr, attributes: attrs)
            let textSize = attrStr.size()
            let textX = centerX - textSize.width / 2
            let textY = swatchY - textSize.height - 2
            attrStr.draw(at: CGPoint(x: textX, y: textY))
        }
    }

    private func extractCenterColor(from cgImage: CGImage) -> RGB? {
        let width = cgImage.width
        let height = cgImage.height
        guard width > 0, height > 0 else { return nil }
        let centerX = width / 2
        let centerY = height / 2
        guard let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let bytes = CFDataGetBytePtr(data) else { return nil }
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow
        let offset = centerY * bytesPerRow + centerX * bytesPerPixel
        guard offset + 2 < CFDataGetLength(data) else { return nil }
        let b = Int(bytes[offset])
        let g = Int(bytes[offset + 1])
        let r = Int(bytes[offset + 2])
        return RGB(r: r, g: g, b: b)
    }
}
