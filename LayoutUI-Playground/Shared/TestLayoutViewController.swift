//
//  TestLayoutViewController.swift
//  LayoutUI-Playground
//
//  Created by Denis Koryttsev on 06.07.2022.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import LayoutUI

#if !os(macOS)
typealias NSViewController = UIViewController
typealias NSScrollView = UIScrollView
typealias NSImageView = UIImageView
typealias NSTextField = UILabel
typealias NSView = UIView
typealias NSButton = UIButton
typealias NSColor = UIColor
typealias NSImage = UIImage
typealias NSViewRepresentable = UIViewRepresentable
extension UILabel {
    var stringValue: String? {
        set { text = newValue }
        get { text }
    }
    var alignment: NSTextAlignment {
        set { textAlignment = newValue }
        get { textAlignment }
    }
}
extension UIView {
    var safeAreaRect: CGRect {
        bounds.inset(by: safeAreaInsets)
    }
    var _layer: CALayer? { layer }
    var _backgroundColor: UIColor? {
        set { backgroundColor = newValue }
        get { backgroundColor }
    }
    var wantsLayer: Bool {
        set {}
        get { true }
    }
    func animator() -> Self { self }
}
extension UIButton {
    var font: UIFont? {
        set { titleLabel?.font = newValue }
        get { titleLabel?.font }
    }
}
#else
extension NSView {
    var _layer: CALayer? { layer }
    var _backgroundColor: NSColor? {
        set { layer?.backgroundColor = newValue?.cgColor }
        get { layer?.backgroundColor.flatMap(NSColor.init(cgColor:)) }
    }
}
extension NSImage {
    func applyingSymbolConfiguration(_ config: NSImage.SymbolConfiguration) -> NSImage? {
        withSymbolConfiguration(config)
    }
    convenience init?(systemName: String) {
        self.init(systemSymbolName: systemName, accessibilityDescription: nil)
    }
}
extension NSColor {
    static var label: NSColor { labelColor }
    static var separator: NSColor { separatorColor }
    static var secondaryLabel: NSColor { secondaryLabelColor }
}
extension NSTextField {
    var numberOfLines: Int {
        set { maximumNumberOfLines = newValue }
        get { maximumNumberOfLines }
    }
}
#endif

final class FlippedView: NSView {
    #if os(macOS)
    override var isFlipped: Bool { true }
    #endif
}

protocol Lazy {}
extension NSObject: Lazy {}
extension Lazy where Self: NSView {
    func `let`(_ this: (Self) -> Void) -> Self {
        this(self); return self
    }
    func add(to view: NSView?) -> Self {
        view?.addSubview(self); return self
    }
    func add(to view: NSView?, completion: (Self) -> Void) -> Self {
        view?.addSubview(self); completion(self); return self
    }
}

