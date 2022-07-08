//
//  ViewBasedLayout.swift
//  LayoutUI
//
//  Created by Denis Koryttsev on 26.05.2022.
//

import CoreGraphics

public struct LayoutSnapshot {
    @usableFromInline
    var completedRects: [Int: CGRect]
    @inlinable
    @inline(__always)
    public var unionRect: CGRect {
        completedRects.values.reduce(into: .null, { $0 = $0.union($1) })
    }
    @inlinable
    @inline(__always)
    public init(preparedRects: [Int: CGRect] = [:]) {
        self.completedRects = preparedRects
    }
}
public protocol ViewBasedLayout {
    associatedtype View
    var id: Int? { get }
    var isFixedWidth: Bool { get }
    var isFixedHeight: Bool { get }
    func layout(_ view: View, in source: CGRect)
    func layout(to rect: inout CGRect, with view: View, in bounds: CGRect)
    func apply(_ rect: CGRect, for view: View)
    func layout(to snapshot: inout LayoutSnapshot, with view: View, in bounds: CGRect)
    func apply(_ snapshot: LayoutSnapshot, for view: View)
    /// `func fillSnapshot(_ snapshot: inout LayoutSnapshot, for view: View)`
}
extension ViewBasedLayout {
    @inlinable
    @inline(__always)
    public var id: Int? { nil }
    @inlinable
    @inline(__always)
    public var isFixedWidth: Bool { false }
    @inlinable
    @inline(__always)
    public var isFixedHeight: Bool { false }

    @inlinable
    @inline(__always)
    public func layout(to rect: inout CGRect, with view: View, in source: CGRect) { rect = source }
    @inlinable
    @inline(__always)
    public func apply(_ rect: CGRect, for view: View) { layout(view, in: rect) }
    @inlinable
    @inline(__always)
    public func layout(_ view: View, in source: CGRect) {
        var rect = source
        layout(to: &rect, with: view, in: source)
        apply(rect, for: view)
    }
    @inlinable
    @inline(__always)
    public func layout(to snapshot: inout LayoutSnapshot, with view: View, in source: CGRect) {
        var rect = source
        layout(to: &rect, with: view, in: source)
        if let id = id {
            snapshot.completedRects[id] = rect
        }
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        apply(snapshot.completedRects[id!]!, for: view)
    }
}
extension ViewBasedLayout {
    @inlinable
    @inline(__always)
    public func snapshot(_ view: View, in source: CGRect) -> LayoutSnapshot {
        var snap = LayoutSnapshot()
        layout(to: &snap, with: view, in: source)
        return snap
    }
}
extension ViewBasedLayout where View == Void {
    @inlinable
    @inline(__always)
    public func layout(in source: CGRect) {
        layout((), in: source)
    }
}
public protocol Layout: ViewBasedLayout where View == Void {}

extension Empty: ViewBasedLayout {
    public typealias View = T
    @inlinable
    @inline(__always)
    public func layout(_ _: View, in _: CGRect) {}
    @inlinable
    @inline(__always)
    public func layout(to rect: inout CGRect, with view: T, in source: CGRect) {}
    @inlinable
    @inline(__always)
    public func apply(_ rect: CGRect, for view: T) {}
    @inlinable
    @inline(__always)
    public func layout(to _: inout LayoutSnapshot, with _: View, in _: CGRect) {}
    @inlinable
    @inline(__always)
    public func apply(_ _: LayoutSnapshot, for _: View) {}
}
extension Empty: Layout where T == Void {}

