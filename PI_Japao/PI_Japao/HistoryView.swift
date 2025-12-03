import SwiftUI

struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.sessions.isEmpty {
                    Text("Nenhuma sessão encontrada")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.sessions) { session in
                        NavigationLink {
                            SessionDetailView(sessionID: session.id!, viewModel: viewModel)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(session.kind == .presence ? "Presença" : "Saída")
                                    .font(.headline)
                                HStack {
                                    Text(session.date, style: .date)
                                    Spacer()
                                    if let count = session.recordsCount {
                                        Text("Registros: \(count)")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Histórico")
            .task {
                await viewModel.loadSessions()
            }
            .refreshable {
                await viewModel.loadSessions()
            }
        }
    }
}

struct SessionDetailView: View {
    let sessionID: UUID
    @State private var detail: SessionDetailDTO?
    @State private var isLoading = false
    @State private var errorMessage: String?
    var viewModel: HistoryViewModel

    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if let detail = detail {
                ForEach(detail.records) { record in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(record.beacon?.name ?? "(Removido)")
                            .font(.headline)
                        Text("Status: \(record.status.rawValue)")
                        if !record.messageLog.isEmpty {
                            ForEach(Array(record.messageLog.enumerated()), id: \.offset) { _, line in
                                Text("• \(line)")
                                    .font(.caption)
                            }
                        }
                        if let updatedAt = record.updatedAt {
                            Text("Atualizado: \(updatedAt.formatted(date: .omitted, time: .shortened))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle(detail?.session.kind == .presence ? "Detalhe Presença" : "Detalhe Saída")
        .task {
            await loadDetail()
        }
    }
    
    private func loadDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            detail = try await viewModel.loadSessionDetail(id: sessionID)
        } catch {
            errorMessage = "Erro ao carregar detalhes: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
