//
//  SabbathView.swift
//  Sabbath
//
//  Created by Jasmine on 4/9/23.
//

import SwiftUI

struct SabbathView: View {
    @Binding var date: Date
    var body: some View {
        ScrollView {
            VStack {
                Image(date.getDayOfMonth())
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
                Spacer()
            }
            .padding()
        }
    }
}

struct SabbathView_Previews: PreviewProvider {
    static var previews: some View {
        SabbathView(date: .constant(Date()))
    }
}
