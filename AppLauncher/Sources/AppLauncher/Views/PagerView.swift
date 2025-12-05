import SwiftUI

struct PagerView<Content: View>: View {
    let pageCount: Int
    @Binding var currentPage: Int
    @ViewBuilder var content: (Int) -> Content

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(0..<pageCount, id: \.self) { page in
                            content(page)
                                .frame(width: width, height: geo.size.height)
                                .id(page)
                        }
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onEnded { value in
                            let threshold = width * 0.2
                            if value.translation.width < -threshold {
                                currentPage = min(currentPage + 1, pageCount - 1)
                            } else if value.translation.width > threshold {
                                currentPage = max(currentPage - 1, 0)
                            }
                            withAnimation(.easeInOut(duration: 0.25)) {
                                proxy.scrollTo(currentPage)
                            }
                        }
                )
                .simultaneousGesture(
                    TapGesture().onEnded {
                        // Propagate tap to parent
                    }
                )
                .onChange(of: currentPage) { newPage in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(newPage)
                    }
                }
            }
        }
    }
}

