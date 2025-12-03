import SwiftUI

struct StudentsListView: View {
    @State private var viewModel = StudentViewModel()
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.students.isEmpty {
                    Text("Nenhum aluno cadastrado")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.students) { student in
                        NavigationLink {
                            StudentFormView(student: student, viewModel: viewModel)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(student.name)
                                    .font(.headline)
                                if let email = student.email, !email.isEmpty {
                                    Text("Email: \(email)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if let phone = student.phone, !phone.isEmpty {
                                    Text("Telefone: \(phone)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if let beacon = student.beacon {
                                    Text("Beacon: \(beacon.name) (\(beacon.beaconID))")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
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
            .navigationTitle("Alunos")
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
                    StudentFormView(viewModel: viewModel)
                }
            }
            .task {
                await viewModel.loadBeacons()
                await viewModel.loadStudents()
            }
            .refreshable {
                await viewModel.loadStudents()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        Task {
            for idx in offsets {
                if let id = viewModel.students[idx].id {
                    try? await viewModel.deleteStudent(id: id)
                }
            }
        }
    }
}

struct StudentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State var name: String = ""
    @State var email: String = ""
    @State var phone: String = ""
    @State var selectedBeaconID: UUID?
    @State var isSaving = false
    
    var student: StudentDTO?
    var viewModel: StudentViewModel

    init(student: StudentDTO? = nil, viewModel: StudentViewModel) {
        self.student = student
        self.viewModel = viewModel
        if let s = student {
            _name = State(initialValue: s.name)
            _email = State(initialValue: s.email ?? "")
            _phone = State(initialValue: s.phone ?? "")
            _selectedBeaconID = State(initialValue: s.beaconID)
        }
    }

    var body: some View {
        Form {
            Section("Identificação") {
                TextField("Nome do Aluno", text: $name)
            }
            Section("Contato") {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Telefone", text: $phone)
                    .keyboardType(.phonePad)
            }
            Section("Beacon") {
                if viewModel.beacons.isEmpty {
                    Text("Nenhum beacon disponível. Cadastre um beacon primeiro.")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Beacon", selection: $selectedBeaconID) {
                        Text("Selecione um beacon").tag(nil as UUID?)
                        ForEach(viewModel.beacons) { beacon in
                            Text("\(beacon.name) (\(beacon.beaconID))")
                                .tag(beacon.id as UUID?)
                        }
                    }
                }
            }
        }
        .navigationTitle(student == nil ? "Novo Aluno" : "Editar Aluno")
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
                .disabled(isSaving || name.trimmingCharacters(in: .whitespaces).isEmpty || selectedBeaconID == nil)
            }
        }
    }

    private func save() async {
        guard let beaconID = selectedBeaconID else { return }
        
        isSaving = true
        defer { isSaving = false }
        
        do {
            if let s = student, let id = s.id {
                try await viewModel.updateStudent(
                    id: id,
                    name: name,
                    email: email.isEmpty ? nil : email,
                    phone: phone.isEmpty ? nil : phone,
                    beaconID: beaconID
                )
            } else {
                try await viewModel.createStudent(
                    name: name,
                    email: email.isEmpty ? nil : email,
                    phone: phone.isEmpty ? nil : phone,
                    beaconID: beaconID
                )
            }
            dismiss()
        } catch {
            print("❌ Erro ao salvar: \(error)")
        }
    }
}

