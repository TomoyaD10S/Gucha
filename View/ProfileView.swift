import SwiftUI

struct ProfileView: View {
    @StateObject var authViewModel = AuthenticationViewModel()
    @ObservedObject var firebaseManager = FirebaseManager.shared
    @State private var newname = ""
    @State private var showAlert = false
    @Environment(\.colorScheme) var colorScheme
    @State private var matchedUserName: String = ""
    @State private var matchedUserAge: Int = 20
    @State private var isNameValid: Bool = true
    @State private var title: String = ""
    @State private var errormessage: String = ""
    
    
    var body: some View {
        VStack {
            if colorScheme == .dark {
                Spacer().frame(width:40)
                Text("Name: \(matchedUserName)")
                    .padding()
                    .font(.title)
                
                Text("Age: \(matchedUserAge)")
                    .padding()
                    .font(.title)
                
                Spacer().frame(width:50)
                
                Text("Please enter new profile name if you want to change.")
                    .padding()
                    .font(.headline)
                
                TextField("New Profile Name", text: $newname)
                    .padding(12)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .padding()
                    .frame(maxWidth: 250)
                    .onChange(of: newname) { _, newName in

                        isNameValid = isValidName(newName)
                    }
                
                if isNameValid {
                    Button("Submit") {

                        print("Name: \(newname), Age: \(matchedUserAge)")
                        firebaseManager.saveUserProfile(name:newname, age:matchedUserAge){ error in
                            if let error = error {
                                title = "Error"
                                errormessage = "Failed to save user profile"
                                showAlert = true
                                print("Error saving user profile: \(error.localizedDescription)")
                                
                            } else {
                                print("User profile saved successfully!")
                                title = ""
                                errormessage = "User profile saved successfully!"
                                authViewModel.fetchUserUID()
                                if let userID = authViewModel.userUID {
                                    firebaseManager.fetchUserInfo(userID:userID) { result in
                                        switch result {
                                        case .success(let userInfo):
                                            let (name, age) = userInfo
                                            matchedUserName = name
                                            matchedUserAge = age
                                            print("Name: \(matchedUserName), Age: \(matchedUserAge)")
                                        case .failure(let error):
                                            print("Error fetching user info: \(error)")
                                        }
                                    }
                                } else {
                                    print("User UID is nil")
                                }
                                showAlert = true
                            }
                        }

                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
                    .frame(maxWidth: 250)
                    
                } else {
                    Button("Submit") {
                        // nothing to do
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()
                    .frame(maxWidth: 250)
                }
                Spacer()
            
            } else {
                Spacer().frame(width:40)
                Text("Name: \(matchedUserName)")
                    .padding()
                    .font(.title)
                
                Text("Age: \(matchedUserAge)")
                    .padding()
                    .font(.title)
                
                Spacer().frame(width:50)
                
                Text("Please enter new profile name if you want to change.")
                    .padding()
                    .font(.headline)
                
                TextField("New Profile Name", text: $newname)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding()
                    .frame(maxWidth: 250)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .onChange(of: newname) { _, newName in

                        isNameValid = isValidName(newName)
                    }
                
                if isNameValid {
                    Button("Submit") {
                        print("Name: \(newname), Age: \(matchedUserAge)")
                        firebaseManager.saveUserProfile(name:newname, age:matchedUserAge){ error in
                            if let error = error {
                                title = "Error"
                                errormessage = "Failed to save user profile"
                                showAlert = true
                                print("Error saving user profile: \(error.localizedDescription)")
                                
                            } else {
                                print("User profile saved successfully!")
                                title = ""
                                errormessage = "User profile saved successfully!"
                                authViewModel.fetchUserUID()
                                if let userID = authViewModel.userUID {
                                    firebaseManager.fetchUserInfo(userID:userID) { result in
                                        switch result {
                                        case .success(let userInfo):
                                            let (name, age) = userInfo
                                            matchedUserName = name
                                            matchedUserAge = age
                                            print("Name: \(matchedUserName), Age: \(matchedUserAge)")
                                        case .failure(let error):
                                            print("Error fetching user info: \(error)")
                                        }
                                    }
                                } else {
                                    print("User UID is nil")
                                }
                                showAlert = true
                            }
                        }

                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
                    .frame(maxWidth: 250)
                    
                } else {
                    Button("Submit") {
                        // nothing to do
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()
                    .frame(maxWidth: 250)
                }
                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(title), message: Text(errormessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            authViewModel.fetchUserUID()
            if let userID = authViewModel.userUID {
                firebaseManager.fetchUserInfo(userID:userID) { result in
                    switch result {
                    case .success(let userInfo):
                        let (name, age) = userInfo
                        matchedUserName = name
                        matchedUserAge = age
                        print("Name: \(matchedUserName), Age: \(matchedUserAge)")
                    case .failure(let error):
                        print("Error fetching user info: \(error)")
                    }
                }
            } else {
                print("User UID is nil")
            }
        }
        .navigationTitle("Profile")
    }
    
    func isValidName(_ name: String) -> Bool {

        let forbiddenStrings: Set<String> = ["Create your own set"]
        
        return name.count <= 20 && !name.isEmpty && !name.contains(" ") && !forbiddenStrings.contains { forbiddenString in
            let lowercaseForbiddenString = forbiddenString.lowercased()
            let lowercaseName = name.lowercased().replacingOccurrences(of: " ", with: "")
            return lowercaseName.contains(lowercaseForbiddenString)
        }
    }
}
