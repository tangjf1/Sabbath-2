//
//  SabbathView.swift
//  Sabbath
//
//  Created by Jasmine on 4/9/23.
//

import SwiftUI

struct SabbathView: View {
    @EnvironmentObject var affirmationsVM: AffirmationsViewModel
    @Binding var date: Date
    @State var affirmation = ""
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    Text("\"\(affirmation)\"")
                        .italic()
                        .multilineTextAlignment(.center)
                    Image(date.getDayOfMonth())
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                    Spacer()
                }
                .padding()
                
                if affirmationsVM.isLoading {
                    ProgressView()
                        .scaleEffect(2)
                }
            }
        }
        .onAppear {
            Task {
                affirmation = await affirmationsVM.getAffirmation()
            }
        }
        .onChange(of: date) { _ in
            Task {
                affirmation = await affirmationsVM.getAffirmation()
            }
        }
    }
}

struct SabbathView_Previews: PreviewProvider {
    static var previews: some View {
        SabbathView(date: .constant(Date()))
            .environmentObject(AffirmationsViewModel())
    }
}
