import SwiftUI

struct StudentsListView: View {
    @State private var viewModel = StudentViewModel()
    @Environment(ErrorHandler.self) private var errorHandler
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.students.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.students.isEmpty {
                    EmptyStateView(
                        icon: "person.2.fill",
                        title: "Nenhum aluno cadastrado",
                        message: "Toque no botão + para adicionar um aluno"
                    )
                } else {
                    List {
                        ForEach(viewModel.students) { student in
                            NavigationLink {
                                StudentFormView(student: student, viewModel: viewModel)
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(AppTheme.primaryColor)
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Text(String(student.name.prefix(1).uppercased()))
                                                .font(.headline)
                                                .foregroundColor(.white)
                                        }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(student.name)
                                            .font(.headline)
                                        if let email = student.email, !email.isEmpty {
                                            Label(email, systemImage: "envelope.fill")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        if let phone = student.phone, !phone.isEmpty {
                                            Label(phone, systemImage: "phone.fill")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        if let beacon = student.beacon {
                                            Label("\(beacon.name)", systemImage: "antenna.radiowaves.left.and.right")
                                                .font(.caption2)
                                                .foregroundStyle(AppTheme.accentColor)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Alunos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack {
                    StudentFormView(viewModel: viewModel)
                }
            }
            .task {
                await loadData()
            }
            .refreshable {
                do {
                    try await viewModel.loadStudents()
                } catch {
                    errorHandler.handleAPIError(error)
                }
            }
        }
    }
    
    private func loadData() async {
        do {
            try await viewModel.loadBeacons()
            try await viewModel.loadStudents()
        } catch {
            errorHandler.handleAPIError(error)
        }
    }

    private func delete(at offsets: IndexSet) {
        Task {
            for idx in offsets {
                if let id = viewModel.students[idx].id {
                    do {
                        try await viewModel.deleteStudent(id: id)
                    } catch {
                        errorHandler.handleAPIError(error)
                    }
                }
            }
        }
    }
}

struct StudentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ErrorHandler.self) private var errorHandler
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
            errorHandler.handleAPIError(error)
        }
    }
}

#Preview("StudentsListView - Empty") {
    StudentsListView()
}

#Preview("StudentsListView - With Students") {
    let viewModel = StudentViewModel()
    viewModel.students = [
        StudentDTO(
            id: UUID(),
            name: "João Silva",
            email: "joao@email.com",
            phone: "+5511999999999",
            beaconID: UUID(),
            beacon: BeaconDTO(id: UUID(), beaconID: "550e8400-e29b-41d4-a716-446655440000", name: "Beacon João", isActive: true),
            createdAt: Date(),
            updatedAt: Date()
        ),
        StudentDTO(
            id: UUID(),
            name: "Maria Santos",
            email: "maria@email.com",
            phone: "+5511888888888",
            beaconID: UUID(),
            beacon: BeaconDTO(id: UUID(), beaconID: "550e8400-e29b-41d4-a716-446655440001", name: "Beacon Maria", isActive: true),
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    return StudentsListView()
}

#Preview("StudentFormView - New") {
    let viewModel = StudentViewModel()
    viewModel.beacons = [
        BeaconDTO(id: UUID(), beaconID: "550e8400-e29b-41d4-a716-446655440000", name: "Beacon 1", isActive: true),
        BeaconDTO(id: UUID(), beaconID: "550e8400-e29b-41d4-a716-446655440001", name: "Beacon 2", isActive: true)
    ]
    return NavigationStack {
        StudentFormView(viewModel: viewModel)
    }
}

#Preview("StudentFormView - Edit") {
    let viewModel = StudentViewModel()
    viewModel.beacons = [
        BeaconDTO(id: UUID(), beaconID: "550e8400-e29b-41d4-a716-446655440000", name: "Beacon 1", isActive: true)
    ]
    let student = StudentDTO(
        id: UUID(),
        name: "João Silva",
        email: "joao@email.com",
        phone: "+5511999999999",
        beaconID: viewModel.beacons[0].id,
        beacon: viewModel.beacons[0],
        createdAt: Date(),
        updatedAt: Date()
    )
    return NavigationStack {
        StudentFormView(student: student, viewModel: viewModel)
    }
}
