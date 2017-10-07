import iCalendar
import Kanna
import Foundation

let comparativeLanguagesURL = URL(string: "https://webwsp.aps.kuleuven.be/sap(bD1ubCZjPTIwMA==)/public/bsp/sap/z_mijnuurrstrs/uurrooster_sem_lijst.htm?sap-params=dGl0ZWxsaWpzdD1TY2hlZHVsZSZvdHlwZT1TTSZvYmppZD01Mjg5NDgwNSZiZWdpbndlZWsxPTIwMTc0MCZlaW5kZXdlZWsxPTIwMTc1MCZiZWdpbndlZWsyPTI5OTkwMSZlaW5kZXdlZWsyPTIwMDAwMSZzY19vYmppZD0wMDAwMDAwMCZzZXNzaW9uaWQ9MkUxREUwRjYzNjBEMUVEN0FBQ0FFNUExQjdDRDgwMDgmdHlwZV9ncm9lcD0%3d")!

let distributedURL = URL(string: "https://webwsp.aps.kuleuven.be/sap(bD1ubCZjPTIwMA==)/public/bsp/sap/z_mijnuurrstrs/uurrooster_sem_lijst.htm?sap-params=dGl0ZWxsaWpzdD1TY2hlZHVsZSZvdHlwZT1TTSZvYmppZD01MjM3MDcyNCZiZWdpbndlZWsxPTIwMTc0MCZlaW5kZXdlZWsxPTIwMTc1MSZiZWdpbndlZWsyPTI5OTkwMSZlaW5kZXdlZWsyPTIwMDAwMSZzY19vYmppZD0wMDAwMDAwMCZzZXNzaW9uaWQ9MkUxREUwRjYzNjBEMUVEN0FBRDcxM0NBRTZCQjAwMUMmdHlwZV9ncm9lcD0%3d")!

let gregorianCalendar = Calendar(identifier: .gregorian)
let europeBrussels = TimeZone(identifier: "Europe/Brussels")

func date(dayAndMonth: String, time: [Int]) -> Date {
	let components = dayAndMonth.split(separator: ".").map {Int($0)}
	return DateComponents(
		calendar: gregorianCalendar, timeZone: europeBrussels,
		year: 2017, month: components[1], day: components[0],
		hour: time[0], minute: time[1]
	).date!
}

enum HTMLParsingError: String, Error {
	case datesNotFound
	case timeSpanNotFound
	case locationNotFound
	case courseIdNotFound
	case courseNameNotFound
}

func events(from schedule: HTMLDocument) throws -> [Event] {
	var result = [Event]()
	
	let horizontalRulers = schedule.css("html > body > center > table > tr > td > hr").makeIterator()
	
	for ruler in horizontalRulers {
		let courseInfo = ruler.xpath("../../../preceding::table[1]/tr/td[position() >= 2]").makeIterator()
		guard let dates = ruler.xpath("../../../tr").first?.css("td > font > i").makeIterator() else {
			throw HTMLParsingError.datesNotFound
		}
		
		func readString(error: HTMLParsingError) throws -> String {
			guard let result = courseInfo.next()?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {throw error}
			return result
		}
		let timespan   = try readString(error:   .timeSpanNotFound) // "10:30 to 12:30"
		let location   = try readString(error:   .locationNotFound) // "200A 00.225"
		let courseID   = try readString(error:   .courseIdNotFound) // "Hs01a"
		let courseName = try readString(error: .courseNameNotFound) // "Distributed systems lecture"
		
		let timeComponents = timespan
			.components(separatedBy: " to ")
			.map {
				$0.components(separatedBy: ":")
				  .map {Int($0)!}
			}
		
		for dateElement in dates {
			let dateString = dateElement.text!
			let startDate = date(dayAndMonth: dateString, time: timeComponents[0])
			let endDate = date(dayAndMonth: dateString, time: timeComponents[1])
			
			result.append(
				Event(
					uid: courseID + String(startDate.timeIntervalSinceReferenceDate),
					startDate: startDate,
					endDate: endDate,
					description: courseID,
					summary: courseName,
					location: location
				)
			)
		}
		
	}
	
	return result
}
