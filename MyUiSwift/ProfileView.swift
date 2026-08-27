import SwiftUI

struct ProfileView: View {
    @ObservedObject var vm: BankingViewModel
    @State private var showLogoutAlert = false

    private let navy = Color(red: 0.08, green: 0.20, blue: 0.38)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                profileHeader

                Text("Personal information")
                    .font(.headline)
                    .foregroundStyle(navy)
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    profileRow(title: "Full Name", value: vm.name ?? "-", icon: "person.fill")
                    profileRow(title: "Phone Number", value: vm.phone_number ?? "-", icon: "phone.fill")
                    profileRow(title: "Email", value: vm.email ?? "-", icon: "envelope.fill")
                    profileRow(title: "User ID", value: vm.user_id ?? "-", icon: "person.crop.square.fill")
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                Text("Account details")
                    .font(.headline)
                    .foregroundStyle(navy)
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    profileRow(title: "Account Number", value: vm.account_number ?? "-", icon: "creditcard.fill")
                    profileRow(title: "UPI ID", value: vm.upi_id ?? "-", icon: "wallet.pass.fill")
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                Text("Device")
                    .font(.headline)
                    .foregroundStyle(navy)
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    Button {
                        showLogoutAlert = true
                    } label: {
                        profileRow(title: "Logout", value: " ", icon: "power")
                    }
                    .buttonStyle(.plain)
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Yes", role: .destructive) {
                vm.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 76))
                .foregroundStyle(.white, navy)

            Text(vm.name ?? "Your Profile")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(vm.email ?? "")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .background(
            LinearGradient(colors: [navy, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: navy.opacity(0.2), radius: 14, y: 8)
        .padding(.horizontal)
    }

    private func profileRow(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                    .frame(width: 24)

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 12)

                Text(value.isEmpty ? "-" : value)
                    .font(.body)
                    .multilineTextAlignment(.trailing)
                    .textSelection(.enabled)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)

            if title != "Email" && title != "UPI ID" {
                Divider().padding(.leading, 64)
            }
        }
    }
}

#Preview {
    ProfileView(vm: BankingViewModel())
}