@usableFromInline
class _AnyViewLayout_<View> {
    @usableFromInline
    var id: Int? { nil }
    @usableFromInline
    var isFixedWidth: Bool { false }
    @usableFromInline
    var isFixedHeight: Bool { false }
    @usableFromInline
    func layout(_ view: View, in source: CGRect) {}
    @usableFromInline
    func layout(to rect: inout CGRect, with view: View, in source: CGRect) {}
    @usableFromInline
    func apply(_ rect: CGRect, for view: View) {}
    @usableFromInline
    func layout(to snapshot: inout LayoutSnapshot, with view: View, in source: CGRect) {}
    @usableFromInline
    func apply(_ snapshot: LayoutSnapshot, for view: View) {}
}
@usableFromInline
final class _AnyViewLayout<Base>: _AnyViewLayout_<Base.View> where Base: ViewBasedLayout {
    @usableFromInline
    let base: Base
    @usableFromInline
    override var id: Int? { base.id }
    @usableFromInline
    override var isFixedWidth: Bool { base.isFixedWidth }
    @usableFromInline
    override var isFixedHeight: Bool { base.isFixedHeight }
    @usableFromInline
    init(base: Base) { self.base = base }
    @usableFromInline
    override func layout(_ view: Base.View, in source: CGRect) {
        base.layout(view, in: source)
    }
    @usableFromInline
    override func layout(to rect: inout CGRect, with view: Base.View, in source: CGRect) {
        base.layout(to: &rect, with: view, in: source)
    }
    @usableFromInline
    override func apply(_ rect: CGRect, for view: Base.View) {
        base.apply(rect, for: view)
    }
    @usableFromInline
    override func layout(to snapshot: inout LayoutSnapshot, with view: Base.View, in source: CGRect) {
        base.layout(to: &snapshot, with: view, in: source)
    }
    @usableFromInline
    override func apply(_ snapshot: LayoutSnapshot, for view: Base.View) {
        base.apply(snapshot, for: view)
    }
}
public struct AnyViewLayout<View>: ViewBasedLayout {
    @usableFromInline
    let base: _AnyViewLayout_<View>
    @inlinable
    public var id: Int? { base.id }
    @inlinable
    public var isFixedWidth: Bool { base.isFixedWidth }
    @inlinable
    public var isFixedHeight: Bool { base.isFixedHeight }
    @inlinable
    @inline(__always)
    public init<Scheme>(@LayoutBuilder schemeBuilder: () -> Scheme) where Scheme: ViewBasedLayout, Scheme.View == View {
        let scheme = schemeBuilder()
        self.base = _AnyViewLayout(base: scheme)
    }
    @inlinable
    @inline(__always)
    public func layout(_ view: View, in source: CGRect) {
        base.layout(view, in: source)
    }
    @inlinable
    @inline(__always)
    public func layout(to rect: inout CGRect, with view: View, in source: CGRect) {
        base.layout(to: &rect, with: view, in: source)
    }
    @inlinable
    @inline(__always)
    public func apply(_ rect: CGRect, for view: View) {
        base.apply(rect, for: view)
    }
    @inlinable
    @inline(__always)
    public func layout(to snap: inout LayoutSnapshot, with view: View, in source: CGRect) {
        base.layout(to: &snap, with: view, in: source)
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        base.apply(snapshot, for: view)
    }
}
extension AnyViewLayout: Layout where View == Void {}

public struct Rect<Mutator, Scheme>: ViewBasedLayout where Mutator: RectMutator, Scheme: RectBasedLayout {
    public typealias View = Mutator.View
    public let id: Int?
    @usableFromInline
    let mutator: Mutator
    @usableFromInline
    let scheme: Scheme

    @inlinable
    @inline(__always)
    public init(_ mutator: Mutator, id: Int? = nil, @LayoutBuilder schemeBuilder: () -> Scheme) {
        self.id = id
        self.mutator = mutator
        self.scheme = schemeBuilder()
    }
    @inlinable
    @inline(__always)
    public init(_ mutator: Mutator, id: Int? = nil) where Scheme == Equal {
        self.id = id
        self.mutator = mutator
        self.scheme = Equal()
    }

    @inlinable
    @inline(__always)
    public func layout(to rect: inout CGRect, with view: Mutator.View, in source: CGRect) {
        var r = mutator[view]
        scheme.layout(&r, with: source)
        rect = r
    }
    @inlinable
    @inline(__always)
    public func apply(_ rect: CGRect, for view: Mutator.View) {
        mutator[view] = rect
    }
    @inlinable
    @inline(__always)
    public func layout(to snap: inout LayoutSnapshot, with view: View, in source: CGRect) {
        var r = mutator[view]
        scheme.layout(&r, with: source)
        if let id = id {
            snap.completedRects[id] = r
        }
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        mutator[view] = snapshot.completedRects[id!]!
    }
}
extension Rect: Layout where Mutator.View == Void {}
extension Rect {
    @inlinable
    @inline(__always)
    public init<View>(_ keyPath: ReferenceWritableKeyPath<View, CGRect>, id: Int? = nil, @LayoutBuilder schemeBuilder: () -> Scheme) where Mutator == _KeyPathRectMutator<View> {
        self.id = id
        self.mutator = _KeyPathRectMutator(keyPath: keyPath)
        self.scheme = schemeBuilder()
    }
}

public struct FittingRect<Mutator, Scheme>: ViewBasedLayout where Mutator: FittingSizeMutator, Scheme: RectBasedLayout {
    public typealias View = Mutator.View
    public let id: Int?
    @inlinable
    @inline(__always)
    public var isFixedWidth: Bool { true }
    @inlinable
    @inline(__always)
    public var isFixedHeight: Bool { true }
    @usableFromInline
    let mutator: Mutator
    @usableFromInline
    let scheme: Scheme

