import Vapor
import Fluent
import Foundation

enum Direction: String {
    case Departure
    case Arrival
}

final class Flight: Model {
    var id: Node?
    let flightID: String
    let flightName: String
    let destinations: String
    let flightDirection: String
    let scheduleTime: String
    let actualLandingTime: String?
    let estimatedLandingTime: String?
    let flightStates: String
    
    init(flightID: String,
         flightName: String,
         destinations: String,
         flightDirection: String,
         scheduleTime: String,
         actualLandingTime: String? = nil,
         estimatedLandingTime: String? = nil,
         flightStates: String) {
        
        self.id = UUID().uuidString.makeNode()
        self.flightID = flightID
        self.flightName = flightName
        self.destinations = destinations
        self.flightDirection = flightDirection
        self.scheduleTime = scheduleTime
        self.actualLandingTime = actualLandingTime
        self.estimatedLandingTime = estimatedLandingTime
        self.flightStates = flightStates
    }
    
    // NodeInitializable
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        flightID = try node.extract("")
        flightName = try node.extract("flightName")
        destinations = try node.extract("destinations")
        flightDirection = try node.extract("flightDirection")
        scheduleTime = try node.extract("scheduleTime")
        actualLandingTime = try node.extract("actualLandingTime")
        estimatedLandingTime = try node.extract("estimatedLandingTime")
        flightStates = try node.extract("flightStates")
    }
    
    // NodeRepresentable
    func makeNode(context: Context) throws -> Node {
        return try Node(node: ["id": id,
                               "flightID": flightID,
                               "flightName": flightName,
                               "destinations": destinations,
                               "flightDirection": flightDirection,
                               "scheduleTime": scheduleTime,
                               "actualLandingTime": actualLandingTime,
                               "estimatedLandingTime": estimatedLandingTime,
                               "flightStates": flightStates])
    }
}

extension Flight: Preparation {
    static func prepare(_ database: Database) throws {
        //
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}
