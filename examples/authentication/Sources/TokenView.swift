//
// Copyright contributors to the IBM Security Verify Authentication Sample App for iOS project
//

import SwiftUI
import Authentication

struct TokenView: View {
    @EnvironmentObject var viewModel: SignInViewModel
    
    var body: some View {
        Text(viewModel.token.accessToken)
    }
}

struct TokenView_Previews: PreviewProvider {
    static var previews: some View {
        TokenView()
    }
}
