import SwiftUI

struct LoginView: View {
    @ObservedObject var vm: BankingViewModel
    @State private var username = "FBCI00001"
    @State private var password = "password"
    @State private var isPasswordVisible = false
    @State private var showInvalidCredentialsToast = false
    @State private var showLoader = false

    private let navy = Color(red: 0.08, green: 0.20, blue: 0.38)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.99)
                    .ignoresSafeArea()

//                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        HStack(spacing: 12) {
                            Image(systemName: "building.columns.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(navy)
                                .clipShape(RoundedRectangle(cornerRadius: 14))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("FRAUD BANK")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .tracking(1.2)
                                    .foregroundStyle(navy)
                                Text("Simple. Secure. Yours.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Welcome back")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundStyle(navy)
                                Text("Sign in to manage your money securely.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Customer ID")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(navy)
                                inputField(icon: "person.fill", placeholder: "Enter your customer ID", text: $username)

                                Text("Password")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(navy)
                                    .padding(.top, 6)
                                passwordField
                            }

                            Label("Your connection is encrypted and secure", systemImage: "lock.shield.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .symbolRenderingMode(.hierarchical)
                                .tint(.green)

                            Button(action: login) {
                                Label("Sign In", systemImage: "arrow.right.circle.fill")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .buttonStyle(PrimaryButtonStyle(color: navy))
                            .disabled(showLoader || username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty)

                            HStack(spacing: 4) {
                                Text("New to Fraud Bank?")
                                    .foregroundStyle(.secondary)
                                NavigationLink(destination: SignUpView(vm: vm)) {
                                    Text("Create an account")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.blue)
                                }
                            }
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(24)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.08), radius: 24, y: 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 28)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
            .overlay(statusOverlay)
//        }
    }

    private var passwordField: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)
                .frame(width: 20)

            if isPasswordVisible {
                TextField("Enter your password", text: $password)
                    .textContentType(.password)
            } else {
                SecureField("Enter your password", text: $password)
                    .textContentType(.password)
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
    }

    private func inputField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.username)
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    private var statusOverlay: some View {
        ZStack {
            if showInvalidCredentialsToast {
                VStack {
                    Spacer()
                    Label("Invalid customer ID or password", systemImage: "exclamationmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 13)
                        .background(.black.opacity(0.82))
                        .clipShape(Capsule())
                        .padding(.bottom, 24)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if showLoader {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                ProgressView("Signing in...")
                    .tint(.white)
                    .foregroundStyle(.white)
                    .padding(28)
                    .background(.black.opacity(0.78))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showInvalidCredentialsToast)
    }

    private func login() {
        NetworkManager.shared.initilizedFramework()
        showLoader = true

        vm.login(username: username.trimmingCharacters(in: .whitespacesAndNewlines), password: password) { _ in
            if vm.isLoggedIn {
                showLoader = false
            } else {
                showLoader = false
                showInvalidCredentialsToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showInvalidCredentialsToast = false
                }
            }
        }
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(color.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 13))
    }
}

#Preview {
    LoginView(vm: BankingViewModel())
}
