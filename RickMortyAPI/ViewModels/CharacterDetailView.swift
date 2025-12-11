
import SwiftUI

struct CharacterDetailView: View {
    let character: RMCharacter
    @State private var note: String = ""
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    AsyncImage(url: URL(string: character.image)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else if phase.error != nil {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(height: 250)
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)

            Section("Info") {
                LabeledContent("Name", value: character.name)
                LabeledContent("Species", value: character.species)
                

                HStack {
                    Text("Status")
                    Spacer()
                    Text(character.status)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(character.status))
                        .clipShape(Capsule())
                }
                
                LabeledContent("Episodes", value: "\(character.episode.count)")
            }

   
            Section("Personal Notes") {
                TextEditor(text: $note)
                    .frame(minHeight: 100)
                    .focused($isNoteFocused)
                    .overlay(
                        Text("Write a note...")
                            .foregroundStyle(.gray.opacity(0.5))
                            .opacity(note.isEmpty && !isNoteFocused ? 1 : 0)
                            .padding(.top, 8)
                            .padding(.leading, 5),
                        alignment: .topLeading
                    )
            }
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNoteFocused {
                Button("Done") { isNoteFocused = false }
            }
        }
        .onAppear {
            note = CharacterNotes.load(for: character.id)
        }
        .onDisappear {
            CharacterNotes.save(note, for: character.id)
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "alive": return .green
        case "dead": return .red
        default: return .gray
        }
    }
}