final class TestLayoutViewController: NSViewController {
    lazy var scrollView: NSScrollView = NSScrollView().add(to: view) { sv in
        #if os(iOS)
        sv.delegate = self
        #else
        sv.postsBoundsChangedNotifications = true
        #endif
    }
    lazy var contentView: NSView = FlippedView().let { cv in
        scrollView.addSubview(cv)
        #if os(macOS)
        cv.wantsLayer = true
        cv.layer?.masksToBounds = false
        scrollView.documentView = cv
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_scrollViewDidScroll(_:)),
            name: NSView.boundsDidChangeNotification,
            object: scrollView.contentView
        )
        #endif
    }
    lazy var imageView: NSImageView = NSImageView().add(to: contentView)
    lazy var connect: NSTextField = NSTextField().add(to: contentView)
    lazy var message: NSTextField = NSTextField().add(to: contentView)
    lazy var stat1: StatView = StatView().add(to: contentView)
    lazy var stat2: StatView = StatView().add(to: contentView)
    lazy var stat3: StatView = StatView().add(to: contentView)
    lazy var name: NSTextField = NSTextField().add(to: contentView)
    lazy var location: NSTextField = NSTextField().add(to: contentView)
    lazy var separator: NSView = NSView().add(to: contentView)
    lazy var desc: NSTextField = NSTextField().add(to: contentView)
    lazy var showMore: NSButton = NSButton().add(to: contentView)
    lazy var backgroundView: NSView = NSView().add(to: contentView) { $0.wantsLayer = true }
    lazy var stackViews: [NSTextField] = {
        (0 ..< 5).map { i in
            let view = NSTextField()
            view.stringValue = "\(i)" + String(repeating: " ", count: (0..<20).randomElement()!)
            let c = CGFloat(i)
            let r = 0...255
            view.backgroundColor = NSColor(
                red: 1.0 * c,
                green: CGFloat(r.randomElement()!) / 255,
                blue: CGFloat(r.randomElement()!) / 255,
                alpha: 0.5
            )
            contentView.addSubview(view)
            return view
        }
    }()

    override func loadView() {
        view = NSView()
        #if os(macOS)
        view.wantsLayer = true
        #endif
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view._backgroundColor = .systemOrange
        backgroundView._backgroundColor = NSColor.black.withAlphaComponent(0.3)
        imageView.image = NSImage(systemName: "person")?
            .applyingSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 200, weight: .regular))
        imageView._backgroundColor = NSColor.black.withAlphaComponent(0.3)
        imageView._layer?.cornerRadius = 50
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
        name.numberOfLines = 0
        location.stringValue = "San Francisco, USA"
        location.font = .systemFont(ofSize: 30, weight: .light)
        separator._backgroundColor = NSColor.separator
        desc.stringValue = "An artist of considerable range, Jessica name taken by Melbourne..."
        desc.font = .systemFont(ofSize: 16)
        desc.numberOfLines = 0
        showMore.font = .systemFont(ofSize: 16)
        #if os(macOS)
        showMore.title = "Show more"
        showMore.target = self
        showMore.action = #selector(showMoreAction)
        #else
        scrollView.contentInsetAdjustmentBehavior = .never
        showMore.setTitle("Show more", for: .normal)
        showMore.addTarget(self, action: #selector(showMoreAction), for: .touchUpInside)
        #endif
    }

    #if os(iOS)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout()
    }
    #else
    override func viewDidLayout() {
        super.viewDidLayout()
        layout()
    }
    #endif
    func layout() {
        guard scrollView.frame != view.bounds else { return }
        let start = CFAbsoluteTimeGetCurrent()
        scrollView.frame = view.bounds
        scheme.layout(in: view.safeAreaRect.insetBy(dx: 20, dy: 0))
        contentView.frame.size = CGSize(width: view.bounds.width, height: showMore.frame.maxY + 30)
        #if os(iOS)
        scrollView.contentSize = contentView.frame.size
        #endif
        let current = CFAbsoluteTimeGetCurrent()
        let diff = current - start
        print("Layout: \(diff) seconds;")
    }
    @objc func _scrollViewDidScroll(_: Any) {
        backgroundScheme.layout(in: scrollView.bounds)
    }

    @objc func showMoreAction() {
        let bounds = view.safeAreaRect.insetBy(dx: 20, dy: 0)
        customStackScheme.layout(in: bounds)
        var snapshot = LayoutSnapshot(preparedRects: [0: imageView.frame])
        customStackScheme.layout(to: &snapshot, with: (), in: bounds)
        print("Custom stack snapshot: ", snapshot)
        var customStackRect = CGRect.null
        customStackScheme.layout(to: &customStackRect, with: (), in: bounds)
        print("Custom stack rect: ", customStackRect)

        var stackRect = CGRect.null
        stackScheme.layout(to: &stackRect, with: (), in: bounds)
        print("ForEach based stack would be have rect: ", stackRect)
    }
}
#if os(iOS)
extension TestLayoutViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        backgroundScheme.layout(in: scrollView.bounds)
    }
}
#endif
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

        #if os(macOS)
        override var isFlipped: Bool { true }
        #endif

        @LayoutBuilder var scheme: some LayoutUI.Layout {
            FittingRect(value, cache: sizesCache, id: 0) {
                Bottom().offset(-4)
                CenterX()
            }.constraints(bounds, viewID: .max) {
                MidY.Limit.MaxY()
            }
            FittingRect(title, cache: sizesCache, id: 1) {
                Top().offset(4)
                CenterX()
            }.constraints(bounds, viewID: .max) {
                MidY.Limit.MinY()
            }
        }

        #if os(iOS)
        override func layoutSubviews() {
            super.layoutSubviews()
            _layout()
        }
        #else
        override func layout() {
            super.layout()
            _layout()
        }
        #endif
        func _layout() {
            if sizesCache.lastBounds.size != bounds.size {
                sizesCache.invalidate()
            }
            scheme.layout(in: bounds)
        }

        #if os(iOS)
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            let bounds = CGRect(origin: .zero, size: size)
            var snapshot = LayoutSnapshot(preparedRects: [.max: bounds])
            if sizesCache.lastBounds.size != size {
                sizesCache.invalidate()
            }
            scheme.layout(to: &snapshot, with: (), in: bounds)
            sizesCache.lastBounds = bounds
            return snapshot.unionRect.size
        }
        #endif
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
            MidX.Limit.MaxX()
        }
        FittingRect(message, id: 2) {
            Width.Current().inset(-10)
            Height.Current().inset(-4)
            Top().offset(15)
            Left().offset(6)
        }.constraints(imageView, viewID: 0) {
            MaxY.Align.MinY()
            MidX.Limit.MinX()
        }
        Group {
            Rect(stat2, id: 3) {
                Width.Constant(70)
                Height.Constant(50)
                Top().offset(20)
                CenterX()
            }.constraints(message, viewID: 2) {
                MaxY.Align.MinY()
            }
            Rect(stat1, id: 4) {
                Width.Constant(70)
                Height.Constant(50)
                Top()
                CenterX()
            }.constraints(stat2, viewID: 3) {
                Top()
                MidX.Limit.MaxX()
            }
            Rect(stat3, id: 5) {
                Width.Constant(70)
                Height.Constant(50)
                Top()
                CenterX()
            }.constraints(stat2, viewID: 3) {
                Top()
                MidX.Limit.MinX()
            }
        }.constraints(view.bounds, viewID: .max) {
            Width().between(300...700)
            CenterX()
        }
        FittingRect(name, id: 6) {
            Top().offset(30)
            CenterX()
        }.constraints(stat2, viewID: 3) {
            MaxY.Align.MinY()
        }
        FittingRect(location, id: 7) {
            Top().offset(10)
            CenterX()
        }.constraints(name, viewID: 6) {
            MaxY.Align.MinY()
        }
        Rect(separator, id: 8) {
            Width().inset(50)
            Height.Constant(1)
            Top().offset(30)
            CenterX()
        }.constraints(location, viewID: 7) {
            MaxY.Align.MinY()
        }
        FittingRect(desc, id: 9) {
            Top().offset(30)
            CenterX()
        }.constraints(separator, viewID: 8) {
            MaxY.Align.MinY()
        }
        FittingRect(showMore, id: 10) {
            Top().offset(10)
            CenterX()
        }.constraints(desc, viewID: 9) {
            MaxY.Align.MinY()
        }
        if true {
            explicitStackScheme
        } else if true {
            customStackScheme
        } else {
            stackScheme
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
            MidY.Limit.MinY()
        }.constraints(bottomConstraint, viewID: 11) {
            MaxY.Pull.MaxY()
        }.constraints(view.safeAreaRect, viewID: .max)
    }
    var bottomConstraint: CGRect {
        view.convert(view.bounds, to: contentView)
    }
    var stackScheme: some LayoutUI.Layout {
        ForEach(id: 20, data: stackViews.enumerated()) { el in
            Rect(el.element, id: el.offset) {
                Width().scaled(0.5 / CGFloat(self.stackViews.count))
                Height()
                CenterY()
                switch self.stackJustifyContent {
                case .start:
                    Left().offset(multiplier: CGFloat(el.offset) * (0.5 / CGFloat(self.stackViews.count)))
                case .end:
                    Right().offset(multiplier: -CGFloat(el.offset) * (0.5 / CGFloat(self.stackViews.count)))
                case .center:
                    CenterX().offset(multiplier: self.stackOffsetMultiplier(el.offset, width: 0.5))
                }
            }
        }.constraints(imageView, viewID: 0) {
            MinY.Limit.MaxY()
        }
    }
    var explicitStackScheme: some LayoutUI.Layout {
        HStack(id: 20, spacing: 10) {
            FittingRect(stackViews[0]) {
                Height()
                Top()
            }
            Rect(stackViews[1]) {
                Height().scaled(0.5)
                Bottom()
            }
            FittingRect(stackViews[2]) {
                Height().scaled(0.5)
                CenterY()
            }
            Rect(stackViews[3]) {
                Height().scaled(0.5)
                Width.Constant(100)
                Top()
            }.fixedSize()
            FittingRect(stackViews[4]) {
                Height()
                Top()
            }
        }.constraints(imageView, viewID: 0) {
            MinY.Limit.MaxY()
        }.constraints {
            Width().inset(20)
            CenterX()
        }
    }
    var customStackScheme: some LayoutUI.Layout {
        Reduce(
            id: 20, reducer: CustomReducer(initialResult: 20, data: stackViews)
        ) { res, el in
            FittingRect(el.animator(), id: res) {}
        }.constraints(imageView, viewID: 0) {
            MinY.Limit.MaxY()
        }
    }
    enum JustifyContent {
        case start
        case end
        case center
    }
    var stackJustifyContent: JustifyContent { .center }
    var stackDistributionFromCenter: Bool { true }
    func stackOffsetMultiplier(_ i: Int, width: CGFloat) -> CGFloat {
        let count = CGFloat(stackViews.count)
        let offsetStep = width / count
        let centeringOffset = stackViews.count % 2 == 0 ? offsetStep / 2 : 0
        if stackDistributionFromCenter {
            return CGFloat((i + 1) / 2) * (i % 2 != 0 ? -1 : 1) * offsetStep + centeringOffset
        } else {
            return CGFloat(i - stackViews.count / 2) * offsetStep + centeringOffset
        }
    }
}

