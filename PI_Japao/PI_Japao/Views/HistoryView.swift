import SwiftUI

struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.sessions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(AppTheme.primaryColor.opacity(0.3))
                        Text("Nenhuma sessão encontrada")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("As sessões aparecerão aqui após detecções")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.sessions) { session in
                            NavigationLink {
                                SessionDetailView(sessionID: session.id!, viewModel: viewModel)
                            } label: {
                                HStack {
                                    Image(systemName: session.kind == .presence ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(session.kind == .presence ? AppTheme.accentColor : AppTheme.secondaryColor)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.kind == .presence ? "Presença" : "Saída")
                                            .font(.headline)
                                        Text(session.date, style: .date)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if let count = session.recordsCount {
                                        Badge(count: count)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                if let error = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        ErrorCard(message: error)
                            .padding()
                    }
                }
            }
            .navigationTitle("Histórico")
            .navigationBarTitleDisplayMode(.large)
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

#Preview("HistoryView - Empty") {
    HistoryView()
}

#Preview("HistoryView - With Sessions") {
    HistoryView()
}

#Preview("SessionDetailView") {
    NavigationStack {
        SessionDetailView(sessionID: UUID(), viewModel: HistoryViewModel())
    }
}
