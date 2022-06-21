//
//  File.swift
//  
//
//  Created by Denis Koryttsev on 06.06.2022.
//

import AppKit
import LayoutUI

/*@main*/ @available(macOS 11, *)
class AppDelegate: NSObject, NSApplicationDelegate {
    let window = NSWindow()
    let windowDelegate = WindowDelegate()
    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentSize = NSSize(width: 800, height: 600)
        window.setContentSize(contentSize)
        window.styleMask = [.borderless, .titled, .closable, .miniaturizable, .resizable]
        window.delegate = windowDelegate
        window.title = "LayoutUI Example"

        let testLayout = TestLayoutViewController()
        testLayout.view.frame = NSRect(origin: NSPoint(x: 0, y: 0), size: contentSize)
        window.contentViewController = testLayout
        window.center()
        window.makeKeyAndOrderFront(window)

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    class WindowDelegate: NSObject, NSWindowDelegate {
        func windowWillClose(_ notification: Notification) {
            NSApplication.shared.terminate(0)
        }
    }
}

if #available(macOS 11, *) {
    let app = NSApplication.shared
    let del = AppDelegate()
    app.delegate = del
    app.run()
    print("Print on exit")
}
else { fatalError("Unsupported macOS version") }

/// --------------------------

protocol Lazy {}
extension NSView: Lazy {}
extension Lazy where Self: NSView {
    func `let`(_ this: (Self) -> Void) -> Self {
        this(self); return self
    }
    func add(to view: NSView) -> Self {
        view.addSubview(self); return self
    }
    func add(to view: NSView, completion: (Self) -> Void) -> Self {
        view.addSubview(self); completion(self); return self
    }
}

@available(macOS 11, *)
final class TestLayoutViewController: NSViewController {
    lazy var scrollView: NSScrollView = NSScrollView().add(to: view) { sv in
        sv.postsBoundsChangedNotifications = true
    }
    lazy var contentView: NSView = ContentView().let { cv in
        cv.wantsLayer = true
        cv.layer?.masksToBounds = false
        scrollView.documentView = cv
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidScroll(_:)),
            name: NSView.boundsDidChangeNotification,
            object: scrollView.contentView
        )
    }
    lazy var imageView: NSImageView = NSImageView().add(to: contentView)
    lazy var connect: NSTextField = NSTextField().add(to: contentView)
    lazy var message: NSTextField = NSTextField().add(to: contentView)
    lazy var stat1: StatView = StatView().add(to: contentView)
    lazy var stat2: StatView = StatView().add(to: contentView)
    lazy var stat3: StatView = StatView().add(to: contentView)
    lazy var name: NSTextField = NSTextField().add(to: contentView)
    lazy var location: NSTextField = NSTextField().add(to: contentView)
    lazy var separator: NSView = NSView().add(to: contentView) { $0.wantsLayer = true }
    lazy var desc: NSTextField = NSTextField().add(to: contentView)
    lazy var showMore: NSButton = NSButton().add(to: contentView)
    lazy var backgroundView: NSView = NSView().add(to: contentView) { $0.wantsLayer = true }

    final class ContentView: NSView {
        override var isFlipped: Bool { true }
    }
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer?.backgroundColor = NSColor.systemPink.cgColor
        backgroundView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.3).cgColor
        imageView.image = NSImage(systemSymbolName: "person", accessibilityDescription: nil)?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 200, weight: .regular))
        imageView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.3).cgColor
        imageView.layer?.cornerRadius = 50
        connect.stringValue = "Connect".uppercased()
        connect.alignment = .center
        connect.font = .systemFont(ofSize: 13, weight: .bold)
        if #available(macOS 12.0, *) {
            connect.backgroundColor = .systemCyan
        } else {
            connect.backgroundColor = .cyan
        }
        message.stringValue = "Message".uppercased()
        message.alignment = .center
        message.backgroundColor = .systemBlue
        message.font = .systemFont(ofSize: 13, weight: .bold)
        stat1.title.stringValue = "Friends"; stat1.value.stringValue = "2k"
        stat2.title.stringValue = "Photos"; stat2.value.stringValue = "10"
        stat3.title.stringValue = "Comments"; stat3.value.stringValue = "89"
        name.stringValue = "Jessica Jones, 27"
        name.font = .systemFont(ofSize: 50, weight: .medium)
        location.stringValue = "San Francisco, USA"
        location.font = .systemFont(ofSize: 30, weight: .light)
        separator.layer?.backgroundColor = NSColor.separatorColor.cgColor
        desc.stringValue = "An artist of considerable range, Jessica name taken by Melbourne..."
        desc.font = .systemFont(ofSize: 16)
        showMore.title = "Show more"
        showMore.font = .systemFont(ofSize: 16)
        showMore.target = self
        showMore.action = #selector(showMoreAction)
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        guard scrollView.frame != view.bounds else { return }
        scrollView.frame = view.bounds
        scheme
            .constraints(view.safeAreaRect, viewID: .max)
            .layout(in: view.bounds)
        contentView.frame.size = CGSize(width: view.bounds.width, height: showMore.frame.maxY + 30)
    }

    @objc func scrollViewDidScroll(_ notif: Notification) {
        backgroundScheme.layout(in: scrollView.bounds)
    }

    @objc func showMoreAction() {
        guard #available(macOS 12.0, *) else { return }
        let hosting = NSHostingController(rootView: SwiftUIView())
        hosting.view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        presentAsSheet(hosting)
    }
}
@available(macOS 11, *)
extension TestLayoutViewController {
    final class StatView: NSView {
        lazy var value: NSTextField = NSTextField().add(to: self) { vw in
            vw.font = .systemFont(ofSize: 15, weight: .bold)
        }
        lazy var title: NSTextField = NSTextField().add(to: self) { vw in
            vw.font = .systemFont(ofSize: 13, weight: .regular)
        }