import SwiftUI

struct CustomReducer<Elements>: LayoutReducer where Elements: Sequence {
    let initialResult: Int
    let data: Elements
    func reduce<Sublayout>(_ bounds: CGRect, scheme: (Int, Elements.Element) -> Sublayout) where Sublayout: SublayoutProtocol {
        let radius = min(bounds.size.width, bounds.size.height)
        let angle = Angle.degrees(
            360 / Double(data.underestimatedCount)
        ).radians
        let randomOffset = (0 ..< 360).randomElement()!
        let offset = Angle.degrees(Double(randomOffset)).radians

        let idOffset = initialResult + 1
        for (index, subview) in data.enumerated() {
            var point = CGPoint(x: 0, y: -radius)
                .applying(CGAffineTransform(
                    rotationAngle: angle * Double(index) + offset))
            point.x += bounds.midX
            point.y += bounds.midY + 20
            let l = scheme(idOffset + index, subview)
            let r = l.rect(in: bounds)
            l.place(in: CGRect(x: point.x - r.width / 2, y: point.y - r.height / 2, width: r.width, height: r.height))
        }
    }
    func forEach(_ next: (Int, Elements.Element) -> Void) {
        let idOffset = initialResult + 1
        for (index, subview) in data.enumerated() {
            next(idOffset + index, subview)
        }
    }
}

