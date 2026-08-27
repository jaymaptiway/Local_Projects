import SwiftUI

struct MPINView: View {
    let recipient: String
    let amount: Double
    let onVerified: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var mpin = ""
    @State private var showError = false
    @State private var isProcessing = false

    private let navy = Color(red: 0.08, green: 0.20, blue: 0.38)

    init(recipient: String = "", amount: Double = 0, onVerified: @escaping () -> Void = {}) {
        self.recipient = recipient
        self.amount = amount
        self.onVerified = onVerified
        print("MPINView initialized with recipient: \(recipient), amount: \(amount)")
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 14) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(navy)
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Confirm payment")
                                .font(.title2.bold())
                                .foregroundStyle(navy)
                            Text("Authorize this transfer securely.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    VStack(spacing: 18) {
                        VStack(spacing: 5) {
                            Text("Amount to send")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("₹\(amount, specifier: "%.2f")")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(navy)
                        }

                        HStack {
                            Label("Recipient", systemImage: "person.fill")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(recipient)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(navy)
                                .lineLimit(1)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                    }
                    .padding(20)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Enter your 5-digit MPIN")
                            .font(.headline)
                            .foregroundStyle(navy)

                        HStack(spacing: 14) {
                            ForEach(0..<5, id: \.self) { index in
                                Circle()
                                    .fill(index < mpin.count ? navy : Color(.systemGray4))
                                    .frame(width: 16, height: 16)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)

                        SecureField("MPIN", text: $mpin)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .multilineTextAlignment(.center)
                            .font(.title2.weight(.semibold))
                            .frame(height: 56)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                            .onChange(of: mpin) { _, newValue in
                                mpin = String(newValue.filter(\.isNumber).prefix(5))
                                showError = false
                            }

                        Text("For now, use 11111 to authorize the payment.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if showError {
                            Label("Incorrect MPIN. Please try again.", systemImage: "exclamationmark.circle.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(20)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Button(action: verifyMPIN) {
                        Group {
                            if isProcessing {
                                ProgressView().tint(.white)
                            } else {
                                Label("Authorize payment", systemImage: "checkmark.shield.fill")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(navy)
                    .disabled(isProcessing || mpin.count != 5)

                    Button("Cancel") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
                }
                .padding(20)
            }
        }
        .navigationTitle("Security Check")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func verifyMPIN() {
        guard mpin == "12345" else {
            showError = true
            return
        }

        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onVerified()
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        MPINView(recipient: "FBCI00002", amount: 1250)
    }
}
