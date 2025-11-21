import SwiftUI

struct CustomButton: View {
    let title: String
    var isLoading: Bool = false
    var backgroundColor: Color = .blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        CustomButton(title: "Login", action: {})

        CustomButton(title: "Loading", isLoading: true, action: {})

        CustomButton(title: "Sign Up", backgroundColor: .green, action: {})
    }
    .padding()
}
