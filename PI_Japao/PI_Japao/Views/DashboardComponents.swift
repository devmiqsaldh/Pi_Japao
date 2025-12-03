import SwiftUI

struct SessionCard: View {
    let session: AttendanceSessionDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: session.kind == .presence ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    .foregroundColor(session.kind == .presence ? AppTheme.accentColor : AppTheme.secondaryColor)
                Text(session.kind == .presence ? "Presença" : "Saída")
                    .font(.headline)
                Spacer()
                if let count = session.recordsCount, count > 0 {
                    Badge(count: count)
                }
            }
            
            HStack {
                // Correção: Label(date, style: .time) não existe; use Text(date, style: .time)
                Text(session.startTime, style: .time)
                    .font(.subheadline)
                Text("→")
                    .foregroundStyle(.secondary)
                Text(session.cutoffTime, style: .time)
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(8)
    }
}

struct BeaconCard: View {
    let beacon: BeaconDTO
    
    var body: some View {
        HStack {
            Circle()
                .fill(AppTheme.accentColor)
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: 4) {
                Text(beacon.name)
                    .font(.headline)
                Text(beacon.beaconID)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.successColor)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(8)
    }
}


struct Badge: View {
    let count: Int
    
    var body: some View {
        Text("\(count)")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppTheme.primaryColor)
            .cornerRadius(12)
    }
}
