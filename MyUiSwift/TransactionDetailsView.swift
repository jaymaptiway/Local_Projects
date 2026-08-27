import SwiftUI

struct TransactionDetailsView: View {
    let txn: Transaction

    private let navy = Color(red: 0.08, green: 0.20, blue: 0.38)

    private var isFailed: Bool {
        txn.status.lowercased() == "failed"
    }

    private var isCredit: Bool {
        txn.amount >= 0
    }

    private var statusColor: Color {
        if isFailed { return .red }
        return .green
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                amountCard

                Text("Transaction information")
                    .font(.headline)
                    .foregroundStyle(navy)
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    detailRow(title: "Transaction ID", value: txn.transaction_id, icon: "number")
                    detailRow(title: "From User", value: txn.from_user_id, icon: "person.fill")
                    detailRow(title: "To User", value: txn.to_user_id, icon: "person.fill.checkmark")
                    detailRow(title: "Transaction Type", value: txn.transaction_type.capitalized, icon: "arrow.left.arrow.right")
                    detailRow(title: "Date", value: formattedDate(txn.transaction_date), icon: "calendar")
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var amountCard: some View {
        VStack(spacing: 16) {
            Image(systemName: isFailed ? "exclamationmark.circle.fill" : (isCredit ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill"))
                .font(.system(size: 38))
                .foregroundStyle(.white)

            Text(isCredit ? "Money received" : "Money sent")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            Text("₹\(abs(txn.amount), specifier: "%.2f")")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(txn.status.capitalized)
                .font(.caption.weight(.semibold))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(.white)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .background(
            LinearGradient(
                colors: isFailed ? [Color.red, Color(red: 0.65, green: 0.08, blue: 0.12)] : [Color.green, Color(red: 0.05, green: 0.55, blue: 0.38)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: statusColor.opacity(0.2), radius: 14, y: 8)
        .padding(.horizontal)
    }

    private func detailRow(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                    .frame(width: 24)

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 12)

                Text(value.isEmpty ? "-" : value)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.trailing)
                    .textSelection(.enabled)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            if title != "Date" {
                Divider().padding(.leading, 52)
            }
        }
    }

    private func formattedDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

#Preview {
    TransactionDetailsView(
        txn: Transaction(
            transaction_id: "TXN-0001",
            from_user_id: "FBCI00001",
            to_user_id: "FBCI00002",
            amount: -1250,
            transaction_type: "send",
            status: "success",
            transaction_date: "2026-08-24T10:30:00Z"
        )
    )
}
