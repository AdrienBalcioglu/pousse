import AppKit
import ServiceManagement

// MARK: - Drawing

/// Draws the plant on a 100 x 120 canvas fitted into `rect`.
/// stage: 0 (seed) to 6 (in full bloom). wilt: 0 (fresh), 1 (thirsty), 2 (wilted).
func drawPlant(in rect: NSRect, stage: Int, wilt: Int, sway: CGFloat = 0) {
    guard let ctx = NSGraphicsContext.current?.cgContext else { return }
    let scale = min(rect.width / 100, rect.height / 120)
    ctx.saveGState()
    ctx.translateBy(x: rect.midX - 50 * scale, y: rect.minY)
    ctx.scaleBy(x: scale, y: scale)

    let stemColor = [NSColor(red: 0.27, green: 0.60, blue: 0.31, alpha: 1), NSColor(red: 0.52, green: 0.62, blue: 0.28, alpha: 1), NSColor(red: 0.60, green: 0.50, blue: 0.26, alpha: 1)][wilt]
    let leafColor = [NSColor(red: 0.33, green: 0.71, blue: 0.38, alpha: 1), NSColor(red: 0.64, green: 0.72, blue: 0.32, alpha: 1), NSColor(red: 0.72, green: 0.60, blue: 0.30, alpha: 1)][wilt]
    let petalColor = [NSColor(red: 1.00, green: 0.52, blue: 0.64, alpha: 1), NSColor(red: 0.95, green: 0.62, blue: 0.62, alpha: 1), NSColor(red: 0.74, green: 0.56, blue: 0.48, alpha: 1)][wilt]

    // Stem: a curve from the soil to the tip. Wilting bends the tip sideways and down.
    let height = [0, 13, 25, 39, 51, 61, 69][stage]
    let h = CGFloat(height)
    let base = CGPoint(x: 50, y: 37)
    let bend = CGFloat(wilt) * h * 0.26 + sway * h / 40
    let tip = CGPoint(x: 50 + bend, y: 37 + h * (1 - 0.16 * CGFloat(wilt)))
    let c1 = CGPoint(x: 50, y: 37 + h * 0.5), c2 = CGPoint(x: 50 + bend * 0.35, y: 37 + h * 0.92)
    func point(_ t: CGFloat) -> CGPoint {
        let u = 1 - t
        let x = u * u * u * base.x + 3 * u * u * t * c1.x + 3 * u * t * t * c2.x + t * t * t * tip.x
        let y = u * u * u * base.y + 3 * u * u * t * c1.y + 3 * u * t * t * c2.y + t * t * t * tip.y
        return CGPoint(x: x, y: y)
    }

    if stage > 0 {
        let stem = NSBezierPath(); stem.move(to: base); stem.curve(to: tip, controlPoint1: c1, controlPoint2: c2)
        stem.lineWidth = 2.2 + CGFloat(stage) * 0.35; stem.lineCapStyle = .round
        stemColor.setStroke(); stem.stroke()

        // Leaves in pairs along the stem. They hang lower as the plant wilts.
        let pairs = [0, 1, 1, 2, 3, 3, 4][stage]
        let length = 9 + CGFloat(stage) * 2.4
        for i in 0..<pairs {
            let t = pairs == 1 ? (stage == 1 ? 1.0 : 0.6) : 0.28 + 0.62 * CGFloat(i) / CGFloat(pairs - 1)
            let at = point(t)
            let size = length * (1 - 0.18 * CGFloat(i) / CGFloat(max(pairs, 1)))
            for side in [-1.0, 1.0] as [CGFloat] {
                let lift: CGFloat = [34, 2, -38][wilt] + sway * 2
                let angle = (side > 0 ? lift : 180 - lift) * .pi / 180
                ctx.saveGState()
                ctx.translateBy(x: at.x, y: at.y); ctx.rotate(by: angle)
                let leaf = NSBezierPath(); leaf.move(to: .zero)
                leaf.curve(to: CGPoint(x: size, y: 0), controlPoint1: CGPoint(x: size * 0.3, y: size * 0.42), controlPoint2: CGPoint(x: size * 0.8, y: size * 0.34))
                leaf.curve(to: .zero, controlPoint1: CGPoint(x: size * 0.8, y: -size * 0.34), controlPoint2: CGPoint(x: size * 0.3, y: -size * 0.42))
                leafColor.setFill(); leaf.fill()
                stemColor.setStroke(); let vein = NSBezierPath(); vein.move(to: .zero); vein.line(to: CGPoint(x: size * 0.8, y: 0)); vein.lineWidth = 0.6; vein.stroke()
                ctx.restoreGState()
            }
        }

        // A flower from stage 5, larger at stage 6.
        if stage >= 5 {
            let r: CGFloat = stage == 6 ? 6.2 : 4.6
            petalColor.setFill()
            for k in 0..<6 {
                let a = CGFloat(k) / 6 * 2 * .pi + sway * 0.05
                NSBezierPath(ovalIn: NSRect(x: tip.x + cos(a) * r - r * 0.72, y: tip.y + sin(a) * r - r * 0.72, width: r * 1.44, height: r * 1.44)).fill()
            }
            NSColor(red: 1.0, green: 0.82, blue: 0.30, alpha: 1).setFill()
            NSBezierPath(ovalIn: NSRect(x: tip.x - r * 0.62, y: tip.y - r * 0.62, width: r * 1.24, height: r * 1.24)).fill()
        }
    }

    // Pot, drawn last so the stem comes out of the soil.
    let pot = NSBezierPath()
    pot.move(to: CGPoint(x: 31, y: 2)); pot.line(to: CGPoint(x: 69, y: 2)); pot.line(to: CGPoint(x: 75, y: 31)); pot.line(to: CGPoint(x: 25, y: 31)); pot.close()
    NSColor(red: 0.82, green: 0.47, blue: 0.31, alpha: 1).setFill(); pot.fill()
    NSColor(red: 0.72, green: 0.38, blue: 0.25, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 21, y: 30, width: 58, height: 9), xRadius: 3, yRadius: 3).fill()
    NSColor(red: 0.33, green: 0.22, blue: 0.16, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(x: 26, y: 34, width: 48, height: 5.5)).fill()
    if stage == 0 {
        NSColor(red: 0.62, green: 0.48, blue: 0.30, alpha: 1).setFill()
        NSBezierPath(ovalIn: NSRect(x: 47, y: 36, width: 6, height: 4)).fill()
    }
    ctx.restoreGState()
}

