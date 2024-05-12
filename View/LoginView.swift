import SwiftUI
import Firebase

struct LoginView: View {
    
    @State var isLoginMode = true
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var passwordsMatch = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showResendEmailAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                if colorScheme == .dark {
                    VStack(spacing: 16) {
                        Picker(selection: $isLoginMode, label: Text("Picker here")) {
                            Text("Login")
                                .tag(true)
                            Text("Create Account")
                                .tag(false)
                        }.pickerStyle(SegmentedPickerStyle())
                        
                        Group {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            SecureField("Password", text: $password)
                                .onChange(of: password) { newValue,_ in
                                    password = newValue
                                }
                        }
                        .padding(12)
                        .background(Color.gray)
                        .cornerRadius(8)
                        
                        if !isLoginMode {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .onChange(of: confirmPassword) { newValue,_ in
                                    print("confirm password: \(confirmPassword)")
                                   
                                    passwordsMatch = (password == confirmPassword) && !newValue.isEmpty
                                }
                                .foregroundColor(passwordsMatch ? .white : .red)
                                .padding(12)
                                .background(Color.gray)
                                .cornerRadius(8)
                        }
                        
                        if !isLoginMode {
                            Button {
                                if passwordsMatch {
                                    createNewAccount()
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Create Account")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .font(.system(size: 14, weight: .semibold))
                                    Spacer()
                                }
                                .background(passwordsMatch ? Color.blue : Color.gray)
                                .cornerRadius(8)
                            }
                            .disabled(!passwordsMatch)
                        } else {
                            Button {
                                handleAction()
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Log In")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .font(.system(size: 14, weight: .semibold))
                                    Spacer()
                                }
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        }
                        
                        Text(self.loginStatusMessage)
                            .foregroundColor(.red)
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Picker(selection: $isLoginMode, label: Text("Picker here")) {
                            Text("Login")
                                .tag(true)
                            Text("Create Account")
                                .tag(false)
                        }.pickerStyle(SegmentedPickerStyle())
                        
                        Group {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            SecureField("Password", text: $password)
                                .onChange(of: password) { newValue,_ in
                                
                                    password = newValue
                                }
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(8)
                        
                        if !isLoginMode {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .onChange(of: confirmPassword) { newValue,_ in
                                    print("confirm password: \(confirmPassword)")
                                    //passwordsMatch = (password == newValue) && !newValue.isEmpty
                                    passwordsMatch = (password == confirmPassword) && !newValue.isEmpty
                                }
                                .foregroundColor(passwordsMatch ? .black : .red)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                        
                        if !isLoginMode {
                            Button {
                                if passwordsMatch {
                                    createNewAccount()
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Create Account")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .font(.system(size: 14, weight: .semibold))
                                    Spacer()
                                }
                                .background(passwordsMatch ? Color.blue : Color.gray)
                                .cornerRadius(8)
                            }
                            .disabled(!passwordsMatch)
                        } else {
                            Button {
                                handleAction()
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Log In")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .font(.system(size: 14, weight: .semibold))
                                    Spacer()
                                }
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        }
                        
                        Text(self.loginStatusMessage)
                            .foregroundColor(.red)
                    }
                    .padding()
                }
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                            .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showResendEmailAlert) {
            Alert(
                title: Text("Email Verification Required"),
                message: Text("Please verify your email address to continue."),
                primaryButton: .default(Text("Resend Verification Email")) {
                    FirebaseManager.shared.sendVerificationEmail { error in
                        if let error = error {
                            print("Failed to send verification email:", error)
                            //self.loginStatusMessage = "Failed to send verification email: \(error.localizedDescription)"
                            self.loginStatusMessage = "Failed to send verification email"
                            //self.alertMessage = "Failed to send verification email: \(error.localizedDescription)"
                            self.alertMessage = "Failed to send verification email"
                            self.showAlert = true
                        } else {
                            print("Verification email sent successfully")
                            self.loginStatusMessage = "Verification email sent successfully"
                            self.alertMessage = "Verification email sent successfully"
                            self.showAlert = true
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func handleAction() {
        if isLoginMode {

            loginUser()
        } else {
            createNewAccount()

        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login"
                return
            }
            if let user = FirebaseManager.shared.auth.currentUser {
                if user.isEmailVerified {
                    print("User is authenticated and email is verified")
                    print("Successfully logged in as user: \(result?.user.uid ?? "")")
                    self.loginStatusMessage = "Successfully logged in as user"
                    FirebaseManager.shared.isLoggedIn = true
                } else {
                    print("User is authenticated but email is not verified")
                    showResendEmailAlert.toggle()
                }
            }
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                //self.loginStatusMessage = "Failed to create user: \(err)"
                self.loginStatusMessage = "Failed to create account"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully created account"
            
            FirebaseManager.shared.sendVerificationEmail { error in
                if let error = error {
                    print("Failed to send verification email:", error)
                    
                    self.loginStatusMessage = "Failed to send verification email"
                    
                    self.alertMessage = "Failed to send verification email"
                    self.showAlert = true
                } else {
                    print("Verification email sent successfully")
                    self.loginStatusMessage = "Verification email sent successfully"
                    self.alertMessage = "Verification email sent successfully"
                    self.showAlert = true
                }
            }
        }
    }
}
