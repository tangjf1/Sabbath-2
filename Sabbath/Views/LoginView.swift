//
//  LoginView.swift
//  Sabbath
//
//  Created by Jasmine on 4/4/23.
//

import SwiftUI

import Firebase
import FirebaseFirestoreSwift

struct LoginView: View {
    enum Field {
        case email, password
    }

    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMesseage = ""
    @FocusState private var focusField: Field?
    @State private var buttonDisabled = true
    @State private var presentUserSetUpSheet = false
    @State private var presentContentViewSheet = false
    @State var user = User()
    
    var body: some View {
        VStack{
            Image("Sabbath")
                .resizable()
                .scaledToFit()
                .padding()
            
            Group {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                    .focused($focusField, equals: .email)
                    .onSubmit {
                        focusField = .password
                    }
                    .onChange(of: email) { _ in
                        enableButtons()
                    }
                
                SecureField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .focused($focusField, equals: .password)
                    .onSubmit {
                        focusField = nil // will dismiss the keyboard
                    }
                    .onChange(of: password) { _ in
                        enableButtons()
                    }
                
            }
            .textFieldStyle(.roundedBorder)
            .overlay{
                RoundedRectangle(cornerRadius: 5).stroke(.gray.opacity(0.5), lineWidth: 1)
            }
            .padding(.horizontal)
            
            HStack{
                Button("Sign Up") {
                    register()
                }
                .padding(.trailing)
                
                Button("Log In") {
                    login()
                }
                .padding(.leading)
                
            }
            .disabled(buttonDisabled)
            .buttonStyle(.borderedProminent)
            .tint(Color.pink.opacity(0.5))
            .font(.title3)
            .padding(.top)
        }
        .alert(alertMesseage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
        .onAppear{
            if Auth.auth().currentUser != nil {
                print("user \(Auth.auth().currentUser?.email! ?? "") is logged in already")
                presentContentViewSheet = true
            }
        }
        .fullScreenCover(isPresented: $presentUserSetUpSheet) {
            NavigationStack {
                UserSetUpView(user: User(email: email))
            }
        }
        .fullScreenCover(isPresented: $presentContentViewSheet) {
            ContentView()
        }
    }

    func enableButtons() {
        let emailIsGood = email.count >= 6 && email.contains("@")
        let passWordIsGood = password.count >= 6
        buttonDisabled = !(emailIsGood && passWordIsGood)
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error { // log in error occured
                print("😡 SIGN-UP ERROR: \(error.localizedDescription)")
                alertMesseage = "SIGN-UP ERROR: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("😎 Registration Success!")
                presentUserSetUpSheet = true
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error { // log in error occured
                print("😡 LOGIN ERROR: \(error.localizedDescription)")
                alertMesseage = "LOGIN ERROR: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("🪵 Log In Success!")
                Task {
                    presentContentViewSheet = true
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
