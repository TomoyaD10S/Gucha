import SwiftUI

struct HelpManagementView: View {
    @State private var ids = [
        ID(name: "Report"),
        ID(name: "Block"),
    ]
    
    @Binding var isPresented: Bool
    let userID: String
    let name: String
    let age: Int
    
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
            .navigationTitle("Help")
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }
    
    private func destinationView(for item: ID) -> some View {
        switch item.name {
        case "Report":
            return AnyView(ReportView())
        case "Block":
            return AnyView(BlockView(userID: userID, name: name, age: age))
        default:
            return AnyView(EmptyView())
        }
    }
}
