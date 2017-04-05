import Vapor
import HTTP

struct Query {

    func iataQuery(_ city: String) throws -> Response {
        guard let iataKey = drop.config["keys", "keys", "iataKey"]?.string else {
            throw Abort.badRequest
        }

        return try drop.client.get(
            "https://iatacodes.org/api/v6/autocomplete",
            query: [
                "api_key": iataKey,
                "query": city
            ]
        )
    }

    func unwrapCodes(from response: Response) -> [Polymorphic]? {
        return response.data["response", "airports_by_cities", "code"]?.array
    }

    func flightsMapper(_ scheduledate: String, _ codes: [Polymorphic]) throws -> [Flight] {
        var flights: [Flight] = []

        for code in codes {
            if let iata = code.string {
                let schipholResponse = try schipholQuery(scheduledate, iata)

                if schipholResponse.status == .ok {
                    if let data = schipholResponse.data[Constants.Query.flights]?.array {
                        for flight in data {
                            guard let obj = flight.object else {
                                throw Abort.badRequest
                            }

                            var temp = [String: Any?]()

                            temp["flightID"] = string(from: obj, withKey: "id")

                            //"publicFlightState": Node.Node.object(["flightStates": Node.Node.array([Node.Node.string("SCH")])])
                            if let publicFlightState = obj["publicFlightState"]?.object,
                                let flightStates = publicFlightState["flightStates"]?.array {
                                let flightState = flightStates.first?.string ?? ""
                                temp["flightState"] = flightState
                            }

                            //"route": Node.Node.object(["destinations": Node.Node.array([Node.Node.string("MXP")])])
                            if let route = obj["route"]?.object,
                                let destinations = route["destinations"]?.array {
                                let dest = destinations.first?.string ?? ""
                                temp["destinations"] =  dest
                            }

                            //"scheduleTime": Node.Node.string("21:55:00")
                            temp["scheduleTime"] = string(from: obj, withKey: "scheduleTime")

                            //"flightName": Node.Node.string("VY8437")
                            temp["flightName"] = string(from: obj, withKey: "flightName")

                            //"actualLandingTime": Node.Node.null
                            temp["actualLandingTime"] = string(from: obj, withKey: "actualLandingTime")

                            temp["estimatedLandingTime"] = string(from: obj, withKey: "estimatedLandingTime")

                            //"flightDirection": Node.Node.string("A")
                            if let direction = string(from: obj, withKey: "flightDirection") {
                                switch direction {
                                case Constants.Direction.departure.rawValue:
                                    temp["flightDirection"] = Direction.Departure.rawValue
                                case Constants.Direction.arrival.rawValue:
                                    temp["flightDirection"] = Direction.Arrival.rawValue
                                default:()
                                }
                            }

                            let result = Flight(flightID: temp["flightID"] as? String ?? "",
                                                flightName: temp["flightName"] as? String ?? "",
                                                destinations: temp["destinations"] as? String ?? "",
                                                flightDirection: temp["flightDirection"] as? String ?? "",
                                                scheduleTime: temp["scheduleTime"] as? String ?? "",
                                                actualLandingTime: temp["actualLandingTime"] as? String,
                                                estimatedLandingTime: temp["estimatedLandingTime"] as? String,
                                                flightStates: temp["flightState"] as? String ?? "")

                            flights.append(result)
                        }
                    }
                }
            }
        }

        return flights
    }

    // MARK: - Private functions
    private func schipholQuery(_ scheduledate: String, _ iata: String) throws -> Response {
        guard let appID = drop.config["keys", "keys", "appID"]?.string,
              let appKey = drop.config["keys", "keys", "appKey"]?.string else {
            throw Abort.badRequest
        }

        return try drop.client.get(
            "https://api.schiphol.nl/public-flights/flights",
            headers: ["ResourceVersion": "v3"],
            query: [
                "app_id": appID,
                "app_key": appKey,
                "scheduledate": scheduledate,
                "route": iata,
                "includedelays": "true"
            ]
        )
    }

    private func string(from obj: [String : Polymorphic], withKey key: String) -> String?{
        return obj[key]?.string
    }
}
