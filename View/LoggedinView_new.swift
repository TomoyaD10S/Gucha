import SwiftUI
import Firebase
import StoreKit

enum AlertType2: Identifiable {
    case showError
    case confirmAlert
    
    var id: Int {
        // Use a unique identifier for each case
        switch self {
        case .showError:
            return 0
        case .confirmAlert:
            return 1
        }
    }
}

class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? Auth.auth().signOut()
    }
}

class AuthenticationViewModel: ObservableObject {
    @Published var userUID: String?

    func fetchUserUID() {
        if let currentUser = Auth.auth().currentUser {
            userUID = currentUser.uid
        } else {
            userUID = nil
        }
    }
    
    func deleteAccount(completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                completion(false, error)
            } else {
                self.userUID = nil
                completion(true, nil)
            }
        }
    }
}

private func getValueFromJSON(responseBody: String) -> [String: String] {
    guard responseBody != "{\"statusCode\": 200, \"body\": \"\\\"\\\"\"}" else {
        return [:]
    }
    
    guard let data = responseBody.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let bodyDict = json["body"] as? [String: String] else {
        return [:]
    }
    
    var trimmedDict: [String: String] = [:]
    for (key, value) in bodyDict {
        trimmedDict[key] = value.replacingOccurrences(of: #"\""#, with: "", options: .regularExpression)
    }
    
    return trimmedDict
}

private func getValueFromJSON2(responseBody: String) -> String {
    guard let data = responseBody.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let bodyString = json["body"] as? String else {
        return ""
    }
    
    let trimmedString = bodyString.replacingOccurrences(of: #"\""#, with: "", options: .regularExpression)
    return trimmedString
}


struct LoggedinView_new: View {
    @State private var showChatLogView = false
    @State private var showAccountView = false
    @State private var selectedLanguage = "English"
    @State private var shouldShowLogOutOptions = false
    @State private var matchedUserID = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @ObservedObject private var authViewModel = AuthenticationViewModel()
    @ObservedObject private var vm = MainMessagesViewModel()
    @State private var isSearching = false
    @State private var chatUser = ""
    @ObservedObject private var tokenManager = TokenManager.shared
    @State private var showTokenRecovery = false
    @ObservedObject var adMobRewardView = AdMobRewardView()
    @StateObject var storeVM = StoreVM()
    @Environment(\.colorScheme) var colorScheme
    @State private var alertType: AlertType2?
    @State private var matchedUserName: String = ""
    @State private var matchedUserAge: Int = 20
    @ObservedObject var firebaseManager = FirebaseManager.shared
    @State private var PassMe: String = ""
    @State private var PassMatch: String = ""
    @StateObject var blockedUserManager = BlockedUserManager.shared

    
    var body: some View {
        NavigationStack {
            VStack{
                if storeVM.purchasedSubscriptions.isEmpty {

                    AdMobBannerView()
                        .padding(.top)
                    
                    Spacer().frame(height:35)
                    
                    if UIScreen.main.nativeBounds.height > 1334 {
                        Text("Welcome to Gucha")
                            .font(Font.custom("Verdana-Bold", size: 30))
                            .kerning(-1.0)
                            .fontWeight(.bold)
                        
                        Picker("Select Language", selection: $selectedLanguage) {
                            Text("English") .font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("English")
                            Text("Spanish").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("Spanish")
                            Text("French").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("French")
                            Text("German").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("German")
                            Text("Japanese").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("Japanese")
                            Text("Korean").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("Korean")
                            Text("Chinese").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("Chinese")
                        }
                        .background(Color.black.opacity(0))
                        .frame(width: 300, height: 160)
                        .pickerStyle(WheelPickerStyle())
                        
                        Button(action: {
                            isSearching = true
                            
                            if tokenManager.tokens == 0 {
                                errorMessage = "You don't have enough tokens. Watch ads to earn tokens."
                                self.alertType = .showError
                                isSearching = false
                            } else {
                                APIManager.postDataToDynamoDB(authViewModel: authViewModel, selectedLanguage: selectedLanguage) { result in
                                    switch result {
                                    case .success(let responseString):
                                        if let responseString = responseString {
                                            let trimmedValues = getValueFromJSON(responseBody: responseString)

                                            if !trimmedValues.isEmpty {
                                                if let id = trimmedValues["ID"] {
                                                    self.chatUser = id
                                                }
                                                if let passme = trimmedValues["PassMe"] {
                                                    self.PassMe = passme
                                                }
                                                if let passmatch = trimmedValues["PassMatch"] {
                                                    self.PassMatch = passmatch
                                                }
                                                print(self.chatUser,self.PassMe,self.PassMatch)
                                                isSearching = false
                                                if blockedUserManager.blockedUsers.contains(where: { $0.userID == self.chatUser}) {
                                                    print("\(self.chatUser) is blocked")
                                                    errorMessage = "The matched user is blocked"
                                                    self.alertType = .showError
                                                    
                                                } else {
                                                    firebaseManager.fetchUserInfo(userID:self.chatUser) { result in
                                                        switch result {
                                                        case .success(let userInfo):
                                                            let (name, age) = userInfo
                                                            matchedUserName = name
                                                            matchedUserAge = age
                                                            print("Name: \(matchedUserName), Age: \(matchedUserAge)")
                                                            self.alertType = .confirmAlert
        
                                                        case .failure(let error):
                                                            print("Error fetching user info: \(error)")
                                                        }
                                                    }
                                                }
                                            } else {
                                                errorMessage = "User not found. Try again!"
                                                self.alertType = .showError
                                                isSearching = false
                                                
                                            }
                                        } else {
                                            errorMessage = "User not found. Try again!"
                                            self.alertType = .showError
                                            isSearching = false
                                        }
                                    case .failure(let error):
                                        print("Error: \(error.localizedDescription)")
                                        errorMessage = "Error: \(error.localizedDescription)"
                                        self.alertType = .showError
                                        isSearching = false
                                    }
                                }
                            }
                        }) {
                            if isSearching {
                                ProgressView()
                            } else {
                                Text("Start Conversation")
                                    .font(.title2)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .fontWeight(.bold)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Spacer()
                        
                        if tokenManager.tokens < 5 {
                            Text("Tokens will recover in:\n\(tokenManager.formattedTimeRemaining)")
                                .font(.title2)
                                .padding()
                                .multilineTextAlignment(.center)
                        }
                        
                        HStack(spacing: 10) {
                            ForEach(0..<min(5, tokenManager.tokens), id: \.self) {_ in
                                Image("icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(.blue)
                                    .cornerRadius(5)
                            }
                            ForEach(0..<max(0, 5 - tokenManager.tokens), id: \.self) {_ in
                                Image("Picture5")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(.blue)
                                    .cornerRadius(5)
                            }
                        }
                        .padding()
                        
                        Button(action: {
                            adMobRewardView.showReward()
                            
                        }) {
                            Text("Watch Ad for Tokens")
                                .font(.title2)
                                .padding()
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                                .cornerRadius(10)
                        }
                    } else {
                        Text("Welcome to Gucha")
                            .font(Font.custom("Verdana-Bold", size: 25))
                            .kerning(-1.0)
                            .fontWeight(.bold)
                        
                        Picker("Select Language", selection: $selectedLanguage) {
                            Text("English") .font(Font.custom("ChalkboardSE-Regular", size: 20)).tag("English")
                            Text("Spanish").font(Font.custom("ChalkboardSE-Regular", size: 20)).tag("Spanish")
                            Text("French").font(Font.custom("ChalkboardSE-Regular", size: 20)).tag("French")
                            Text("German").font(Font.custom("ChalkboardSE-Regular", size: 20)).tag("German")
                            Text("Japanese").font(Font.custom("ChalkboardSE-Regular", size: 20)).tag("Japanese")
                            Text("Korean").font(Font.custom("ChalkboardSE-Regular", size: 20)).tag("Korean")
                            Text("Chinese").font(Font.custom("ChalkboardSE-Regular", size: 20)).tag("Chinese")
                        }
                        .background(Color.black.opacity(0))
                        .frame(width: 300, height: 120)
                        .pickerStyle(WheelPickerStyle())
                        
                        Button(action: {
                            isSearching = true
                            
                            if tokenManager.tokens == 0 {
                                errorMessage = "You don't have enough tokens. Watch ads to earn tokens."
                                self.alertType = .showError
                                isSearching = false
                            } else {
                                APIManager.postDataToDynamoDB(authViewModel: authViewModel, selectedLanguage: selectedLanguage) { result in
                                    switch result {
                                    case .success(let responseString):
                                        if let responseString = responseString {
                                            let trimmedValues = getValueFromJSON(responseBody: responseString)

                                            if !trimmedValues.isEmpty {
                                                if let id = trimmedValues["ID"] {
                                                    self.chatUser = id
                                                }
                                                if let passme = trimmedValues["PassMe"] {
                                                    self.PassMe = passme
                                                }
                                                if let passmatch = trimmedValues["PassMatch"] {
                                                    self.PassMatch = passmatch
                                                }
                                                print(self.chatUser,self.PassMe,self.PassMatch)
                                                isSearching = false
                                                if blockedUserManager.blockedUsers.contains(where: { $0.userID == self.chatUser}) {
                                                    print("\(self.chatUser) is blocked")
                                                    errorMessage = "The matched user is blocked"
                                                    self.alertType = .showError
                                                    
                                                } else {
                                                    firebaseManager.fetchUserInfo(userID:self.chatUser) { result in
                                                        switch result {
                                                        case .success(let userInfo):
                                                            let (name, age) = userInfo
                                                            matchedUserName = name
                                                            matchedUserAge = age
                                                            print("Name: \(matchedUserName), Age: \(matchedUserAge)")
                                                            self.alertType = .confirmAlert
        
                                                        case .failure(let error):
                                                            print("Error fetching user info: \(error)")
                                                        }
                                                    }
                                                }
                                            } else {
                                                errorMessage = "User not found. Try again!"
                                                self.alertType = .showError
                                                isSearching = false
                                                
                                            }
                                        } else {
                                            errorMessage = "User not found. Try again!"
                                            self.alertType = .showError
                                            isSearching = false
                                        }
                                    case .failure(let error):
                                        print("Error: \(error.localizedDescription)")
                                        errorMessage = "Error: \(error.localizedDescription)"
                                        self.alertType = .showError
                                        isSearching = false
                                    }
                                }
                            }
                        }) {
                            if isSearching {
                                ProgressView()
                            } else {
                                Text("Start Conversation")
                                    .font(.headline)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .frame(width: 230, height: 30)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                        
                        if tokenManager.tokens < 5 {
                            Text("Tokens will recover in:\n\(tokenManager.formattedTimeRemaining)")
                                .font(.headline)
                                .padding()
                                .multilineTextAlignment(.center)
                        }
                        
                        HStack(spacing: 10) {
                            ForEach(0..<min(5, tokenManager.tokens), id: \.self) {_ in
                                Image("icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 38, height: 38)
                                    .foregroundColor(.blue)
                                    .cornerRadius(5)
                            }
                            ForEach(0..<max(0, 5 - tokenManager.tokens), id: \.self) {_ in
                                Image("Picture5")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 38, height: 38)
                                    .foregroundColor(.blue)
                                    .cornerRadius(5)
                            }
                        }
                        .padding()
                        
                        Button(action: {
                            adMobRewardView.showReward()
                            
                        }) {
                            Text("Watch Ad for Tokens")
                                .font(.headline)
                                .padding()
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                                .cornerRadius(10)
                                .frame(width: 230, height: 30)
                        }
                    }
                } else {
                    if UIScreen.main.nativeBounds.height > 1334 {
                        HStack{
                            Image("Picture6")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                            Image("Picture5")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .cornerRadius(5)
                        }
                        Spacer()
                        
                        Text("Welcome to Gucha")
                            .font(Font.custom("Verdana-Bold", size: 30))
                            .kerning(-1.0)
                            .fontWeight(.bold)
                        
                        Picker("Select Language", selection: $selectedLanguage) {
                            Text("English") .font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("English")
                            Text("Spanish").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("Spanish")
                            Text("French").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("French")
                            Text("German").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("German")
                            Text("Japanese").font(Font.custom("ChalkboardSE-Regular", size: 22.5)).tag("Japanese")
                            Text("Korean").font(Font.custom("ChalkboardSE-Regular", size: 22.5)).tag("Korean")
                            Text("Chinese").font(Font.custom("ChalkboardSE-Regular", size: 22.5)).tag("Chinese")
                        }
                        .background(Color.black.opacity(0))
                        .frame(width: 300, height: 200)
                        .pickerStyle(WheelPickerStyle())
                        
                        Button(action: {
                            isSearching = true
                            APIManager.postDataToDynamoDB(authViewModel: authViewModel, selectedLanguage: selectedLanguage) { result in
                                switch result {
                                case .success(let responseString):
                                    if let responseString = responseString {
                                        let trimmedValues = getValueFromJSON(responseBody: responseString)

                                        if !trimmedValues.isEmpty {
                                            if let id = trimmedValues["ID"] {
                                                self.chatUser = id
                                            }
                                            if let passme = trimmedValues["PassMe"] {
                                                self.PassMe = passme
                                            }
                                            if let passmatch = trimmedValues["PassMatch"] {
                                                self.PassMatch = passmatch
                                            }
                                            print(self.chatUser,self.PassMe,self.PassMatch)
                                            isSearching = false
                                            if blockedUserManager.blockedUsers.contains(where: { $0.userID == self.chatUser}) {
                                                print("\(self.chatUser) is blocked")
                                                errorMessage = "The matched user is blocked"
                                                self.alertType = .showError
                                                
                                            } else {
                                                firebaseManager.fetchUserInfo(userID:self.chatUser) { result in
                                                    switch result {
                                                    case .success(let userInfo):
                                                        let (name, age) = userInfo
                                                        matchedUserName = name
                                                        matchedUserAge = age
                                                        print("Name: \(matchedUserName), Age: \(matchedUserAge)")
                                                        self.alertType = .confirmAlert

                                                    case .failure(let error):
                                                        print("Error fetching user info: \(error)")
                                                    }
                                                }
                                            }
                                        } else {
                                            errorMessage = "User not found. Try again!"
                                            self.alertType = .showError
                                            isSearching = false
                                            
                                        }
                                    } else {
                                        errorMessage = "User not found. Try again!"
                                        self.alertType = .showError
                                        isSearching = false
                                    }
                                case .failure(let error):
                                    errorMessage = "Error: \(error.localizedDescription)"
                                    self.alertType = .showError
                                    isSearching = false
                                }
                            }
                        }) {
                            if isSearching {
                                ProgressView()
                            } else {
                                Text("Start Conversation")
                                    .font(.title2)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .fontWeight(.bold)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Spacer()
                        
                        HStack{
                            Image("Picture5")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .cornerRadius(5)
                            Image("Picture7")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                        }
                    } else {
                        HStack{
                            Image("Picture6")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                            Image("Picture5")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .cornerRadius(5)
                        }
                        Spacer()
                        
                        Text("Welcome to Gucha")
                            .font(Font.custom("Verdana-Bold", size: 30))
                            .kerning(-1.0)
                            .fontWeight(.bold)
                        
                        Picker("Select Language", selection: $selectedLanguage) {
                            Text("English") .font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("English")
                            Text("Spanish").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("Spanish")
                            Text("French").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("French")
                            Text("German").font(Font.custom("ChalkboardSE-Regular", size: 22)).tag("German")
                            Text("Japanese").font(Font.custom("ChalkboardSE-Regular", size: 22.5)).tag("Japanese")
                            Text("Korean").font(Font.custom("ChalkboardSE-Regular", size: 22.5)).tag("Korean")
                            Text("Chinese").font(Font.custom("ChalkboardSE-Regular", size: 22.5)).tag("Chinese")
                        }
                        .background(Color.black.opacity(0))
                        .frame(width: 300, height: 200)
                        .pickerStyle(WheelPickerStyle())
                        
                        Button(action: {
                            isSearching = true
                            APIManager.postDataToDynamoDB(authViewModel: authViewModel, selectedLanguage: selectedLanguage) { result in
                                switch result {
                                case .success(let responseString):
                                    if let responseString = responseString {
                                        let trimmedValues = getValueFromJSON(responseBody: responseString)
                                        if !trimmedValues.isEmpty {
                                            if let id = trimmedValues["ID"] {
                                                self.chatUser = id
                                            }
                                            if let passme = trimmedValues["PassMe"] {
                                                self.PassMe = passme
                                            }
                                            if let passmatch = trimmedValues["PassMatch"] {
                                                self.PassMatch = passmatch
                                            }
                                            print(self.chatUser,self.PassMe,self.PassMatch)
                                            isSearching = false
                                            if blockedUserManager.blockedUsers.contains(where: { $0.userID == self.chatUser}) {
                                                print("\(self.chatUser) is blocked")
                                                errorMessage = "The matched user is blocked"
                                                self.alertType = .showError
                                                
                                            } else {
                                                firebaseManager.fetchUserInfo(userID:self.chatUser) { result in
                                                    switch result {
                                                    case .success(let userInfo):
                                                        let (name, age) = userInfo
                                                        matchedUserName = name
                                                        matchedUserAge = age
                                                        print("Name: \(matchedUserName), Age: \(matchedUserAge)")
                                                        self.alertType = .confirmAlert
                   
                                                    case .failure(let error):
                                                        print("Error fetching user info: \(error)")
                                                    }
                                                }
                                            }
                                        } else {
                                            errorMessage = "User not found. Try again!"
                                            self.alertType = .showError
                                            isSearching = false
                                            
                                        }
                                    } else {
                                        errorMessage = "User not found. Try again!"
                                        self.alertType = .showError
                                        isSearching = false
                                    }
                                case .failure(let error):
                                    errorMessage = "Error: \(error.localizedDescription)"
                                    self.alertType = .showError
                                    isSearching = false
                                }
                            }
                        }) {
                            if isSearching {
                                ProgressView()
                            } else {
                                Text("Start Conversation")
                                    .font(.title2)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .fontWeight(.bold)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Spacer()
                        
                        HStack{
                            Image("Picture5")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .cornerRadius(5)
                            Image("Picture7")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showChatLogView) {
                NavigationStack {
                    ChatLogView(chatUser: self.chatUser, matchUserID: self.$chatUser, matchUser: $matchedUserName, matchUserAge: $matchedUserAge)
                        .navigationBarTitle("Chat")
                        .navigationBarItems(trailing: Button("Close") {
                            FirebaseManager.sendExitMessage(to: chatUser) { error in
                                if let error = error {
                                    print("Error: \(error.localizedDescription)")
                                } else {
                                    tokenManager.useToken()
                                    
                                    print("Exit message sent successfully")
                                }
                            }
                            showChatLogView = false
                        })
                }
            }

            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAccountView.toggle()
                    }) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                            .padding(0.0)
                    }
                }
            }
            .navigationDestination(isPresented: $showAccountView) {
                AccountView()
            }

            .padding()
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
            .alert(item: $alertType) { alertType in
                switch alertType {
                case .showError:
                    return Alert(
                        title: Text(""),
                        message: Text(errorMessage).bold(),
                        dismissButton: .default(Text("OK")){
                            self.alertType = nil
                        }
                    )
                case .confirmAlert:
                    return Alert(
                        title: Text("You matched!"),
                        message: Text("----------------------------\nName: \(matchedUserName)\nAge: \(matchedUserAge)\n----------------------------\nWould you like to proceed to the chat room?"),
                        primaryButton: .default(Text("Yes")) {
                            self.alertType = nil
                            isSearching = true
                            APIManager_ConfirmPass.postDataToDynamoDB(authViewModel: authViewModel, passme: self.PassMe, passmatch: self.PassMatch) { result in
                                switch result {
                                case .success(let responseString):
                                    if let passcheck = responseString?.trimmingCharacters(in: .whitespacesAndNewlines) {
                                        print(passcheck)
                                        let responseBody = passcheck
                                        let check = getValueFromJSON2(responseBody: responseBody)
                                        print(check)
                                        if check == "yes" {
                                            showChatLogView = true
                                            isSearching = false
                                        } else {
                                            errorMessage = "Match User did not join the room. Try again!"
                                            self.alertType = .showError
                                            isSearching = false
                                        }
                                    } else {
                                        errorMessage = "Match User did not join the room. Try again!"
                                        self.alertType = .showError
                                        isSearching = false
                                    }
                                case .failure(let error):
                                    errorMessage = "Error: \(error.localizedDescription)"
                                    self.alertType = .showError
                                    isSearching = false
                                }
                            }
                        },
                        secondaryButton: .cancel(Text("No"))
                    )
                }
            }
            .onAppear {
                Task {
                    await storeVM.updateCustomerProductStatus()
                }
            }
        }
        .onAppear {
            authViewModel.fetchUserUID()
        }
    }
}
