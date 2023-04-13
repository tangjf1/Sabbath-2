//
//  UserSetUpView.swift
//  Sabbath
//
//  Created by Jasmine on 4/5/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserSetUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userVM: UserViewModel
    @State var user: User
    var newUser: Bool {
        return user.id == nil
    }
    @State private var presentContentViewSheet = false
    @State private var backToLogin = false
    @State private var selectedSabbath: Sabbath = .Sun
    @FocusState private var firstNameIsFocused: Bool
    @FocusState private var lastNameIsFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 50) {
                if newUser {
                    VStack {
                        Text("Thank you for signing up with Sabbath!")
                            .padding(.top)
                            .font(.title)
                            .foregroundColor((Color("SabbathBlue")))
                            .bold()
                        Text("Please enter in some additional information:")
                    }
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                } else {
                    Text("View or Update Your Information:")
                            .multilineTextAlignment(.center)
                }
                
                VStack (alignment: .leading, spacing: 4){
                    Text("First Name")
                        .bold()
                    TextField("Enter First Name", text: $user.firstName)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .focused($firstNameIsFocused)
                        .padding(.bottom)
                    
                    Text("Last Name")
                        .bold()
                    TextField("Enter Last Name", text: $user.lastName)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .focused($lastNameIsFocused)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack{
                    Text("Birthday")
                        .bold()
                    DatePicker("", selection: $user.birthday, displayedComponents: .date)
                }
                
                VStack (spacing: 2){
                    HStack {
                        Text("Day of Sabbath")
                            .bold()
                        
                        Spacer()
                        
                        Picker("Day of Sabbath", selection: $selectedSabbath) {
                            ForEach(Sabbath.allCases, id: \.self) { day in
                                Text(day.rawValue.capitalized) } }
                        .onChange(of: selectedSabbath) { newSabbath in
                            user.sabbath = newSabbath.rawValue
                        }
                    }
                    Text("Sabbath, a day of rest and rejuvenation, is often observed in many religious traditions, but can be incorporated in everyone's schedules to promote and prioritize well-being")
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .fullScreenCover(isPresented: $presentContentViewSheet) {
                ContentView()
            }
            .fullScreenCover(isPresented: $backToLogin) {
                LoginView()
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if newUser {
                            let user = Auth.auth().currentUser
                            user?.delete { error in
                              if let error = error {
                                  print("ERROR: \(error.localizedDescription)")
                              } else {
                                print("Success! Account Deleted")
                              }
                            }
                        }
                        dismiss()
                    } label: {
                        Text("\(newUser ? "Cancel" : "Back")")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                           let wasNewUser = newUser
                            let success = await userVM.saveUser(user: user)
                            if success {
                                if wasNewUser {
                                    print("⭐️ Saved new user")
                                    presentContentViewSheet.toggle()
                                } else {
                                    print("UPDATED current user: \(user)")
                                    dismiss()
                                }
                            } else {
                                print("DANG! Error saving user!")
                            }
                        }
                    }
                    .disabled(user.firstName.isEmpty || user.lastName.isEmpty)
                }
                
                
                
                if !newUser  {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Sign Out") {
                            do {
                                try Auth.auth().signOut()
                                print("🪵➡️ Logout Successful!")
                                backToLogin.toggle()
                            } catch {
                                print("😡 ERROR: Could not sign out!")
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .onAppear{
            switch user.sabbath {
            case "Sun":
                selectedSabbath = .Sun
            case "Mon":
                selectedSabbath = .Mon
            case "Tue":
                selectedSabbath = .Tue
            case "Wed":
                selectedSabbath = .Wed
            case "Thu":
                selectedSabbath = .Thu
            case "Fri":
                selectedSabbath = .Fri
            default:
                selectedSabbath = .Sat
            }
        }
    }
}

struct UserSetUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserSetUpView(user: User())
                .environmentObject(UserViewModel())
        }
    }
}
