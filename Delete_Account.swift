import SwiftUI
import FirebaseAuth

struct Delete_Account: View {
    @StateObject var authViewModel = AuthenticationViewModel()
    @State private var showingConfirmation = false
    @State private var showAlert = false
    @State private var deletionError: Error?
    @Environment(\.presentationMode) var presentationMode
    @StateObject var storeVM = StoreVM()

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                if !storeVM.purchasedSubscriptions.isEmpty {
                    Text("If you have an active subscription, please cancel it before deleting your account.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                }
                Button(action: {
                    showingConfirmation.toggle()
                }) {
                    Text("Delete Account")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .navigationBarTitle("Delete Account", displayMode: .inline)
            .padding()
            .alert(isPresented: $showAlert) {
                if let error = deletionError {
                    return Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
                } else {
                    return Alert(title: Text("Success"), message: Text("Account deleted successfully."), dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
            .sheet(isPresented: $showingConfirmation) {
                ConfirmationView(confirmAction: {
                    authViewModel.deleteAccount { success, error in
                        if success {
                            showAlert = true
                        } else {
                            deletionError = error
                            showAlert = true
                        }
                    }
                }, cancelAction: {
                    showingConfirmation.toggle()
                })
            }
        }
    }
}

struct ConfirmationView: View {
    var confirmAction: () -> Void
    var cancelAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Are you sure you want to delete your account?")
                .font(.title2)
                .padding()

            HStack {
                Button("Yes") {
                    confirmAction()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                
                Button("No") {
                    cancelAction()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)
        }
        .cornerRadius(20)
        .padding()
    }
}
