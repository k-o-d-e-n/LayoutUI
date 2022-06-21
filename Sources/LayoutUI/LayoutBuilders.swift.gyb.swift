%{
type_names = {2:'Two', 3:'Three', 4:'Four', 5:'Five', 6:'Six', 7:'Seven', 8:'Eight', 9:'Nine', 10: 'Ten', 11: 'Eleven', 12: 'Twelve', 13: 'Thirteen', 14: 'Fourteen', 15: 'Fifteen'}
elements = ['C0', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13', 'C14']
}%
///
/// Generated by Swift GYB.
///

import CoreGraphics

/// MARK: - RectBasedLayout

% for count in type_names:
public struct ${type_names[count]}RectLayout<${', '.join(elements[:count])}>: RectBasedLayout
where ${', '.join(map(lambda x: x + ': RectBasedLayout', elements[:count]))} {
    % for i in range(0, count):
    @usableFromInline
    let c${i}: C${i}
    % end
    @usableFromInline
    init(${', '.join(map(lambda x: 'c' + str(x) + ': C' + str(x), range(0, count)))}) {
        % for i in range(0, count):
        self.c${i} = c${i}
        % end
    }
    @inlinable
    @inline(__always)
    public func layout(_ rect: inout CGRect, with source: CGRect) {
        % for i in range(0, count):
        c${i}.layout(&rect, with: source)
        % end
    }
}
% end

extension LayoutBuilder {
    % for count in type_names:
    @inlinable
    @inline(__always)
    public static func buildBlock<${', '.join(elements[:count])}>(
    ${', '.join(map(lambda x, y: '_ c' + str(x) + ': ' + y, range(0, count), elements[:count]))}
    ) -> ${type_names[count]}RectLayout<${', '.join(elements[:count])}> {
        ${type_names[count]}RectLayout(${', '.join(map(lambda x: 'c' + str(x) + ': ' 'c' + str(x), range(0, count)))})
    }
    % end
}

/// MARK: - ViewBasedLayout

% for count in type_names:
public struct ${type_names[count]}ViewLayout<${', '.join(elements[:count])}>: ViewBasedLayout
where ${', '.join(map(lambda x: x + ': ViewBasedLayout', elements[:count]))},
${', '.join(map(lambda x: x + '.View == C0.View', elements[1:count]))}
{
    % for i in range(0, count):
    @usableFromInline
    let c${i}: C${i}
    % end
    @usableFromInline
    init(${', '.join(map(lambda x: 'c' + str(x) + ': C' + str(x), range(0, count)))}) {
        % for i in range(0, count):
        self.c${i} = c${i}
        % end
    }
    @inlinable
    @inline(__always)
    public func layout(_ view: C0.View, in source: CGRect) {
        % for i in range(0, count):
        c${i}.layout(view, in: source)
        % end
    }
    @inlinable
    @inline(__always)
    public func layout(to snapshot: inout LayoutSnapshot, with view: C0.View, in source: CGRect) {
        % for i in range(0, count):
        c${i}.layout(to: &snapshot, with: view, in: source)
        % end
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: C0.View) {
        % for i in range(0, count):
        c${i}.apply(snapshot, for: view)
        % end
    }
}
extension ${type_names[count]}ViewLayout: Layout where C0.View == Void {}
% end

extension LayoutBuilder {
    % for count in type_names:
    @inlinable
    @inline(__always)
    public static func buildBlock<${', '.join(elements[:count])}>(
    ${', '.join(map(lambda x, y: '_ c' + str(x) + ': ' + y, range(0, count), elements[:count]))}
    ) -> ${type_names[count]}ViewLayout<${', '.join(elements[:count])}> {
        ${type_names[count]}ViewLayout(${', '.join(map(lambda x: 'c' + str(x) + ': ' 'c' + str(x), range(0, count)))})
    }
    % end
}