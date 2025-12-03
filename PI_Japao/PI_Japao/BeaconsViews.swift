import SwiftUI

struct BeaconsListView: View {
    @State private var viewModel = BeaconViewModel()
    @Environment(AttendanceManager.self) private var attendanceManager
    @State private var showingAdd = false
    @State private var selectedBeacon: BeaconDTO?

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.beacons.isEmpty {
                    Text("Nenhum beacon cadastrado")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.beacons) { beacon in
                        NavigationLink {
                            BeaconFormView(beacon: beacon, viewModel: viewModel)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(beacon.name)
                                    .font(.headline)
                                Text("ID: \(beacon.beaconID)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Toggle("Ativo", isOn: Binding(
                                    get: { beacon.isActive },
                                    set: { newValue in
                                        Task {
                                            try? await viewModel.updateBeacon(id: beacon.id!, isActive: newValue)
                                        }
                                    }
                                ))
                                .toggleStyle(.switch)
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Beacons")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Label("Adicionar", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack {
                    BeaconFormView(viewModel: viewModel)
                }
            }
            .task {
                await viewModel.loadBeacons()
            }
            .refreshable {
                await viewModel.loadBeacons()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        Task {
            for idx in offsets {
                if let id = viewModel.beacons[idx].id {
                    try? await viewModel.deleteBeacon(id: id)
                }
            }
        }
    }
}

struct BeaconFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State var beaconID: String = ""
    @State var name: String = ""
    @State var isActive: Bool = true
    @State var isSaving = false
    
    var beacon: BeaconDTO?
    var viewModel: BeaconViewModel

    init(beacon: BeaconDTO? = nil, viewModel: BeaconViewModel) {
        self.beacon = beacon
        self.viewModel = viewModel
        if let b = beacon {
            _beaconID = State(initialValue: b.beaconID)
            _name = State(initialValue: b.name)
            _isActive = State(initialValue: b.isActive)
        }
    }

    var body: some View {
        Form {
            Section("Identificação") {
                TextField("ID do Beacon (UUID)", text: $beaconID)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(beacon != nil) // Não permite editar ID existente
                TextField("Nome", text: $name)
            }
            Section {
                Toggle("Ativo", isOn: $isActive)
            }
        }
        .navigationTitle(beacon == nil ? "Novo Beacon" : "Editar Beacon")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salvar") {
                    Task {
                        await save()
                    }
                }
                .disabled(isSaving || beaconID.trimmingCharacters(in: .whitespaces).isEmpty || name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        
        let trimmedID = beaconID.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            if let b = beacon, let id = b.id {
                try await viewModel.updateBeacon(id: id, name: name, isActive: isActive)
            } else {
                try await viewModel.createBeacon(beaconID: trimmedID, name: name, isActive: isActive)
                await attendanceManager.refreshBeacons()
            }
            dismiss()
        } catch {
            print("❌ Erro ao salvar: \(error)")
        }
    }
}
