import Vapor
import HTTP

private func badRequest() -> Response {
    let response = Response(status: .badRequest, body: Constants.nok)
    response.headers["Content-Type"] = "text/plain"
    return response
}

private func wrap(_ flights: [Flight]) throws -> Response {
    if flights.count > 0 {
        let flightsNode = try flights.makeNode()
        let nodeDictionary = [Constants.Query.flights: flightsNode]
        let json = try JSON(node: nodeDictionary)
        let response = try Response(status: .ok, json: json)
        return response
    } else {
        return badRequest()
    }
}

let drop = Droplet()

drop.get(Constants.Query.flights) { req in
    guard let scheduledate = req.data[Constants.Query.scheduledate]?.string else {
        throw Abort.badRequest
    }

    guard let city = req.data[Constants.Query.city]?.string else {
        throw Abort.badRequest
    }

    print("Schedule date: " + "\(scheduledate)")
    print("City: " + "\(city)")
    let query = Query()

    let iataResponse = try query.iataQuery(city)

    if let codes = query.unwrapCodes(from: iataResponse) {
        do {
            let flights = try query.flightsMapper(scheduledate, codes)
            return try wrap(flights)
        } catch {
              throw Abort.badRequest
        }
    } else {
        return badRequest()
    }
}

drop.run()
