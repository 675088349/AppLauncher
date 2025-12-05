import SwiftUI

struct LauncherView: View {
    @EnvironmentObject var vm: LauncherViewModel

    @State private var containerSize: CGSize = .zero
    @State private var itemsPerPage: Int = 24
    @State private var appeared: Bool = false

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.closeFolder()
                    vm.dismissWindow()
                }

            VStack(spacing: 16) {
                SearchBarModern(text: $vm.searchText)
                    .padding(.horizontal, 96)
                    .frame(maxWidth: 560)
                    .padding(.top, 24)

                GeometryReader { geo in
                    let size = geo.size
                    Color.clear.onAppear {
                        containerSize = size
                        itemsPerPage = computeItemsPerPage(size: size)
                        vm.updatePageCount(itemsPerPage: itemsPerPage)
                    }
                    .onChange(of: size) { newSize in
                        containerSize = newSize
                        itemsPerPage = computeItemsPerPage(size: newSize)
                        vm.updatePageCount(itemsPerPage: itemsPerPage)
                    }

                    PagerView(pageCount: vm.pageCount, currentPage: $vm.currentPage) { page in
                        AppGridView(items: vm.pageItems(page: page, itemsPerPage: itemsPerPage), itemsPerPage: itemsPerPage) { item in
                            switch item {
                            case .app(let app): vm.launch(app)
                            case .folder(let folder): vm.beginFolder(folder)
                            }
                        } onGroup: { src, dst in
                            vm.group(source: src, target: dst)
                        }
                        .padding(.horizontal, 96)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.closeFolder()
                            vm.dismissWindow()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                PageIndicatorView(currentPage: vm.currentPage, pageCount: vm.pageCount)
                    .padding(.bottom, 16)
            }

            if vm.isFolderOpen, let folder = vm.activeFolder {
                FolderView(folder: folder)
                    .environmentObject(vm)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .background(BackgroundStyle())
        .scaleEffect(appeared ? 1.0 : 0.98)
        .opacity(appeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.currentPage)
        .animation(.easeInOut(duration: 0.25), value: vm.isFolderOpen)
        .onAppear {
            itemsPerPage = computeItemsPerPage(size: containerSize)
            vm.updatePageCount(itemsPerPage: itemsPerPage)
            NSApp.activate(ignoringOtherApps: true)
            withAnimation(.easeOut(duration: 0.22)) { appeared = true }
        }
    }

    private func computeItemsPerPage(size: CGSize) -> Int {
        let itemWidth: CGFloat = 96
        let itemHeight: CGFloat = 110
        let horizontalPadding: CGFloat = 192
        let verticalPadding: CGFloat = 64
        let spacing: CGFloat = 24
        let columns = min(max(Int((size.width - horizontalPadding + spacing) / (itemWidth + spacing)), 3), 8)
        let rows = max(Int((size.height - verticalPadding) / itemHeight), 3)
        return columns * rows
    }
}

struct BackgroundStyle: View {
    var body: some View {
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            .ignoresSafeArea()
    }
}
