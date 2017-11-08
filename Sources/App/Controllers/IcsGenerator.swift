//
//  IcsGenerator.swift
//  KulCalendarPackageDescription
//
//  Created by Damiaan on 10/10/17.
//

import Vapor
import Foundation
import Kanna
import iCalendar
import Dispatch

let comparativeLanguagesURL = URL(string: "https://www.kuleuven.be/sapredir/uurrooster/pre_laden.htm?OBJID=52894805&OTYPE=SM&TAAL=E&SEL_JAAR=2017")!
let distributedURL = URL(string: "https://www.kuleuven.be/sapredir/uurrooster/pre_laden.htm?OBJID=52370724&OTYPE=SM&TAAL=E&SEL_JAAR=2017")!
let softwareArchitectureURL = URL(string: "https://www.kuleuven.be/sapredir/uurrooster/pre_laden.htm?OBJID=54072110&OTYPE=SM&TAAL=E&SEL_JAAR=2017")!
let courseURLs = [comparativeLanguagesURL, distributedURL, softwareArchitectureURL]

func parseEvents(from url: URL) throws -> [iCalendar.Event] {
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

public func createCalendar() -> String {
	let group = DispatchGroup()
	var events = [iCalendar.Event]()
	for url in courseURLs {
		print("visiting", url)
		group.enter()
		DispatchQueue.global(qos: .userInitiated).async {
			do {
				events.append(contentsOf: try parseEvents(from: url))
				print("events from url loaded")
			} catch {
				print("❌", error)
			}
			group.leave()
		}
	}

	group.wait()
	let calendar = Calendar(events: events)
	return Writer.write(calendar: calendar)
}

public func debugCalendar() -> Response {
	return Response { (chunker) in
		let group = DispatchGroup()
		for url in courseURLs {
			print("visiting", url)
			group.enter()
			DispatchQueue.global(qos: .userInitiated).async {
				do {
					try chunker.write("visiting URL\n")
					let x = try parseEvents(from: url)
					try chunker.write("read \(x.count) bytes from url\n")
				} catch {
					print("❌", error)
				}
				group.leave()
			}
		}
		
		group.wait()
		try chunker.close()
	}
}

