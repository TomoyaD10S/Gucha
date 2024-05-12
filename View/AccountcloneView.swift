import SwiftUI

struct AccountcloneView: View {
    @State private var ids = [
        ID(name: "Account Manegement"),
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
        case "Account Manegement":
            return AnyView(AccountManegement())
        case "Delete Account":
            return AnyView(Delete_Account())
        default:
            return AnyView(EmptyView())
        }
    }
}

struct AccountcloneView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}

