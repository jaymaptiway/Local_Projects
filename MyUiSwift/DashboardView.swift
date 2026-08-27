import SwiftUI
import UniformTypeIdentifiers

struct DashboardView: View {
    @ObservedObject var vm: BankingViewModel
    @State private var showAccountNumber = false

    private let navy = Color(red: 0.08, green: 0.20, blue: 0.38)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome,")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(vm.name ?? "Customer")
                                .font(.title.bold())
                                .foregroundStyle(navy)
                        }
                        Spacer()
                        Image(systemName: "building.columns.fill")
                            .font(.title3)
                            .foregroundStyle(navy)
                            .frame(width: 44, height: 44)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }

                    balanceCard

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Quick actions")
                            .font(.headline)
                            .foregroundStyle(navy)
                        HStack(spacing: 12) {
                            actionLink(title: "Send", icon: "arrow.up.right", color: .blue, destination: TransferView(vm: vm))
                            actionLink(title: "Receive", icon: "arrow.down.left", color: .green, destination: ReceiveView(vm: vm))
                            actionLink(title: "Scan & Pay", icon: "qrcode.viewfinder", color: .orange, destination: ScanPayView(vm: vm))
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Last 5 transactions")
                                .font(.headline)
                                .foregroundStyle(navy)
                            Spacer()
                            NavigationLink("View all") {
                                AllTransactionsView(transactions: vm.transactions)
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.blue)
                        }

                        if vm.transactions.isEmpty {
                            emptyTransactionsView
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(vm.transactions.prefix(5))) { transaction in
                                    NavigationLink(destination: TransactionDetailsView(txn: transaction)) {
                                        transactionRow(transaction)
                                    }
                                    .buttonStyle(.plain)
                                    if transaction.id != vm.transactions.prefix(10).last?.id {
                                        Divider().padding(.leading, 52)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Fraud Bank")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ProfileView(vm: vm)) {
                        Image(systemName: "person.crop.circle")
                            .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("Profile")
                }
            }
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Label("ACCOUNT", systemImage: "wallet.pass.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                HStack(spacing: 8) {
                    Text(showAccountNumber ? (vm.account_number ?? "-") : "•••• \(String(vm.account_number?.suffix(4) ?? "----"))")
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Button {
                        showAccountNumber.toggle()
                        
                    } label: {
                        Image(systemName: showAccountNumber ? "eye.slash" : "eye")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .accessibilityLabel(showAccountNumber ? "Hide account number" : "Show account number")
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Available balance")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                Text("₹\(vm.balance ?? 0, specifier: "%.2f")")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [navy, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: navy.opacity(0.2), radius: 14, y: 8)
    }

    private func actionLink<Destination: View>(title: String, icon: String, color: Color, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(color)
                    .frame(width: 46, height: 46)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(navy)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func transactionRow(_ transaction: Transaction) -> some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.amount >= 0 ? "arrow.down.left" : "arrow.up.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(transaction.amount >= 0 ? .green : .red)
                .frame(width: 36, height: 36)
                .background((transaction.amount >= 0 ? Color.green : Color.red).opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.transaction_type.capitalized)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(transaction.transaction_date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 4) {
                Text("₹\(abs(transaction.amount), specifier: "%.2f")")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(transaction.status.lowercased() == "failed" ? .purple : (transaction.amount >= 0 ? .green : .red))
                Text(transaction.status.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 14)
    }

    private var emptyTransactionsView: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No transactions yet")
                .font(.subheadline.weight(.semibold))
            Text("Your recent activity will appear here.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DashboardView(vm: BankingViewModel())
}

struct AllTransactionsView: View {
    let transactions: [Transaction]
    @State private var showingExporter = false
    @State private var selectedFilter = TransactionFilter.all

    private let navy = Color(red: 0.08, green: 0.20, blue: 0.38)

    private enum TransactionFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case success = "Success"
        case failed = "Failed"
        case send = "Send"
        case receive = "Receive"

        var id: String { rawValue }
    }

    private var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            switch selectedFilter {
            case .all:
                true
            case .success:
                transaction.status.lowercased() == "success"
            case .failed:
                transaction.status.lowercased() == "failed"
            case .send:
                transaction.transaction_type.lowercased() == "send"
            case .receive:
                transaction.transaction_type.lowercased() == "receive"
            }
        }
    }

    var body: some View {
        Group {
            if filteredTransactions.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(transactions.isEmpty ? "No transactions yet" : "No matching transactions")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredTransactions) { transaction in
                    NavigationLink(destination: TransactionDetailsView(txn: transaction)) {
                        transactionRow(transaction)
                    }
                }
                .listStyle(.plain)
            }
        }
        .safeAreaInset(edge: .top) {
            Picker("Transaction filter", selection: $selectedFilter) {
                ForEach(TransactionFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.bar)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("All Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingExporter = true
                } label: {
                    Image(systemName: "arrow.down.doc")
                }
                .accessibilityLabel("Download transactions")
            }
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: TransactionCSVDocument(contents: transactionCSV),
            contentType: .commaSeparatedText,
            defaultFilename: "transactions.csv"
        ) { _ in }
    }

    private func transactionRow(_ transaction: Transaction) -> some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.amount >= 0 ? "arrow.down.left" : "arrow.up.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(transaction.amount >= 0 ? .green : .red)
                .frame(width: 36, height: 36)
                .background((transaction.amount >= 0 ? Color.green : Color.red).opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.transaction_type.capitalized)
                    .font(.subheadline.weight(.semibold))
                Text(transaction.transaction_date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 4) {
                Text("₹\(abs(transaction.amount), specifier: "%.2f")")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(transaction.status.lowercased() == "failed" ? .purple : (transaction.amount >= 0 ? .green : .red))
                Text(transaction.status.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    private var transactionCSV: String {
        let header = "Transaction ID,From User,To User,Amount,Type,Status,Date"
        let rows = filteredTransactions.map { transaction in
            [transaction.transaction_id, transaction.from_user_id, transaction.to_user_id,
             String(format: "%.2f", transaction.amount), transaction.transaction_type,
             transaction.status, transaction.transaction_date]
                .map(csvValue)
                .joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n")
    }

    private func csvValue(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}

private struct TransactionCSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }

    let contents: String

    init(contents: String) {
        self.contents = contents
    }

    init(configuration: ReadConfiguration) throws {
        contents = String(decoding: configuration.file.regularFileContents ?? Data(), as: UTF8.self)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(contents.utf8))
    }
}
