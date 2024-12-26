import SwiftUI

struct SiteCell: View {
    let site: AuthSite
    @State private var showingFaceAuth = false
    
    var body: some View {
        Button(action: {
            showingFaceAuth = true
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(site.name)
                        .font(.headline)
                    Text(site.issuer)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "faceid")
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 8)
        }
        .fullScreenCover(isPresented: $showingFaceAuth) {
            FaceAuthView(site: site)
        }
    }
}
