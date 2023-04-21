//
//  GoalRatingView.swift
//  Sabbath
//
//  Created by Jasmine on 4/20/23.
//

import SwiftUI

struct GoalRatingView: View {
    @Binding var rating: Int // change this to @Binding after layout is tested
    let highestRating = 5
    let unselected = Image(systemName: "rhombus")
    let selected = Image(systemName: "rhombus.fill")
    var font: Font = .title
    let fillColor: Color = Color("SabbathBlue")
    let emptyColor: Color = .gray
    
    var body: some View {
        HStack{
            ForEach(1...highestRating, id: \.self) { number in
                showStar(for: number).foregroundColor(number <= rating ? fillColor : emptyColor)
                    .font(font)
                    .onTapGesture {
                            rating = number
                    }
            }
        }
    }
    
    func showStar(for number: Int) -> Image {
        if number > rating {
            return unselected
        } else {
            return selected
        }
    }
}

struct GoalRatingView_Previews: PreviewProvider {
    static var previews: some View {
        GoalRatingView(rating: .constant(4))
    }
}
