import Vapor
import App

import Foundation
import Kanna
import iCalendar
import Dispatch

func events(from url: URL) throws -> [iCalendar.Event] {
	let redirectionFollower = Follower()

	let weekSchedule = try EngineClient.factory.get(url.absoluteString, through: [ScheduleLoader.shared, redirectionFollower])
	guard let scheduleUri = weekSchedule.headers[Follower.finalDestinationHeader], let client = redirectionFollower.lastClient else { fatalError("No redirection") }
	let showSemester1View = Request(method: .post, uri: scheduleUri)
	showSemester1View.formURLEncoded = try Node(node: ["onInputProcessing(semester)": ""])
	let semester1Response = try client.respond(to: showSemester1View, through: [ScheduleLoader.shared, redirectionFollower])
	guard let bytes = semester1Response.body.bytes else { fatalError("no bytes in schedule") }
	let semester1Events = try events(
		from: try HTML(
			html: Data(bytes: bytes),
			encoding: .utf8
		)
	)
	
	guard let semester1Uri = semester1Response.headers[Follower.finalDestinationHeader] else { fatalError("No redirection") }
	let showSemester2View = Request(method: .post, uri: semester1Uri)
	showSemester2View.formURLEncoded = try Node(node: [
		"typedatum": "2",
		"onInputProcessing(semester)": ""
	])
	let semester2Response = try client.respond(to: showSemester2View, through: [ScheduleLoader.shared, redirectionFollower])
	guard let semester2bytes = semester2Response.body.bytes else { fatalError("no bytes in schedule") }
	let semester2Events = try events(
		from: try HTML(
			html: Data(bytes: semester2bytes),
			encoding: .utf8
		)
	)
	
	return semester1Events + semester2Events
}

let courseURLs = [comparativeLanguagesURL, distributedURL, softwareArchitectureURL]
let group = DispatchGroup()
var events = [iCalendar.Event]()
let start = Date()
for url in courseURLs {
	group.enter()
	DispatchQueue.global(qos: .userInitiated).async {
		do {
			events.append(contentsOf: try events(from: url))
		} catch {
			print("❌", error)
		}
		group.leave()
	}
}

group.wait()
let end = Date()
print(end.timeIntervalSince(start))
let calendar = Calendar(events: events)
try Writer.write(calendar: calendar).write(toFile: "/tmp/KulCal.ics", atomically: true, encoding: .utf8)
