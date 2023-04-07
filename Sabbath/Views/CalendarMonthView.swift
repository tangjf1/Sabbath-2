//
//  MonthView2.swift
//  Sabbath
//
//  Created by Jasmine on 4/4/23.
//

import SwiftUI
import Foundation
import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct CalendarMonthView: View {
    @FirestoreQuery(collectionPath: "users") var users: [User]
    @Binding var selectedDate: Date
    @State var month = Date()
    var user: User {
        return users.first(where: {$0.email == Auth.auth().currentUser?.email ?? ""}) ?? User()
    }
    
    func dateSelected(_ date: Date) {
        print("Selected date: \(date)")
        // Do something else here based on the selected date
    }
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Button{
                    month = Calendar.current.date(byAdding: .month, value: -1, to: month)!
                } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text("\(month, formatter: monthYearFormatter)").font(.title3)
                Spacer()
                Button{
                    month = Calendar.current.date(byAdding: .month, value: 1, to: month)!
                } label: {
                    Image(systemName: "chevron.right")
                }
                
                
            }
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(month.getDatesForMonth().sorted(by: { $0 < $1 }), id: \.self) { date in
                    DateCell(date: date, isSelected: (selectedDate == date), mainMonth: month, sabbath: user.sabbath)
                        .onTapGesture {
                            selectedDate = date
                            dateSelected(date)
                            print("\(selectedDate == date)")
                        }
                }
            }
            .onAppear{
            print("selected date: \(selectedDate)")
            }
        }
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let mainMonth: Date
    let sabbath: String
    
    var isSabbath: Bool {
        return date.getDayOfWeek() == sabbath
    }
    
    var isCurrentMonth: Bool {
        return date.getMonthOfDate() == mainMonth.getMonthOfDate()
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(date.getDayOfMonth()).font(.title3).foregroundColor( isCurrentMonth ? .primary : .gray.opacity(0.5))
            }
            if isSelected && !isSabbath {
                Circle().foregroundColor(Color("SabbathPeach")).frame(width: 10, height: 10)
            } else {
                Circle().opacity(0).frame(width: 10, height: 10)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
        .disabled(!isSabbath)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke((isSelected ? Color("SabbathBlue") : Color.clear), lineWidth: 4 ))
        .background(isSabbath ? Color("SabbathPink").opacity(isCurrentMonth ? 0.5 : 0.2) : Color.clear)
        .cornerRadius(8)
    }
}

extension Date {
    func getDayOfMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self)
    }
    
    func getMonthOfDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        return dateFormatter.string(from: self)
    }
    
    func getDayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self)
    }
    
    func getDatesForMonth() -> [Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self)))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        _ = range.count
        let numDaysInAWeek = 7
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
        let startOfMonth = calendar.date(byAdding: .day, value: -calendar.component(.weekday, from: firstOfMonth) + 1, to: firstOfMonth)!
        return (0 ..< numDaysInAWeek * 6).map { i in
            calendar.date(byAdding: .day, value: i, to: startOfMonth)!
        }
    }
}

struct CalendarMonthView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMonthView(selectedDate: .constant(Date()))
    }
}