public struct ProportionallyStackReducer<Elements>: LayoutReducer where Elements: Sequence {
    let data: Elements
    public init(data: Elements) { self.data = data }
    public func reduce<Sublayout>(_ bounds: CGRect, scheme: (Void, Elements.Element) -> Sublayout) where Sublayout : SublayoutProtocol {
        var filledHeight: CGFloat = 0
        var rects: [(CGRect, Sublayout)] = []
        for element in data {
            let l = scheme((), element)
            let r = l.rect(in: bounds)
            rects.append((r, l))
            filledHeight += r.height
        }
        var offset = bounds.minY
        for (rect, l) in rects {
            let space = CGRect(
                origin: CGPoint(x: bounds.minX, y: offset),
                size: CGSize(
                    width: bounds.width,
                    height: bounds.height * (rect.height / filledHeight)
                )
            )
            let r = l.rect(in: space)
            l.place(in: r)
            offset += space.height
        }
    }
    public func forEach(_ next: (Void, Elements.Element) -> Void) {
        for element in data {
            next((), element)
        }
    }
}

#if os(iOS)
struct TestLayoutView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TestLayoutViewController {
        TestLayoutViewController()
    }
    func updateUIViewController(_ uiViewController: TestLayoutViewController, context: Context) {}
}
#else
struct TestLayoutView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> TestLayoutViewController {
        TestLayoutViewController()
    }
    func updateNSViewController(_ uiViewController: TestLayoutViewController, context: Context) {}
}
#endif
