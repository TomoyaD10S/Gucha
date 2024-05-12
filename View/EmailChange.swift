import SwiftUI
import FirebaseAuth

struct EmailChange: View {
    @StateObject var authViewModel = AuthenticationViewModel()
    @State private var newEmail = ""
    @State private var isEmailSent = false
    @State private var showErrorPopup = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if colorScheme == .dark {
                Text("Please enter your registered email address below. A link to change your email will be sent to that email address.")
                    .padding()
                
                TextField("Registered Email Address", text: $newEmail)
                    .padding(12)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .padding()
                
                Button("Send Email") {
                    changeEmail()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
                
                if isEmailSent {
                    Text("Confirmation email has been sent to \(newEmail). Please check your inbox.")
                        .padding()
                }
            } else {
                Text("Please enter your registered email address below. A link to change your email will be sent to that email address.")
                    .padding()
                
                TextField("Registered Email Address", text: $newEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Send Email") {
                    changeEmail()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
                
                if isEmailSent {
                    Text("Confirmation email has been sent to \(newEmail). Please check your inbox.")
                        .padding()
                }
            }
        }
        .alert(isPresented: $showErrorPopup) {
            Alert(title: Text("Authentication Required"),
                  message: Text("This operation requires recent authentication. Please sign out and log in again."),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    private func changeEmail() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        currentUser.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
            if let error = error {
                print("Error updating email: \(error.localizedDescription)")
                showErrorPopup = true
            } else {
                print("Email update initiated successfully. Please check your inbox for a confirmation email.")
                isEmailSent = true
            }
        }
    }
}

