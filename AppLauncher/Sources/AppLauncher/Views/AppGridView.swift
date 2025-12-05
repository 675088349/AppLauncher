import SwiftUI
import UniformTypeIdentifiers

struct AppGridView: View {
    let items: [LaunchItem]
    let itemsPerPage: Int
    var onSelect: (LaunchItem) -> Void
    var onGroup: ((LaunchItem, LaunchItem) -> Void)? = nil

    @EnvironmentObject var vm: LauncherViewModel

    private var columns: [GridItem] { Array(repeating: GridItem(.fixed(96), spacing: 24, alignment: .center), count: max(itemsPerRow, 3)) }

    @State private var gridWidth: CGFloat = 0
    private var itemsPerRow: Int {
        if gridWidth <= 0 { return 7 }
        let maxColumns = 8
        let spacing: CGFloat = 24
        let columns = Int((gridWidth + spacing) / (96 + spacing))
        return min(max(columns, 3), maxColumns)
    }

    var body: some View {
        GeometryReader { geo in
            Color.clear.onAppear { gridWidth = geo.size.width }
                .onChange(of: geo.size.width) { newValue in gridWidth = newValue }

            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(items, id: \.id) { item in
                    AppIconView(item: item)
                        .simultaneousGesture(TapGesture().onEnded { onSelect(item) })
                        .onDrag { NSItemProvider(object: NSString(string: item.id.uuidString)) }
                        .onDrop(of: [UTType.text], delegate: DropReorderDelegate(item: item, items: $vm.items, onGroup: onGroup))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct DropReorderDelegate: DropDelegate {
    let item: LaunchItem
    @Binding var items: [LaunchItem]
    var onGroup: ((LaunchItem, LaunchItem) -> Void)?

    func performDrop(info: DropInfo) -> Bool {
        guard let sourceID = extractID(info: info) else { return true }
        // Grouping logic disabled to prevent item disappearance during reordering
        // To re-enable, we need a more robust way to distinguish 'drop to reorder' from 'drop to group'
        // For now, we prioritize stable reordering.
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let sourceID = extractID(info: info) else { return }
        let sourceIndex = items.firstIndex { $0.id.uuidString == sourceID }
        let targetIndex = items.firstIndex(of: item)
        if let sIdx = sourceIndex, let tIdx = targetIndex, sIdx != tIdx {
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                    if sIdx < items.count, tIdx < items.count {
                        items.move(fromOffsets: IndexSet(integer: sIdx), toOffset: tIdx > sIdx ? tIdx + 1 : tIdx)
                    }
                }
            }
        }
    }

    private func extractID(info: DropInfo) -> String? {
        guard let provider = info.itemProviders(for: [UTType.text]).first else { return nil }
        var idStr: String?
        let semaphore = DispatchSemaphore(value: 0)
        _ = provider.loadObject(ofClass: NSString.self) { (object, error) in
            if let s = object as? String {
                idStr = s
            }
            semaphore.signal()
        }
        semaphore.wait()
        return idStr
    }
}
