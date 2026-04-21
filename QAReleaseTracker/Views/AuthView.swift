//
//  AuthView.swift
//  QAReleaseTracker
//
//  Created by GermanDriveM on 4/21/26.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                // Logo
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text("QA Release Tracker")
                        .font(.title)
                        .bold()
                    Text("by CodeRendering Studio")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    TextField("Phone Number (+1XXXXXXXXXX)", text: $phoneNumber)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Button(action: authenticate) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)

                    Button(isSignUp ? "Already have an account? Sign In" : "No account? Sign Up") {
                        isSignUp.toggle()
                        errorMessage = ""
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding()

                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    func authenticate() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }
        isLoading = true
        errorMessage = ""

        let endpoint = isSignUp ? "signup" : "token?grant_type=password"
        let urlString = "https://zskjzutxeafxluarmmkx.supabase.co/auth/v1/\(endpoint)"

        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpza2p6dXR4ZWFmeGx1YXJtbWt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3ODYyMzQsImV4cCI6MjA5MjM2MjIzNH0.P91kDwqiARgKJHFkXNxeNBW4-K_QLsBGDrcRHZmAoyQ", forHTTPHeaderField: "apikey")

        let body = ["email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, _ in
            DispatchQueue.main.async {
                isLoading = false
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    errorMessage = "Network error. Try again."
                    return
                }

                if let token = json["access_token"] as? String,
                   let userDict = json["user"] as? [String: Any],
                   let userId = userDict["id"] as? String {
                    appState.accessToken = token
                    appState.userId = userId
                    appState.isLoggedIn = true
                    appState.userPhone = self.phoneNumber
                } else if let msg = json["msg"] as? String {
                    errorMessage = msg
                } else if let error = json["error_description"] as? String {
                    errorMessage = error
                } else {
                    print("Supabase response: \(json)")
                    errorMessage = "Something went wrong. Try again."
                }
            }
        }.resume()
    }
}
