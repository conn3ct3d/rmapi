import SwiftUI

struct CharactersView: View {
    @StateObject private var vm = CharactersVM()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search character...", text: $vm.searchText)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                Task { await vm.applySearch() }
                            }
                        
                        if !vm.searchText.isEmpty {
                            Button {
                                vm.searchText = ""
                                Task { await vm.applySearch() }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
                
                switch vm.state {
                case .idle:
                    ContentUnavailableView("Search for a character", systemImage: "person.fill.questionmark")
                    
                case .loading:
                    ProgressView("Loading...")
                        .scaleEffect(1.5)
                        .frame(maxHeight: .infinity)
                        
                case .failed(let errorMessage):
                    ContentUnavailableView {
                        Label("Something went wrong", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Try again") {
                            Task { await vm.firstLoad() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                case .loaded:
                    List {
                        ForEach(vm.characters) { character in
                            NavigationLink(destination: CharacterDetailView(character: character)) {
                                CharacterRowView(character: character)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await vm.applySearch()
                    }
                    
                    PaginationView(vm: vm)
                }
            }
            .navigationTitle("Rick & Morty")
            .task {
                if vm.state == .idle {
                    await vm.firstLoad()
                }
            }
        }
    }
}

struct CharacterRowView: View {
    let character: RMCharacter
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: character.image)) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fit)
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor(character.status))
                        .frame(width: 8, height: 8)
                    Text(character.status)
                    Text("•")
                    Text(character.species)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }
    
    func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "alive": return .green
        case "dead": return .red
        default: return .gray
        }
    }
}

struct PaginationView: View {
    @ObservedObject var vm: CharactersVM
    
    var body: some View {
        HStack {
            Button {
                Task { await vm.prevPage() }
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Prev")
                }
            }
            .disabled(vm.info?.prev == nil)
            
            Spacer()
            

            Text("Page Navigation")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button {
                Task { await vm.nextPage() }
            } label: {
                HStack {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
            }
            .disabled(vm.info?.next == nil)
        }
        .padding()
        .background(.regularMaterial)
    }
}

#Preview {
    CharactersView()
}
