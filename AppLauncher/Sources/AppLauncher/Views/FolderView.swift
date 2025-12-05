import SwiftUI
import UniformTypeIdentifiers

struct FolderView: View {
    let folder: FolderItem
    @EnvironmentObject var vm: LauncherViewModel
    @State private var name: String

    init(folder: FolderItem) {
        self.folder = folder
        _name = State(initialValue: folder.name)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("文件夹名称", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 320)
                Button("完成") { vm.renameFolder(folder: folder, name: name); vm.closeFolder() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8)

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(96), spacing: 24), count: 6), spacing: 24) {
                ForEach(folder.apps, id: \.id) { app in
                    AppIconView(item: .app(app))
                        .onDrag { NSItemProvider(object: NSString(string: app.id.uuidString)) }
                        .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                            false
                        }
                }
            }

            Button("关闭") { vm.closeFolder() }
                .buttonStyle(.bordered)
                .padding(.bottom, 8)
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
    }
}
