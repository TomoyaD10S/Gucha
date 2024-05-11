import SwiftUI

struct AccountManegement: View {
    @State private var ids = [
        ID(name: "Email Change"),
        ID(name: "Password Change"),
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
            .navigationTitle("Account Management")
        }
    }
    
    private func destinationView(for item: ID) -> some View {
        switch item.name {
        case "Email Change":
            return AnyView(EmailChange())
        case "Password Change":
            return AnyView(PasswordChange())
        default:
            return AnyView(EmptyView())
        }
    }
}

struct AccountManegement_Preview: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
