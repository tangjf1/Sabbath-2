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
    @State var date: Date
    @State var sabbathEvent: SabbathEvent
    @FocusState private var textFieldIsFocused: Bool
    var body: some View {
        NavigationStack{
            ZStack {
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
                    
                    Text(sabbathEvent.journalPrompt)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                    
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
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                        .overlay{
                            RoundedRectangle(cornerRadius: 5).stroke(.gray.opacity(0.25), lineWidth: 1)
                        }
                    
                    Spacer()
                }
                .padding()
                
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
}

struct SabbathView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SabbathView(date: Date(), sabbathEvent: SabbathEvent())
                .environmentObject(SabbathViewModel())
        }
    }
}
