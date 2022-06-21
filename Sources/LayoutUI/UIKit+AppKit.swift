//
//  UIKit+AppKit.swift
//  LayoutUI
//
//  Created by Denis Koryttsev on 21.06.2022.
//

#if canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit)
import UIKit

public typealias _SystemView = UIView
public typealias _SystemFittingView = UIView
#elseif canImport(AppKit)
import AppKit

public typealias _SystemView = NSView
public typealias _SystemFittingView = NSControl
#endif


/// - Mutators

public struct _ViewFrameMutator<ExplicitView>: RectMutator where ExplicitView: _SystemView {
    public typealias View = Void
    @usableFromInline
    let _view: ExplicitView
    @usableFromInline
    init(_view: ExplicitView) {
        self._view = _view
    }
    @inlinable
    @inline(__always)
    public subscript(view: View) -> CGRect {
        get { _view.frame }
        nonmutating set { _view.frame = newValue }
    }
}

extension _ViewFrameMutator: FittingSizeMutator where ExplicitView: _SystemFittingView {
    @inlinable
    @inline(__always)
    public func fittingSize(for view: Void, with availableSize: CGSize) -> CGSize {
        _view.sizeThatFits(availableSize)
    }
}
extension _KeyPathFittingMutator: RectAccessor where Subview: _SystemView {}
extension _KeyPathFittingMutator: RectMutator where Subview: _SystemView {
    @inlinable
    @inline(__always)
    public subscript(view: View) -> CGRect {
        get { view[keyPath: keyPath].frame }
        nonmutating set { view[keyPath: keyPath].frame = newValue }
    }
}
extension _KeyPathFittingMutator: FittingSizeMutator where Subview: _SystemFittingView {
    @inlinable
    @inline(__always)
    public subscript(view: View) -> CGRect {
        get { view[keyPath: keyPath].frame }
        nonmutating set { view[keyPath: keyPath].frame = newValue }
    }
    @inlinable
    @inline(__always)
    public func fittingSize(for view: View, with availableSize: CGSize) -> CGSize {
        view[keyPath: keyPath].sizeThatFits(availableSize)
    }
}

/// - ViewBasedLayout

extension Rect {
    @inlinable
    @inline(__always)
    public init(_ view: _SystemView, id: Int? = nil, @LayoutBuilder schemeBuilder: () -> Scheme) where Mutator == _ViewFrameMutator<_SystemView> {
        self.id = id
        self.mutator = _ViewFrameMutator(_view: view)
        self.scheme = schemeBuilder()
    }
}
extension FittingRect {
    @inlinable
    @inline(__always)
    public init(_ view: _SystemFittingView, id: Int? = nil, @LayoutBuilder schemeBuilder: () -> Scheme) where Mutator == _ViewFrameMutator<_SystemFittingView> {
        self.id = id
        self.mutator = _ViewFrameMutator(_view: view)
        self.scheme = schemeBuilder()
    }
    @inlinable
    @inline(__always)
    public init<Cache>(_ view: _SystemFittingView, cache: Cache, id: Int, @LayoutBuilder schemeBuilder: () -> Scheme) where Mutator == Cached<_ViewFrameMutator<_SystemFittingView>, Cache> {
        self.id = id
        self.mutator = Cached(id: id, base: _ViewFrameMutator(_view: view), cache: cache)
        self.scheme = schemeBuilder()
    }
    @inlinable
    @inline(__always)
    public init<View, Subview>(_ keyPath: KeyPath<View, Subview>, id: Int? = nil, @LayoutBuilder schemeBuilder: () -> Scheme) where Mutator == _KeyPathFittingMutator<View, Subview> {
        self.id = id
        self.mutator = _KeyPathFittingMutator(keyPath: keyPath)
        self.scheme = schemeBuilder()
    }
    @inlinable
    @inline(__always)
    public init<View, Subview, Cache>(_ keyPath: KeyPath<View, Subview>, cache: Cache, id: Int, @LayoutBuilder schemeBuilder: () -> Scheme) where Mutator == Cached<_KeyPathFittingMutator<View, Subview>, Cache>, Cache: CacheContainer {
        self.id = id
        self.mutator = Cached(id: id, base: _KeyPathFittingMutator(keyPath: keyPath), cache: cache)
        self.scheme = schemeBuilder()
    }
}

/// - ViewConstraints

extension ViewBasedLayout {
    @inlinable
    @inline(__always)
    public func constraints<RectConstraints>(_ view: _SystemView, viewID: Int, @LayoutBuilder constraints: () -> RectConstraints) -> ViewConstraints<_ViewFrameMutator<_SystemView>, RectConstraints, Self> {
        ViewConstraints(_ViewFrameMutator(_view: view), viewID: viewID, constraints: constraints(), layout: self)
    }
}

#endif