    @inlinable
    @inline(__always)
    public init(_ mutator: Mutator, id: Int? = nil, @LayoutBuilder schemeBuilder: () -> Scheme) {
        self.id = id
        self.mutator = mutator
        self.scheme = schemeBuilder()
    }
    @inlinable
    @inline(__always)
    public init(_ mutator: Mutator, id: Int? = nil) where Scheme == Equal {
        self.id = id
        self.mutator = mutator
        self.scheme = Equal()
    }

    @inlinable
    @inline(__always)
    public func layout(to rect: inout CGRect, with view: View, in source: CGRect) {
        rect.origin = mutator[view].origin
        rect.size = mutator.fittingSize(for: view, with: source.size)
        scheme.layout(&rect, with: source)
    }
    @inlinable
    @inline(__always)
    public func apply(_ rect: CGRect, for view: Mutator.View) {
        mutator[view] = rect
    }
    @inlinable
    @inline(__always)
    public func layout(to snap: inout LayoutSnapshot, with view: View, in source: CGRect) {
        let size = mutator.fittingSize(for: view, with: source.size)
        var r = mutator[view]
        r.size = size
        scheme.layout(&r, with: source)
        if let id = id {
            snap.completedRects[id] = r
        }
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        mutator[view] = snapshot.completedRects[id!]!
    }
}
extension FittingRect: Layout where Mutator.View == Void {}

public struct Group<Base>: ViewBasedLayout where Base: ViewBasedLayout {
    public typealias View = Base.View
    public let id: Int?
    @usableFromInline
    let base: Base

    @inlinable
    @inline(__always)
    public init(id: Int? = nil, @LayoutBuilder base: () -> Base) {
        self.id = id
        self.base = base()
    }

    @inlinable
    @inline(__always)
    public func layout(_ view: View, in source: CGRect) {
        base.layout(view, in: source)
    }
    @inlinable
    @inline(__always)
    public func layout(to rect: inout CGRect, with view: Base.View, in source: CGRect) {
        base.layout(to: &rect, with: view, in: source)
    }
    @inlinable
    @inline(__always)
    public func apply(_ rect: CGRect, for view: Base.View) {
        base.apply(rect, for: view)
    }
    @inlinable
    @inline(__always)
    public func layout(to snapshot: inout LayoutSnapshot, with view: View, in source: CGRect) {
        if let id = id {
            snapshot.completedRects[id] = source
        }
        base.layout(to: &snapshot, with: view, in: source)
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        base.apply(snapshot, for: view)
    }
}
extension Group: Layout where Base.View == Void {}

public struct ResizingMode<Base>: ViewBasedLayout where Base: ViewBasedLayout {
    @usableFromInline
    let base: Base
    @usableFromInline
    let fixedWidth: Bool?
    @usableFromInline
    let fixedHeight: Bool?
    @usableFromInline
    init(_ base: Base, fixedWidth: Bool?, fixedHeight: Bool?) {
        self.base = base
        self.fixedWidth = fixedWidth
        self.fixedHeight = fixedHeight
    }
    public typealias View = Base.View
    @inlinable
    @inline(__always)
    public var id: Int? { base.id }
    @inlinable
    @inline(__always)
    public var isFixedWidth: Bool { fixedWidth ?? base.isFixedWidth }
    @inlinable
    @inline(__always)
    public var isFixedHeight: Bool { fixedHeight ?? base.isFixedHeight }

    @inlinable
    @inline(__always)
    public func layout(_ view: View, in source: CGRect) {
        base.layout(view, in: source)
    }
    @inlinable
    @inline(__always)
    public func layout(to rect: inout CGRect, with view: Base.View, in source: CGRect) {
        base.layout(to: &rect, with: view, in: source)
    }
    @inlinable
    @inline(__always)
    public func apply(_ rect: CGRect, for view: Base.View) {
        base.apply(rect, for: view)
    }
    @inlinable
    @inline(__always)
    public func layout(to snapshot: inout LayoutSnapshot, with view: View, in source: CGRect) {
        base.layout(to: &snapshot, with: view, in: source)
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        base.apply(snapshot, for: view)
    }
}
extension ViewBasedLayout {
    @inlinable
    @inline(__always)
    public func fixed(width: Bool?, height: Bool?) -> ResizingMode<Self> {
        ResizingMode(self, fixedWidth: width, fixedHeight: height)
    }
    @inlinable
    @inline(__always)
    public func flexible(width: Bool?, height: Bool?) -> ResizingMode<Self> {
        ResizingMode(self, fixedWidth: width.map({ !$0 }), fixedHeight: height.map({ !$0 }))
    }
    @inlinable
    @inline(__always)
    public func fixedSize() -> ResizingMode<Self> {
        ResizingMode(self, fixedWidth: true, fixedHeight: true)
    }
    @inlinable
    @inline(__always)
    public func flexibleSize() -> ResizingMode<Self> {
        ResizingMode(self, fixedWidth: false, fixedHeight: false)
    }
}
