struct Constants {
    static let nok = "No flights found."

    struct Query {
        static let scheduledate = "scheduledate"
        static let city = "city"
        static let flights = "flights"
    }

    enum Direction: String {
        case departure = "D"
        case arrival   = "A"
    }
}
