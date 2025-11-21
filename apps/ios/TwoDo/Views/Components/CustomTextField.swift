import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    VStack(spacing: 16) {
        CustomTextField(
            placeholder: "Email",
            text: .constant(""),
            icon: "envelope"
        )

        CustomTextField(
            placeholder: "Password",
            text: .constant(""),
            icon: "lock",
            isSecure: true
        )
    }
    .padding()
}
