# LayoutUI

Reimplemenation of [CGLayout](https://github.com/k-o-d-e-n/CGLayout) in SwiftUI-like style. More powerful than before.

```swift
var scheme: some Layout {
    Rect(subview0, id: 0) {
        if isLandscape {
            Height().scaled(0.5)
            Width().inset(100)
            Top()
            CenterX()
        } else {
            Width().inset(60)
            Height().scaled(0.3)
        }
    }
    if isLandscape {
        Rect(subview1, id: 1) {
            Height().scaled(0.2)
            Width().inset(50)
            Top()
            CenterX()
        }.constraints(subview0, viewID: 0) {
            MaxY.Pull.MinY()
            if isRTL { MidX.Limit.MinX() } else { MidX.Limit.MaxX() }
        }
    } else {
        Rect(subview1, id: 1) {
            Height().scaled(0.2)
            Width().inset(50)
            Top()
            CenterX()
        }.constraints(subview0, viewID: 0) {
            MaxY.After.Limit()
        }
    }
    FittingRect(label0, cache: sizeCache, id: 2) {
        Width.Current().inset(-10)
        CenterY()
        CenterX()
    }.constraints(subview0, viewID: 0)
}

/// ...
scheme.layout(in: view.bounds)
```

### Universal layout

```swift
var scheme: AnyViewLayout<TableViewCell> {
    /// ...
    FittingRect(\TableViewCell.label0, id: 2) {
        Width.Current().inset(-10)
        CenterY()
        CenterX()
    }.constraints(\.subview0.frame, viewID: 0)
    /// ...
}

/// ...
let cell = TableViewCell()
scheme.layout(cell, in: cell.contentView.bounds)
```

### SwiftUI

```swift
struct ContentView: View {
    var body: some View {
        if #available(iOS 16, *) {
            Text("Hello World").layout { labelLayout }
            Text("Hello World").fittingLayout {
                Bottom()
                Right().offset(-10)
            }
        } else {
            Text("Hello World").basicLayout { labelLayout }
        }
        if #available(iOS 16, *) {
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
    }
    @LayoutBuilder var labelLayout: some RectBasedLayout {
        Width.Constant(200)
        CenterX()
        CenterY()
    }
}
```

## Performance

<p align="center">
    <img src="Resources/benchmark_result.png">
    Performed by <a href="https://github.com/lucdion/LayoutFrameworkBenchmark">LayoutBenchmarkFramework</a>
</p>