        lazy var sizesCache: SizesCache = SizesCache(lastBounds: .null)
        final class SizesCache: CacheContainer {
            var values: [Int: CGSize] = [:]
            var lastBounds: CGRect

            init(lastBounds: CGRect) { self.lastBounds = lastBounds }

            subscript(id: Int) -> CGSize? {
                get { values[id] }
                set { values[id] = newValue }
            }

            func invalidate() { values.removeAll(keepingCapacity: true) }
        }

        @LayoutBuilder var scheme: some LayoutUI.Layout {
            FittingRect(value, cache: sizesCache, id: 0) {
                Bottom().offset(-4)
                CenterX()
            }.constraints(bounds, viewID: .max) {
                MidY.Before.Limit()
            }
            FittingRect(title, cache: sizesCache, id: 1) {
                Top().offset(4)
                CenterX()
            }.constraints(bounds, viewID: .max) {
                MidY.After.Limit()
            }
        }

        override func layout() {
            super.layout()
            if sizesCache.lastBounds.size != bounds.size {
                sizesCache.invalidate()
            }
            scheme.layout(in: bounds)
        }

        func sizeThatFits(_ size: CGSize) -> CGSize {
            let bounds = CGRect(origin: .zero, size: size)
            var snapshot = LayoutSnapshot(preparedRects: [.max: bounds])
            if sizesCache.lastBounds.size != size {
                sizesCache.invalidate()
            }
            scheme.layout(to: &snapshot, with: (), in: bounds)
            sizesCache.lastBounds = bounds
            return snapshot.unionRect.size
        }
    }
}
@available(macOS 11, *)
extension TestLayoutViewController {
    @LayoutBuilder var scheme: some LayoutUI.Layout {
        Rect(imageView, id: 0) {
            Width.Constant(100)
            Height.Constant(100)
            Top().offset(40)
            CenterX()
        }
        FittingRect(connect, id: 1) {
            Width.Current().inset(-10)
            Height.Current().inset(-4)
            Top().offset(15)
            Right().offset(-6)
        }.constraints(imageView, viewID: 0) {
            MaxY.Align.MinY()
            MidX.Before.Limit()
        }
        FittingRect(message, id: 2) {
            Width.Current().inset(-10)
            Height.Current().inset(-4)
            Top().offset(15)
            Left().offset(6)
        }.constraints(imageView, viewID: 0) {
            MaxY.After.Align()
            MidX.After.Limit()
        }
        Rect(stat2, id: 3) {
            Width.Constant(70)
            Height.Constant(50)
            Top().offset(20)
            CenterX()
        }.constraints(message, viewID: 2) {
            MaxY.After.Align()
        }
        Rect(stat1, id: 4) {
            Width.Constant(70)
            Height.Constant(50)
            Top()
            CenterX()
        }.constraints(stat2, viewID: 3) {
            Top()
            MidX.Before.Limit()
        }
        Rect(stat3, id: 5) {
            Width.Constant(70)
            Height.Constant(50)
            Top()
            CenterX()
        }.constraints(stat2, viewID: 3) {
            Top()
            MidX.After.Limit()
        }
        FittingRect(name, id: 6) {
            Top().offset(30)
            CenterX()
        }.constraints(stat2, viewID: 3) {
            MaxY.After.Align()
        }
        FittingRect(location, id: 7) {
            Top().offset(10)
            CenterX()
        }.constraints(name, viewID: 6) {
            MaxY.After.Align()
        }
        Rect(separator, id: 8) {
            Width().inset(50)
            Height.Constant(1)
            Top().offset(30)
            CenterX()
        }.constraints(location, viewID: 7) {
            MaxY.After.Align()
        }
        FittingRect(desc, id: 9) {
            Top().offset(30)
            CenterX()
        }.constraints(separator, viewID: 8) {
            MaxY.After.Align()
        }
        FittingRect(showMore, id: 10) {
            Top().offset(10)
            CenterX()
        }.constraints(desc, viewID: 9) {
            MaxY.After.Align()
        }
        backgroundScheme
    }
    /// Pins background to bottom of screen
    @LayoutBuilder var backgroundScheme: some LayoutUI.Layout {
        Rect(backgroundView, id: 11) {
            Width().inset(30)
            Height().inset(-30)
            Top()
            CenterX()
        }.constraints(imageView, viewID: 0) {
            MidY.After.Limit()
        }.constraints(bottomConstraint, viewID: 11) {
            MaxY.Before.Pull()
        }.constraints(view.safeAreaRect, viewID: .max)
    }
    var bottomConstraint: CGRect {
        view.convert(view.bounds, to: contentView)
    }
}

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 12.0, *)
struct SwiftUIView: View {
    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 100) {
                Rectangle()
                Rectangle()
                    .basicLayout {
                        Height().scaled(0.5)
                        Bottom()
                    }
            }
            .foregroundColor(.red)
            .opacity(0.5)
            .basicLayout {
                Width()
                Height().scaled(0.5)
                CenterY()
                Right()
            }
            .background(.gray)
            .basicLayout {
                Width().scaled(0.5)
                MaxX.Align.MaxX()
            }
            VStack {
                Text("Hello")
                    .font(.largeTitle)
                    .background(.green)
                Text("World")
            }
            .basicLayout(.bottomLeading) {
                Width().scaled(0.5)
                Left().offset(40)
                Bottom().offset(-40)
            }
            .border(Color.green, width: 10)
            #if compiler(>=5.7)
            if #available(macOS 13.0, *) {
                Color.red.opacity(0.5)
                    .layout {
                        Width().inset(100)
                        Height().scaled(0.5)
                        CenterX()
                        CenterY()
                    }
                Text("Custom layout")
                    .background(Color.yellow)
                    .fittingLayout {
                        CenterX()
                        CenterY()
                    }
                (ConstraintBasedLayout()) {
                    Text("Text #1+").constrainedLayout { Left().offset(20) }
                    Text("Text #2/").constrainedLayout {
                        Constraint(0) { MaxY.Align.MinY().offset(20) }
                    }
                    Text("Text #3\\").zIndex(50).constrainedLayout {
                        Constraint(1) {
                            MaxY.Align.MinY()
                            MaxX.Align.MinX().offset(10)
                        }
                    }
                    Color.red.border(Color.yellow, width: 2).constrainedLayout {
                        Constraint(2) { Equal() }
                    }
                    Color.brown.constrainedLayout {
                        Constraint(1) { MaxY.Limit.MinY() }
                        Constraint(2) { MinX.Limit.MaxX() }
                    }
                }
            }
            #endif
        }
    }
}

#endif