func plantImage(size: CGFloat, stage: Int, wilt: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    drawPlant(in: NSRect(x: 0, y: 0, width: size, height: size), stage: stage, wilt: wilt)
    image.unlockFocus()
    return image
}

// MARK: - State

final class Garden {
    private let store = UserDefaults.standard
    static let thresholds = [0, 1, 3, 6, 10, 15, 21] // sessions needed to reach each stage
    static let stageNames = ["A seed", "A sprout", "A seedling", "A young plant", "A leafy plant", "A plant in bloom", "A plant in full bloom"]

    var sessions: Int { get { store.integer(forKey: "sessions") } set { store.set(newValue, forKey: "sessions") } }
    var minutes: Int { get { let m = store.integer(forKey: "minutes"); return m > 0 ? m : 25 } set { store.set(newValue, forKey: "minutes") } }
    var skipWeekends: Bool { get { store.object(forKey: "skipWeekends") as? Bool ?? true } set { store.set(newValue, forKey: "skipWeekends") } }
    var sessionEnd: Date? { get { store.object(forKey: "sessionEnd") as? Date } set { store.set(newValue, forKey: "sessionEnd") } }
    var days: [String] { get { store.stringArray(forKey: "days") ?? [] } set { store.set(Array(newValue.suffix(400)), forKey: "days") } }

    private let calendar = Calendar.current
    private func key(_ date: Date) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
    private func counts(_ date: Date) -> Bool { !(skipWeekends && calendar.isDateInWeekend(date)) }

