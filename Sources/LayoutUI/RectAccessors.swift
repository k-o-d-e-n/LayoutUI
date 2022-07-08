//
//  RectAccessors.swift
//  LayoutUI
//
//  Created by Denis Koryttsev on 21.06.2022.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import CoreGraphics
#else
import Foundation
#endif

public protocol RectAccessor {
    associatedtype View
    subscript(view: View) -> CGRect { get }
}
public protocol RectMutator: RectAccessor {
    subscript(view: View) -> CGRect { get nonmutating set }
}
public protocol FittingSizeMutator: RectMutator {
    func fittingSize(for view: View, with availableSize: CGSize) -> CGSize
}

///

public struct _ConstantRect<View>: RectAccessor {
    @usableFromInline
    let value: CGRect
    @usableFromInline
    init(value: CGRect) { self.value = value }
    @inlinable
    @inline(__always)
    public subscript(view: View) -> CGRect { value }
}
public struct _KeyPathRectAccessor<View>: RectAccessor {
    @usableFromInline
    let keyPath: KeyPath<View, CGRect>
    @usableFromInline
    init(keyPath: KeyPath<View, CGRect>) {
        self.keyPath = keyPath
    }
    @inlinable
    @inline(__always)
    public subscript(view: View) -> CGRect {
        view[keyPath: keyPath]
    }
}
public struct _KeyPathRectMutator<View>: RectMutator {
    @usableFromInline
    let keyPath: ReferenceWritableKeyPath<View, CGRect>
    @usableFromInline
    init(keyPath: ReferenceWritableKeyPath<View, CGRect>) {
        self.keyPath = keyPath
    }
    @inlinable
    @inline(__always)
    public subscript(view: View) -> CGRect {
        get { view[keyPath: keyPath] }
        nonmutating set { view[keyPath: keyPath] = newValue }
    }
}
public struct _KeyPathFittingMutator<View, Subview> {
    @usableFromInline
    let keyPath: KeyPath<View, Subview>
    @usableFromInline
    init(keyPath: KeyPath<View, Subview>) {
        self.keyPath = keyPath
    }
}

///

public protocol CacheContainer {
    associatedtype Value
    subscript(id: Int) -> Value? { get nonmutating set }
}

public struct Cached<Base, Cache>: FittingSizeMutator where Base: FittingSizeMutator, Cache: CacheContainer, Cache.Value == CGSize {
    @usableFromInline
    let id: Int
    @usableFromInline
    let base: Base
    @usableFromInline
    let cache: Cache
    @usableFromInline
    init(id: Int, base: Base, cache: Cache) {
        self.id = id
        self.base = base
        self.cache = cache
    }
    @inlinable
    @inline(__always)
    public subscript(view: Base.View) -> CGRect {
        get { base[view] }
        nonmutating set { base[view] = newValue }
    }
    @inlinable
    @inline(__always)
    public func fittingSize(for view: Base.View, with availableSize: CGSize) -> CGSize {
        guard let val = cache[id] else { // TODO: Cache by available size?
            let size = base.fittingSize(for: view, with: availableSize)
            cache[id] = size
            return size
        }
        return val
    }
}
