import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
    }

    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    var day: Int {
        Calendar.current.component(.day, from: self)
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func isSameMonth(as other: Date) -> Bool {
        let cal = Calendar.current
        return cal.component(.year, from: self) == cal.component(.year, from: other)
            && cal.component(.month, from: self) == cal.component(.month, from: other)
    }

    var shortDateString: String {
        self.formatted(.dateTime.month().day())
    }

    var monthYearString: String {
        self.formatted(.dateTime.year().month())
    }

    var yearString: String {
        self.formatted(.dateTime.year())
    }

    var dayOfWeekString: String {
        self.formatted(.dateTime.weekday(.wide))
    }
}