    var stage: Int { (Garden.thresholds.lastIndex { sessions >= $0 }) ?? 0 }
    var toNextStage: Int? { stage < 6 ? Garden.thresholds[stage + 1] - sessions : nil }

    /// Days that counted, strictly between the last session and today, with no session.
    var missedDays: Int {
        guard let last = days.last, let lastDate = date(from: last) else { return 0 }
        var missed = 0
        var day = calendar.date(byAdding: .day, value: 1, to: lastDate)!
        let today = calendar.startOfDay(for: Date())
        while day < today { if counts(day) { missed += 1 }; day = calendar.date(byAdding: .day, value: 1, to: day)! }
        return missed
    }
    var wilt: Int { let m = missedDays; return m >= 3 ? 2 : m >= 1 ? 1 : 0 }

    /// Consecutive counting days with a session, ending today or on the last counting day.
    var streak: Int {
        let done = Set(days)
        var day = calendar.startOfDay(for: Date()), count = 0
        if !done.contains(key(day)) { day = calendar.date(byAdding: .day, value: -1, to: day)! }
        for _ in 0..<400 {
            if !counts(day) { day = calendar.date(byAdding: .day, value: -1, to: day)!; continue }
            guard done.contains(key(day)) else { break }
            count += 1; day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        return count
    }
    private func date(from key: String) -> Date? {
        let p = key.split(separator: "-").compactMap { Int($0) }
        guard p.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: p[0], month: p[1], day: p[2]))
    }

    func completeSession() {
        sessions += 1; sessionEnd = nil
        let today = key(Date())
        if days.last != today { days = days + [today] }
    }

    var headline: String {
        if sessionEnd != nil { return "Growing… stay with it." }
        switch wilt {
        case 2: return "Wilted. One session brings it back."
        case 1: return "Thirsty: no session on the last working day."
        default: return sessions == 0 ? "Plant it: finish one session." : "Doing well."
        }
    }
    var detail: String {
        var parts = ["\(Garden.stageNames[stage])", "\(sessions) session\(sessions == 1 ? "" : "s")"]
        if streak > 1 { parts.append("\(streak) days in a row") }
        if let n = toNextStage { parts.append("\(n) to grow") }
        return parts.joined(separator: " · ")
    }
}

// MARK: - Views

/// The plant with its two lines of text. Used in the menu and in the desktop window.
final class PlantCard: NSView {
    let garden: Garden
    var sway: CGFloat = 0 { didSet { needsDisplay = true } }
    var onDark = false
    init(garden: Garden, frame: NSRect) { self.garden = garden; super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ dirtyRect: NSRect) {
        let textHeight: CGFloat = 44
        drawPlant(in: NSRect(x: 10, y: textHeight + 4, width: bounds.width - 20, height: bounds.height - textHeight - 10), stage: garden.stage, wilt: garden.wilt, sway: sway)
        let style = NSMutableParagraphStyle(); style.alignment = .center; style.lineBreakMode = .byTruncatingTail
        let primary = onDark ? NSColor.white : NSColor.labelColor
        let secondary = onDark ? NSColor.white.withAlphaComponent(0.75) : NSColor.secondaryLabelColor
        (garden.headline as NSString).draw(in: NSRect(x: 8, y: 22, width: bounds.width - 16, height: 18),
            withAttributes: [.font: NSFont.systemFont(ofSize: 12.5, weight: .semibold), .foregroundColor: primary, .paragraphStyle: style])
        (garden.detail as NSString).draw(in: NSRect(x: 8, y: 5, width: bounds.width - 16, height: 16),
            withAttributes: [.font: NSFont.systemFont(ofSize: 11), .foregroundColor: secondary, .paragraphStyle: style])
    }
}

