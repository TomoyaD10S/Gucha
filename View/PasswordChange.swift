import SwiftUI
import FirebaseAuth

struct PasswordChange: View {
    @State private var email = ""
    @State private var isResetSent = false
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            if colorScheme == .dark {
                Text("Please enter your registered email address below. A link to reset your password will be sent to that email address.")
                    .padding()
                
                TextField("Registered Email Address", text: $email)
                    .padding(12)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .padding()
                
                Button("Send Email") {
                    resetPassword()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
                
                if isResetSent {
                    Text("Password reset instructions sent to \(email). Please check your email.")
                        .foregroundColor(.green)
                        .padding()
                }
            } else {
                Text("Please enter your registered email address below. A link to reset your password will be sent to that email address.")
                    .padding()
                
                TextField("Registered Email Address", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Send Email") {
                    resetPassword()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
                
                if isResetSent {
                    Text("Password reset instructions sent to \(email). Please check your email.")
                        .foregroundColor(.green)
                        .padding()
                }
            }
        }
        .alert(isPresented: $showErrorPopup) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Email address cannot be empty."
            showErrorPopup = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print(error.localizedDescription)
                errorMessage = error.localizedDescription
                showErrorPopup = true
            } else {
                isResetSent = true
                errorMessage = ""
            }
        }
    }
}
