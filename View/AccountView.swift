import SwiftUI

struct ID: Identifiable {
    var id = UUID()
    var name: String
}

struct AccountView: View {
    @State private var ids = [
        ID(name: "Profile"),
        ID(name: "Account Manegement"),
        ID(name: "Subscription Plan"),
        ID(name: "Terms and Conditions"),
        ID(name: "Blocked User"),
        ID(name: "Delete Account")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                List(ids) { ele in
                    NavigationLink(destination: destinationView(for: ele)) {
                        Text(ele.name)
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Account")
        }
    }
    
    private func destinationView(for item: ID) -> some View {
        switch item.name {
        case "Profile":
            return AnyView(ProfileView())
        case "Account Manegement":
            return AnyView(AccountManegement())
        case "Subscription Plan":
            return AnyView(SubscriptionPlanView())
        case "Terms and Conditions":
            return AnyView(TermsAndConditionsView())
        case "Blocked User":
            return AnyView(BlockedUserView())
        case "Delete Account":
            return AnyView(Delete_Account())
        default:
            return AnyView(EmptyView())
        }
    }
}
