import SwiftUI

class UserData: ObservableObject {
    static let shared = UserData()
    @Published var isAgreed: Bool {
        didSet {
            UserDefaults.standard.set(isAgreed, forKey: "isAgreed")
        }
    }
    
    init() {
        self.isAgreed = UserDefaults.standard.bool(forKey: "isAgreed")
    }
    
}


struct AgreeView: View {
    @ObservedObject var firebaseManager = FirebaseManager.shared
    @ObservedObject var userData: UserData
    @Binding var isAgreedView: Bool
    @State private var checked: Bool = false
    @State private var showAccountView = false
    @State private var showAlert = false
    
    @State private var name: String = ""
    @State private var selectedAge: Int = 20
    @State private var isNameValid: Bool = false
    @State private var shouldShowLogOutOptions = false
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    Text("Create Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack{
                        Text("User Name")
                            .fontWeight(.bold)
                        Spacer()
                        TextField("Enter user name", text: $name)
                            .padding()
                            .fontWeight(.bold)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: name) { _, newName in
                                isNameValid = isValidName(newName)
                            }
                    }
                    .padding()
                    
                    
                    HStack {
                        Text("Age")
                            .fontWeight(.bold)
                        Color.clear.frame(width: 60)
                        Picker("Age", selection: $selectedAge) {
                            ForEach(17 ..< 110, id: \.self) { age in
                                Text("\(age)")
                                    .fontWeight(.bold)
                            }
                        }
                        .multilineTextAlignment(.trailing)
                        Spacer()
                    }
                    .padding()
                    
                    DisclosureGroup {
                        ScrollView {
                            EULA()
                        }
                        .frame(width: 350, height: 300)
                        .overlay(RoundedRectangle(cornerRadius:0).stroke(lineWidth: 1))
                    } label: {
                        Text("Details of the EULA")
                            .bold()
                            .padding()
                    }
                    
                    Toggle("Agree to Terms", isOn: $checked)
                        .fontWeight(.bold)
                        .padding()
                    
                    if isNameValid && checked {
                        Button("Submit") {
                            print("Name: \(name), Age: \(selectedAge)")
                            firebaseManager.saveUserProfile(name:name, age:selectedAge){ error in
                                if let error = error {
                                    showAlert = true
                                    print("Error saving user profile: \(error.localizedDescription)")
                                    
                                } else {
                                    print("User profile saved successfully!")
                                    userData.isAgreed = true
                                    isAgreedView = false
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 120)
                        .background(Color.blue)
                        .cornerRadius(10)
                        
                    } else {
                        Button("Submit") {
                            //nothing to do
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 120)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .disabled(true)
                    }
                    
                    Spacer()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text("Failed to save user profile"), dismissButton: .default(Text("OK")))
                }
                
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showAccountView.toggle()
                        }) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(0.0)
                        }
                    }
                }
                .navigationDestination(isPresented: $showAccountView) {
                    AccountcloneView()
                }
                .actionSheet(isPresented: $shouldShowLogOutOptions) {
                    ActionSheet(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                        .destructive(Text("Sign Out"), action: {
                            print("handle sign out")
                            vm.handleSignOut()
                        }),
                        .cancel()
                    ])
                }
                .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
                    LoginView()
                }
                .navigationBarItems(leading: Button(action: {
                    shouldShowLogOutOptions.toggle()
                }) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(.blue))
                })
            }
        }
    }
    
    func isValidName(_ name: String) -> Bool {
        guard !name.isEmpty else {
                return false
            }
        let forbiddenStrings: Set<String> = ["Create your own set"]
        
        return name.count <= 20 && !name.contains(" ") && !forbiddenStrings.contains { forbiddenString in
            let lowercaseForbiddenString = forbiddenString.lowercased()
            let lowercaseName = name.lowercased().replacingOccurrences(of: " ", with: "")
            return lowercaseName.contains(lowercaseForbiddenString)
        }
    }
    
    func EULA() -> some View {
        VStack{
            VStack(alignment: .leading, spacing: 15){
                Text("End-User License Agreement")
                    .font(.system(size: 25, weight: .bold))
                Spacer().frame(height: 10)
                
                Text("Create your own EULA")
                Spacer().frame(height: 20)
            }
            .padding()
        }
    }
}

