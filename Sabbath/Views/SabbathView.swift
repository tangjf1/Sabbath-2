//
//  SabbathView.swift
//  Sabbath
//
//  Created by Jasmine on 4/9/23.
//

import SwiftUI

struct SabbathView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sabbathVM: SabbathViewModel
    @EnvironmentObject var weatherVM: WeatherViewModel
    @EnvironmentObject var locationManager: LocationManager
    @Binding var date: Date
    @State var sabbathEvent: SabbathEvent
    @FocusState private var textFieldIntentionsIsFocused: Bool
    @FocusState private var textFieldIsFocused: Bool
    var body: some View {
        NavigationStack{
            ZStack {
                List {
                    Section{
                        VStack (alignment: .leading){
                            Text("Intentions and plans for the day:")
                                .font(.body)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("  Write your goals and self-care plan here", text: $sabbathEvent.intentionsEntry, axis: .vertical)
                                .font(.callout)
                                .submitLabel(.done)
                                .focused($textFieldIntentionsIsFocused)
                                .onChange(of: sabbathEvent.intentionsEntry) { newValue in
                                    guard let newValueLastChar = newValue.last else {return}
                                    if newValueLastChar == "\n" {
                                        sabbathEvent.intentionsEntry.removeLast()
                                        textFieldIntentionsIsFocused = false
                                    }
                                }
                                .frame(minHeight: 80, maxHeight: .infinity, alignment: .topLeading)
                                .overlay{
                                    RoundedRectangle(cornerRadius: 5).stroke(.gray.opacity(0.25), lineWidth: 1)
                                }
                        }
                        .listSectionSeparator(.hidden)
                        .listRowSeparator(.hidden)
                    } header: {
                        HStack {
                            Text("Goals for Sabbath")
                            Spacer()
                            WeatherView(selectedDate: $date)
                        }
                    }
                    
                    Section("Journal and Reflection"){
                        VStack {
                            Text(sabbathEvent.journalPrompt)
                                .font(.body)
                                .minimumScaleFactor(0.5)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("  Write your thoughts and reflections here", text: $sabbathEvent.journalEntry, axis: .vertical)
                                .font(.callout)
                                .submitLabel(.done)
                                .focused($textFieldIsFocused)
                                .onChange(of: sabbathEvent.journalEntry) { newValue in
                                    guard let newValueLastChar = newValue.last else {return}
                                    if newValueLastChar == "\n" {
                                        sabbathEvent.journalEntry.removeLast()
                                        textFieldIsFocused = false
                                    }
                                }
                                .frame(minHeight: 160, maxHeight: .infinity, alignment: .topLeading)
                                .overlay{
                                    RoundedRectangle(cornerRadius: 5).stroke(.gray.opacity(0.25), lineWidth: 1)
                                }
                            
                            HStack {
                                Text("Did I meet my intentions?")
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(2)
                                GoalRatingView(rating: $sabbathEvent.goalsRating)
                                    .imageScale(.small)
                            }
                            .frame(alignment: .leading)
                        }
                        .listSectionSeparator(.hidden)
                        .listRowSeparator(.hidden)
                    }
                    
                    Section {
                        VStack {
                            Image(date.getDayOfMonth())
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                            Text("\"\(sabbathEvent.affirmation)\"")
                                .italic()
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.bottom)
                        }
                    }
                    .listSectionSeparator(.hidden)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            
            if sabbathVM.isLoading {
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Task {
                        await sabbathVM.saveSabbathEvent(sabbathEvent: sabbathEvent)
                    }
                    dismiss()
                } label: {
                    HStack{
                        Image(systemName: "chevron.backward")
                        Text("Back to Calendar")
                    }
                }
                
            }
        }
        .onAppear {
            if sabbathEvent.id == nil {
                sabbathEvent.journalPrompt = sabbathVM.journalPrompts.randomElement()!
                Task {
                    sabbathEvent.affirmation = await sabbathVM.getAffirmation()
                }
            }
        }
    }
}

struct SabbathView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SabbathView(date: .constant(Date()), sabbathEvent: SabbathEvent(date: Date().getFullDate()))
                .environmentObject(SabbathViewModel())
                .environmentObject(LocationManager())
                .environmentObject(WeatherViewModel())
        }
    }
}
