import SwiftUI

struct PageIndicatorView: View {
    let currentPage: Int
    let pageCount: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(0..<pageCount), id: \.self) { idx in
                Circle()
                    .fill(idx == currentPage ? Color.accentColor : Color.secondary.opacity(0.4))
                    .frame(width: 6, height: 6)
            }
        }
    }
}
