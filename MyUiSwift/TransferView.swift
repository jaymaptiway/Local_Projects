import SwiftUI

struct TransferView: View {
    @ObservedObject var vm: BankingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var recipient = ""
    @State private var showSuccessOverlay = false
    @State private var showMessage = ""
    @State private var showMessageTitle = ""
    @State private var overlayImage = ""
    @State private var overlayImageColor = Color.green
    @State private var showLoader = false
    @State private var showMPIN = false
    @State private var users: [BankApiData] = []

    private let navy = Color(red: 0.08, green: 0.20, blue: 0.38)

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    pageHeader(icon: "arrow.up.right", title: "Send money", subtitle: "Transfer funds securely to another account.")
                    VStack(alignment: .leading, spacing: 18) {
                        fieldLabel("Recipient")
                        VStack(alignment: .leading, spacing: 0) {
                            inputField(icon: "person.fill", placeholder: "Name, customer ID, or UPI ID", text: $recipient)

                            if !recipient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !matchingUsers.isEmpty {
                                VStack(spacing: 0) {
                                    ForEach(matchingUsers, id: \.user_id) { user in
                                        Button {
                                            recipient = user.user_id ?? user.upi_id ?? user.name ?? ""
                                        } label: {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(user.name ?? "Unnamed user")
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(.primary)
                                                HStack(spacing: 8) {
                                                    Text(user.user_id ?? "No customer ID")
                                                    if let upiID = user.upi_id, !upiID.isEmpty {
                                                        Text("•")
                                                        Text(upiID)
                                                    }
                                                }
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                        }
                                        .buttonStyle(.plain)

                                        if user.user_id != matchingUsers.last?.user_id {
                                            Divider().padding(.leading, 16)
                                        }
                                    }
                                }
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                                .padding(.top, 8)
                            }
                        }
                        fieldLabel("Amount")
                        HStack(spacing: 10) {
                            Text("₹").font(.title2.bold()).foregroundStyle(navy)
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 64)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        HStack {
                            Label("Available balance", systemImage: "wallet.pass.fill")
                                .font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            Text("₹\(vm.balance ?? 0, specifier: "%.2f")")
                                .font(.caption.bold()).foregroundStyle(navy)
                        }
                    }
                    .padding(20)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    Button(action: reviewTransfer) {
                        Label("Review and Send", systemImage: "arrow.up.right.circle.fill")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(navy)
                    .disabled(showLoader || recipient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(amount) == nil || (Double(amount) ?? 0) <= 0)
                }
                .padding(20)
            }
        }
        .navigationTitle("Send Money")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadUsers)
        .overlay(resultOverlay)
        .fullScreenCover(isPresented: $showMPIN) {
            NavigationStack {
                MPINView(recipient: recipient, amount: Double(amount) ?? 0) {
                    executeTransfer()
                }
            }
        }
    }

    private func pageHeader(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.title2.bold()).foregroundStyle(.white).frame(width: 48, height: 48).background(navy).clipShape(RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title2.bold()).foregroundStyle(navy)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }

    private func fieldLabel(_ title: String) -> some View { Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(navy) }

    private func inputField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(.secondary).frame(width: 20)
            TextField(placeholder, text: text).textInputAutocapitalization(.never).autocorrectionDisabled()
        }
        .padding(.horizontal, 16).frame(height: 54).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 13))
    }

    private var matchingUsers: [BankApiData] {
        let query = recipient.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return [] }

        return users.filter { user in
            user.user_id?.lowercased().contains(query) == true ||
            user.name?.lowercased().contains(query) == true ||
            user.upi_id?.lowercased().contains(query) == true
        }
        .filter { $0.user_id != vm.user_id }
        .prefix(6)
        .map { $0 }
    }

    private func loadUsers() {
        guard users.isEmpty else { return }
        NetworkManager.shared.initilizedFramework()
        NetworkManager.shared.getAllUsers { result, _ in
            DispatchQueue.main.async {
                users = result ?? []
            }
        }
    }

    private var resultOverlay: some View {
        ZStack {
            if showSuccessOverlay {
                Color.black.opacity(0.35).ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: overlayImage)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(overlayImageColor)
                        .frame(width: 76, height: 76)
                        .background(overlayImageColor.opacity(0.12))
                        .clipShape(Circle())

                    VStack(spacing: 8) {
                        Text(showMessageTitle)
                            .font(.title2.bold())
                            .foregroundStyle(navy)
                        Text(showMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    HStack {
                        Label("Updated balance", systemImage: "wallet.pass.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("₹\(vm.balance ?? 0, specifier: "%.2f")")
                            .font(.subheadline.bold())
                            .foregroundStyle(navy)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button {
                        showSuccessOverlay = false
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(navy)
                }
                .padding(24)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.18), radius: 24, y: 10)
                .padding(24)
            }
            if showLoader {
                Color.black.opacity(0.25).ignoresSafeArea()
                VStack(spacing: 14) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                    Text("Processing payment...")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .padding(28)
                .background(.black.opacity(0.78))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    private func reviewTransfer() {
        guard let value = Double(amount), value > 0, value <= (vm.balance ?? 0), vm.user_id != nil else {
            showFailure("Insufficient balance or invalid amount.")
            return
        }
        showMPIN = true
    }

    private func executeTransfer() {
        guard let value = Double(amount), value > 0, let userID = vm.user_id else {
            showFailure("Unable to process this transfer.")
            return
        }
        showLoader = true
        NetworkManager.shared.userTransfer(fromUser: userID, toUser: recipient, amount: value) { success in
            DispatchQueue.main.async {
                if success {
                    vm.sendMoney(title: recipient, amount: value, status: "Success")
                    showMessage = "₹\(value, default: "%.2f") sent to \(recipient)."
                    showMessageTitle = "Payment sent"
                    overlayImage = "checkmark.circle.fill"
                    overlayImageColor = .green
                } else { showFailure("The recipient could not be found.") ; return }
                showLoader = false; showSuccessOverlay = true; amount = ""; recipient = ""
            }
        }
    }

    private func showFailure(_ message: String) {
        showMessage = message; showMessageTitle = "Payment failed"; overlayImage = "xmark.circle.fill"; overlayImageColor = .red; showLoader = false; showSuccessOverlay = true
    }
}

#Preview { NavigationStack { TransferView(vm: BankingViewModel()) } }