/// A rounded, translucent backdrop for the desktop window.
final class Backdrop: NSVisualEffectView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        material = .hudWindow; blendingMode = .behindWindow; state = .active
        wantsLayer = true; layer?.cornerRadius = 16; layer?.masksToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - App

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let garden = Garden()
    private var statusItem: NSStatusItem!
    private var menuCard: PlantCard!
    private var windowCard: PlantCard?
    private var window: NSPanel?
    private var sessionItem: NSMenuItem!
    private var lengthItems: [NSMenuItem] = []
    private var weekendItem: NSMenuItem!
    private var windowItem: NSMenuItem!
    private var loginItem: NSMenuItem!
    private var started = Date()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.imagePosition = .imageLeft
        buildMenu()
        if UserDefaults.standard.object(forKey: "showWindow") as? Bool ?? true { showWindow() }
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(timer, forMode: .common)
        let swayTimer = Timer(timeInterval: 1.0 / 20, repeats: true) { [weak self] _ in
            guard let self = self, let card = self.windowCard, self.window?.isVisible == true else { return }
            card.sway = CGFloat(sin(Date().timeIntervalSince(self.started) * 1.1)) * (self.garden.wilt == 2 ? 0.6 : 1.6)
        }
        RunLoop.main.add(swayTimer, forMode: .common)
        tick()
    }

    private func tick() {
        if let end = garden.sessionEnd, end <= Date() { finishSession() }
        refresh()
    }

    private func refresh() {
        statusItem.button?.image = plantImage(size: 20, stage: garden.stage, wilt: garden.wilt)
        if let end = garden.sessionEnd {
            let s = max(0, Int(end.timeIntervalSinceNow.rounded(.up)))
            statusItem.button?.attributedTitle = NSAttributedString(string: String(format: " %02d:%02d", s / 60, s % 60),
                attributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)])
            sessionItem.title = "Abandon This Session"
        } else {
            statusItem.button?.title = ""
            sessionItem.title = "Start a \(garden.minutes)-Minute Session"
        }
        statusItem.button?.toolTip = garden.headline
        menuCard.needsDisplay = true
        windowCard?.needsDisplay = true
    }

    private func finishSession() {
        garden.completeSession()
        NSSound(named: "Glass")?.play()
        showWindow()
    }

    @objc private func toggleSession() {
        if garden.sessionEnd != nil { garden.sessionEnd = nil }
        else { garden.sessionEnd = Date().addingTimeInterval(Double(garden.minutes) * 60) }
        refresh()
    }
    @objc private func pickLength(_ item: NSMenuItem) {
        garden.minutes = item.tag
        if garden.sessionEnd != nil { garden.sessionEnd = Date().addingTimeInterval(Double(item.tag) * 60) }
        lengthItems.forEach { $0.state = $0.tag == garden.minutes ? .on : .off }
        refresh()
    }
    @objc private func toggleWeekends() { garden.skipWeekends.toggle(); weekendItem.state = garden.skipWeekends ? .on : .off; refresh() }
    @objc private func toggleWindow() {
        if window?.isVisible == true { window?.orderOut(nil); UserDefaults.standard.set(false, forKey: "showWindow") } else { showWindow() }
        windowItem.state = window?.isVisible == true ? .on : .off
    }
    @objc private func toggleLogin() {
        do {
            if SMAppService.mainApp.status == .enabled { try SMAppService.mainApp.unregister() } else { try SMAppService.mainApp.register() }
        } catch {
            let alert = NSAlert(); alert.messageText = "Could not change the login setting"
            alert.informativeText = "Move Pousse to the Applications folder, then try again."
            NSApp.activate(ignoringOtherApps: true); alert.runModal()
        }
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }

    private func showWindow() {
        if window == nil {
            let size = NSSize(width: 210, height: 250)
            let screen = (NSScreen.main ?? NSScreen.screens[0]).visibleFrame
            let panel = NSPanel(contentRect: NSRect(x: screen.maxX - size.width - 24, y: screen.minY + 24, width: size.width, height: size.height),
                                styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
            panel.isOpaque = false; panel.backgroundColor = .clear; panel.hasShadow = true
            panel.level = .floating; panel.isMovableByWindowBackground = true; panel.hidesOnDeactivate = false
            panel.isReleasedWhenClosed = false; panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            let backdrop = Backdrop(frame: NSRect(origin: .zero, size: size))
            let card = PlantCard(garden: garden, frame: backdrop.bounds); card.autoresizingMask = [.width, .height]; card.onDark = true
            backdrop.addSubview(card)
            panel.contentView = backdrop
            panel.setFrameAutosaveName("PlantWindow")
            window = panel; windowCard = card
        }
        window?.orderFrontRegardless()
        UserDefaults.standard.set(true, forKey: "showWindow")
        windowItem?.state = .on
    }

    func menuWillOpen(_ menu: NSMenu) {
        refresh()
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        windowItem.state = window?.isVisible == true ? .on : .off
    }

    private func item(_ title: String, _ action: Selector?, key: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key); item.target = self; return item
    }
    private func buildMenu() {
        let menu = NSMenu(); menu.delegate = self
        menuCard = PlantCard(garden: garden, frame: NSRect(x: 0, y: 0, width: 250, height: 210))
        let cardItem = NSMenuItem(); cardItem.view = menuCard; menu.addItem(cardItem)
        menu.addItem(.separator())
        sessionItem = item("Start a Session", #selector(toggleSession)); menu.addItem(sessionItem)
        let length = NSMenuItem(title: "Session Length", action: nil, keyEquivalent: ""); let sub = NSMenu()
        for m in [15, 25, 45, 60] {
            let i = item("\(m) minutes", #selector(pickLength(_:))); i.tag = m; i.state = m == garden.minutes ? .on : .off
            sub.addItem(i); lengthItems.append(i)
        }
        length.submenu = sub; menu.addItem(length)
        menu.addItem(.separator())
        weekendItem = item("Weekends Do Not Count", #selector(toggleWeekends)); weekendItem.state = garden.skipWeekends ? .on : .off; menu.addItem(weekendItem)
        windowItem = item("Show the Plant on the Desktop", #selector(toggleWindow)); menu.addItem(windowItem)
        loginItem = item("Open at Login", #selector(toggleLogin)); menu.addItem(loginItem)
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Pousse", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"); menu.addItem(quit)
        statusItem.menu = menu
    }
}

// MARK: - Entry point

// `Pousse --render file.png` draws every stage and state to an image, to check the artwork.
if CommandLine.arguments.count == 3, CommandLine.arguments[1] == "--render" {
    let cell: CGFloat = 150
    let image = NSImage(size: NSSize(width: cell * 7, height: cell * 3))
    image.lockFocus()
    NSColor(white: 0.96, alpha: 1).setFill(); NSRect(x: 0, y: 0, width: cell * 7, height: cell * 3).fill()
    for wilt in 0..<3 { for stage in 0..<7 {
        drawPlant(in: NSRect(x: CGFloat(stage) * cell + 10, y: CGFloat(2 - wilt) * cell + 8, width: cell - 20, height: cell - 16), stage: stage, wilt: wilt)
    } }
    for (i, size) in [20, 20, 20].enumerated() { plantImage(size: CGFloat(size), stage: [1, 4, 6][i], wilt: i).draw(in: NSRect(x: 6 + i * 26, y: 4, width: size, height: size)) }
    image.unlockFocus()
    if let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) {
        try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[2]))
    }
    exit(0)
}

// `--icon file.png` draws the 1024-pixel app icon.
if CommandLine.arguments.count == 3, CommandLine.arguments[1] == "--icon" {
    let image = NSImage(size: NSSize(width: 1024, height: 1024))
    image.lockFocus()
    let tile = NSBezierPath(roundedRect: NSRect(x: 100, y: 100, width: 824, height: 824), xRadius: 185, yRadius: 185)
    NSGradient(starting: NSColor(red: 0.78, green: 0.91, blue: 0.80, alpha: 1), ending: NSColor(red: 0.93, green: 0.98, blue: 0.90, alpha: 1))?.draw(in: tile, angle: 90)
    drawPlant(in: NSRect(x: 212, y: 170, width: 600, height: 700), stage: 6, wilt: 0)
    image.unlockFocus()
    if let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) {
        try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[2]))
    }
    exit(0)
}

let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
