import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: DreamListViewModel

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("About")) {
                    Text("Dream Todo App")
                    Text("Designed to help you follow your dreams.")
                }
                Section {
                    NavigationLink("Archived Dreams") {
                        ArchivedListView(viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}



struct ArchivedListView: View {
    @ObservedObject var viewModel: DreamListViewModel

    var body: some View {
        List {
            ForEach(viewModel.dreams.filter { $0.isArchived }) { dream in
                HStack {
                    Text(dream.name)
                    Spacer()
                    Button("Restore") {
                        var restored = dream
                        restored.isArchived = false
                        viewModel.updateDream(restored)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .navigationTitle("Archived Dreams")
    }
}
