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
                                    HStack(spacing: 4) {
                                        Image(systemName: "antenna.radiowaves.left.and.right")
                                            .font(.caption2)
                                        Text("\(beacon.name)")
                                            .font(.caption2)
                                    }
                                    .foregroundStyle(AppTheme.accentColor)
                                    Text(beacon.beaconID)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
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
    @State var beaconID: String = ""
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
            _beaconID = State(initialValue: s.beacon?.beaconID ?? "")
        }
    }

    var body: some View {
        Form {
            Section("Identificação do Aluno") {
                TextField("Nome do Aluno", text: $name)
            }
            
            Section("Contato") {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                TextField("Telefone (opcional)", text: $phone)
                    .keyboardType(.phonePad)
            }
            
            Section {
                TextField("UUID do Beacon", text: $beaconID)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .disabled(student != nil) // Não permite editar UUID de aluno existente
                
                if student == nil {
                    Text("O beacon será criado automaticamente com o nome do aluno.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("UUID do beacon não pode ser alterado após o cadastro.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Beacon")
            } footer: {
                Text("Cada aluno deve ter um beacon único. O UUID será usado para identificação.")
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
                .disabled(isSaving || name.trimmingCharacters(in: .whitespaces).isEmpty || beaconID.trimmingCharacters(in: .whitespaces).isEmpty || email.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBeaconID = beaconID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validações
        guard !trimmedName.isEmpty else {
            errorHandler.show("Nome do aluno é obrigatório", type: .error)
            return
        }
        
        guard !trimmedEmail.isEmpty else {
            errorHandler.show("Email é obrigatório para receber notificações", type: .error)
            return
        }
        
        // Validação básica de email
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: trimmedEmail) else {
            errorHandler.show("Email inválido. Verifique o formato.", type: .error)
            return
        }
        
        guard !trimmedBeaconID.isEmpty else {
            errorHandler.show("UUID do beacon é obrigatório", type: .error)
            return
        }
        
        // Validação básica de UUID
        guard UUID(uuidString: trimmedBeaconID) != nil else {
            errorHandler.show("UUID do beacon inválido. Use um formato válido (ex: 550e8400-e29b-41d4-a716-446655440000)", type: .error)
            return
        }
        
        do {
            if let s = student, let id = s.id {
                // Edição: atualizar apenas dados do aluno
                try await viewModel.updateStudent(
                    id: id,
                    name: trimmedName,
                    email: trimmedEmail,
                    phone: trimmedPhone.isEmpty ? nil : trimmedPhone,
                    beaconID: nil // Não muda o beacon na edição
                )
                errorHandler.show("Aluno atualizado com sucesso!", type: .success)
                // Aguardar um pouco para mostrar mensagem de sucesso
                try? await Task.sleep(nanoseconds: 500_000_000)
                dismiss()
            } else {
                // Criação: criar aluno com beacon
                // Nome do beacon será gerado automaticamente: "Beacon de {nome do aluno}"
                let beaconName = "Beacon de \(trimmedName)"
                try await viewModel.createStudentWithBeacon(
                    name: trimmedName,
                    email: trimmedEmail,
                    phone: trimmedPhone.isEmpty ? nil : trimmedPhone,
                    beaconID: trimmedBeaconID,
                    beaconName: beaconName
                )
                errorHandler.show("Aluno cadastrado com sucesso!", type: .success)
                // Aguardar um pouco para mostrar mensagem de sucesso
                try? await Task.sleep(nanoseconds: 500_000_000)
                dismiss()
            }
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
