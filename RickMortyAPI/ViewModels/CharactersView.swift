import SwiftUI

struct CharactersView: View {
    @StateObject private var vm = CharactersVM()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Character search", text: $vm.searchText)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            Task { await vm.applySearch() }
                        }
                    
                    if !vm.searchText.isEmpty {
                        Button("Erase") {
                            vm.searchText = ""
                            Task { await vm.applySearch() }
                        }
                    }
                }
                .padding()
                
                switch vm.state {
                case .idle, .loading:
                    ProgressView("Loading...")
                        .scaleEffect(1.5)
                        .frame(maxHeight: .infinity)
                        
                case .failed(let errorMessage):
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        Text("Error: \(errorMessage)")
                            .multilineTextAlignment(.center)
                        Button("Try again") {
                            Task { await vm.firstLoad() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxHeight: .infinity)
                    
                case .loaded:
                    List(vm.characters) { character in
                        HStack {
                            AsyncImage(url: URL(string: character.image)) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fit)
                                } else if phase.error != nil {
                                    Color.red
                                } else {
                                    Color.gray
                                }
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(character.name)
                                    .font(.headline)
                                Text(character.species)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    

                    HStack {
                        Button("Previous") {
                            Task { await vm.prevPage() }
                        }
                        .disabled(vm.info?.prev == nil)
                        
                        Spacer()
                        
                        Text("This page")
                            .font(.caption)
                        
                        Spacer()
                        
                        Button("Next") {
                            Task { await vm.nextPage() }
                        }
                        .disabled(vm.info?.next == nil)
                    }
                    .padding()
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

#Preview {
    CharactersView()
}
