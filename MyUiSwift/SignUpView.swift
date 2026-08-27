import SwiftUI

struct SignUpView: View {
    @ObservedObject var vm: BankingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var dateOfBirth = Date()
    @State private var dateOfBirthText = ""
    @State private var showingDatePicker = false
    @State private var showSuccessOverlay = false
    @State private var successMessage = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showAllFieldsRequiredToast = false
    @State private var showLoader = false

    private let navy = Color(red: 0.08, green: 0.20, blue: 0.38)

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.99)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(navy)
                            .clipShape(RoundedRectangle(cornerRadius: 15))

                        Text("Create your account")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(navy)
                            .padding(.top, 8)
                        Text("Join Fraud Bank and take control of your finances.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        formField(title: "Full Name", icon: "person.fill", placeholder: "Enter your full name", text: $fullName)
                        formField(title: "Email Address", icon: "envelope.fill", placeholder: "yourmail@example.com", text: $email, keyboard: .emailAddress)
                        formField(title: "Phone Number", icon: "phone.fill", placeholder: "Enter your phone number", text: $phoneNumber, keyboard: .phonePad)

                        Text("Date of Birth")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(navy)
                        Button {
                            showingDatePicker = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                Text(dateOfBirthText.isEmpty ? "Select your date of birth" : dateOfBirthText)
                                    .foregroundStyle(dateOfBirthText.isEmpty ? .secondary : .primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 54)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                        }
                        .buttonStyle(.plain)

                        Text("Create Password")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(navy)
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            Group {
                                if isPasswordVisible {
                                    TextField("At least 8 characters", text: $password)
                                } else {
                                    SecureField("At least 8 characters", text: $password)
                                }
                            }
                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 13))

                        Button(action: createAccount) {
                            Label("Create Account", systemImage: "arrow.right.circle.fill")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(SignUpButtonStyle(color: navy))
                        .disabled(showLoader)
                    }
                }
                .padding(24)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.08), radius: 24, y: 10)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if showingDatePicker {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    VStack(spacing: 16) {
                        Text("Select Date of Birth")
                            .font(.headline)
                        DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                        Button("Done") {
                            dateOfBirthText = dateOfBirth.formatted(date: .abbreviated, time: .omitted)
                            showingDatePicker = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .padding(24)
                    .zIndex(1)
                }
            }
        }
        .overlay(statusOverlay)
    }

    private func formField(title: String, icon: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(navy)
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(keyboard == .emailAddress ? .never : .sentences)
                    .autocorrectionDisabled(keyboard == .emailAddress)
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 13))
        }
    }

    private var statusOverlay: some View {
        ZStack {
            if showSuccessOverlay {
                Color.black.opacity(0.3).ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 58))
                        .foregroundStyle(.green)
                    Text("Account Created")
                        .font(.title2.bold())
                    Text(successMessage)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Button("Continue") { dismiss() }
                        .buttonStyle(.borderedProminent)
                }
                .padding(28)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .padding(28)
            }
            if showAllFieldsRequiredToast {
                VStack {
                    Spacer()
                    Text("Please complete all fields")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 13)
                        .background(.black.opacity(0.82))
                        .clipShape(Capsule())
                        .padding(.bottom, 24)
                }
            }
            if showLoader {
                Color.black.opacity(0.25).ignoresSafeArea()
                ProgressView("Creating account...")
                    .tint(.white)
                    .foregroundStyle(.white)
                    .padding(28)
                    .background(.black.opacity(0.78))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    private func createAccount() {
        guard !fullName.isEmpty, !email.isEmpty, !phoneNumber.isEmpty, !password.isEmpty, !dateOfBirthText.isEmpty else {
            showAllFieldsRequiredToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showAllFieldsRequiredToast = false }
            return
        }

        NetworkManager.shared.initilizedFramework()
        showLoader = true
        NetworkManager.shared.getUserAccountNo { accountNumber in
            guard let accountNumber else { showLoader = false; return }
            NetworkManager.shared.getUserIdNo { userId in
                guard let userId else { showLoader = false; return }
                let upiId = fullName
                        .replacingOccurrences(of: " ", with: "")
                        .lowercased() + "@upi"
                NetworkManager.shared.createUserAccount(user_id: userId, fullname: fullName, email: email, acc_no: accountNumber, upi_id: upiId, phone: phoneNumber, passwd: password)
                DispatchQueue.main.async {
                    successMessage = "Welcome, \(fullName)! Your customer ID is \(userId)."
                    showLoader = false
                    showSuccessOverlay = true
                }
            }
        }
    }
}

private struct SignUpButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(color.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 13))
    }
}

#Preview {
    NavigationStack { SignUpView(vm: BankingViewModel()) }
}
