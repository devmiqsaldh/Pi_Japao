import SwiftUI

struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()
    @Environment(ErrorHandler.self) private var errorHandler

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.sessions.isEmpty {
                    EmptyStateView(
                        icon: "clock.fill",
                        title: "Nenhuma sessão encontrada",
                        message: "As sessões aparecerão aqui após detecções de beacons"
                    )
                } else {
                    List {
                        ForEach(viewModel.sessions) { session in
                            if let id = session.id {
                                NavigationLink {
                                    SessionDetailView(sessionID: id, viewModel: viewModel)
                                } label: {
                                    HStack(spacing: 12) {
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
                            } else {
                                // Sessão sem ID (defensivo): apenas mostra como linha estática
                                HStack(spacing: 12) {
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
            }
            .navigationTitle("Histórico")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadSessions()
            }
            .refreshable {
                await loadSessions()
            }
        }
    }
    
    private func loadSessions() async {
        do {
            try await viewModel.loadSessions()
        } catch {
            errorHandler.handleAPIError(error)
        }
    }
}

struct SessionDetailView: View {
    let sessionID: UUID
    @State private var detail: SessionDetailDTO?
    @State private var isLoading = false
    var viewModel: HistoryViewModel
    @Environment(ErrorHandler.self) private var errorHandler

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
        }
        .navigationTitle(detail?.session.kind == .presence ? "Detalhe Presença" : "Detalhe Saída")
        .task {
            await loadDetail()
        }
    }
    
    private func loadDetail() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            detail = try await viewModel.loadSessionDetail(id: sessionID)
        } catch {
            errorHandler.handleAPIError(error)
        }
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
