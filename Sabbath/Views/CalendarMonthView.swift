//
//  CalendarMonthView.swift
//  Sabbath
//
//  Created by Jasmine on 4/4/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct CalendarMonthView: View {
    @FirestoreQuery(collectionPath: "users") var users: [User]
    @Binding var selectedDate: Date
    @State var month = Date()
    var user: User {
        return users.first(where: {$0.email == Auth.auth().currentUser?.email ?? "none"}) ?? User()
    }
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    @FirestoreQuery(collectionPath: "users/\(Auth.auth().currentUser?.uid ?? "tGeWm6jBzXOz0kxnuBLtl9dd3KP2")/\(Date().getFullDate())") var events: [Event]
    
    var body: some View {
        VStack {
            HStack {
                Button{
                    month = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
                    selectedDate = month
                } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text("\(month, formatter: monthYearFormatter)").font(.title3)
                Spacer()
                Button{
                    month = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
                    selectedDate = month
                } label: {
                    Image(systemName: "chevron.right")
                }
                
                
            }
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 10) {
                ForEach(month.getDatesForMonth().sorted(by: { $0 < $1 }), id: \.self) { date in
                    DateCell(date: date, isSelected: (selectedDate.getFullDate() == date.getFullDate()), mainMonth: month, sabbath: user.sabbath)
                        .onTapGesture {
                            selectedDate = date
                        }
                        .frame(height: 40)
                }
            }
        }
    }
    
    func getWeekNumbers() {
        
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let mainMonth: Date
    let sabbath: String
    
    @FirestoreQuery(collectionPath: "users/\(Auth.auth().currentUser?.uid ?? "none")/\(Date().getFullDate())") var events: [Event]
    
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
            if (!events.isEmpty) && !isSabbath {
                Circle().foregroundColor(Color("SabbathPeach")).frame(width: 10, height: 10)
            } else {
                Circle().opacity(0).frame(width: 10, height: 10)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .disabled(!isSabbath)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke((isSelected ? Color("SabbathBlue") : Color.clear), lineWidth: 4 ))
        .background(isSabbath ? Color("SabbathPink").opacity(isCurrentMonth ? 0.5 : 0.2) : Color.clear)
        .cornerRadius(8)
        .onAppear{
            $events.path = "users/\(Auth.auth().currentUser?.uid ?? "none")/\(date.getFullDate())"
        }
    }
}

extension Date {
    func getDayOfMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self)
    }
    
    func getFullDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: self)
    }
    
    func getFullDateForWeather() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
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
    
    func getDayOfWeekNum() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "e"
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
        
        let daysInMonth = Int(startDate.getDayOfWeekNum())! + range.endIndex-2

        let numberOfWeeks = (daysInMonth % 7 != 0 ? (daysInMonth / 7) + 1 : (daysInMonth / 7) )
        
        return (0 ..< numDaysInAWeek * numberOfWeeks).map { i in
            calendar.date(byAdding: .day, value: i, to: startOfMonth)!
        }
    }
}

struct CalendarMonthView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMonthView(selectedDate: .constant(Date()))
    }
}
