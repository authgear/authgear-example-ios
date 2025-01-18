//
//  ContentView.swift
//  my_demo_app
//
//  Created by Pius Aboyi on 15/01/2025.
//

import SwiftUI
import Authgear
struct ContentView: View {
    
    private var authgear: Authgear = Authgear(clientId: "<ClIENT_ID>", endpoint: "<AUTHGEAR_ENDPOINT>")
    @State private var loginState: SessionState = .unknown
    @State private var isLoading: Bool = false
    @State private var userId: String? = ""
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            }
            if loginState == SessionState.authenticated {
                Text("Welcome user \(userId ?? "user")")
                Button(action: openUserSettings) {
                    Text("User Settings")
                }
                Button(action: logout) {
                    Text("Logout")
                }
            } else {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("My Demo App")
                Button(action: startAuthentication) {
                    Text("Login")
                }
            }
        }
        .padding()
        .onAppear() {
            authgear.configure() { result in
                switch result {
                case .success():
                    // configured successfully
                    // refresh access token if user has an existing session
                    if authgear.sessionState == SessionState.authenticated {
                        getCurrentUser()
                    }
                case let .failure(error):
                    // failed to configured
                    print("config failed", error)
                }
            }
        }
    }
    
    func startAuthentication() {
        isLoading = true
        authgear.authenticate(redirectURI: "com.example.authgeardemo://host/path", handler: { result in
            switch result {
            case let .success(userInfo):
                // login successfully
                userId = userInfo.sub
                loginState = authgear.sessionState
                isLoading = false
            case let .failure(error):
                if let authgearError = error as? AuthgearError, case .cancel = authgearError {
                    // user cancel
                    isLoading = false
                } else {
                    // Something went wrong
                    isLoading = false
                }
            }
        })
    }
    
    func logout() {
        isLoading = true
        authgear.logout { result in
            switch result {
            case .success():
                // logout successfully
                isLoading = false
                loginState = authgear.sessionState
            case let .failure(error):
                print("failed to logout", error)
                isLoading = false// failed to login
            }
        }
    }
    
    func openUserSettings() {
        authgear.open(page: SettingsPage.settings)
    }
    
    func getCurrentUser() {
        isLoading = true
        authgear.fetchUserInfo { userInfoResult in
            // sessionState is now up to date
            // it will change to .noSession if the session is invalid
            loginState = authgear.sessionState
            
            switch userInfoResult {
            case let .success(userInfo):
                // read the userInfo if needed
                userId = userInfo.sub
                isLoading = false
            case let .failure(error):
                // failed to fetch user info
                // the refresh token maybe expired or revoked
                print("the refresh token maybe expired or revoked", error)
                isLoading = false
            }
        
        }
    }
}

#Preview {
    ContentView()
}
