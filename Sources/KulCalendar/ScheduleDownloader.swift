import iCalendar
import Kanna
import Foundation

let comparativeLanguagesURL = URL(string: "https://webwsp.aps.kuleuven.be/sap(bD1ubCZjPTIwMA==)/public/bsp/sap/z_mijnuurrstrs/uurrooster_sem_lijst.htm?sap-params=dGl0ZWxsaWpzdD1TY2hlZHVsZSZvdHlwZT1TTSZvYmppZD01Mjg5NDgwNSZiZWdpbndlZWsxPTIwMTc0MCZlaW5kZXdlZWsxPTIwMTc1MCZiZWdpbndlZWsyPTI5OTkwMSZlaW5kZXdlZWsyPTIwMDAwMSZzY19vYmppZD0wMDAwMDAwMCZzZXNzaW9uaWQ9MkUxREUwRjYzNjBEMUVEN0FBQ0FFNUExQjdDRDgwMDgmdHlwZV9ncm9lcD0%3d")!

let distributedURL = URL(string: "https://webwsp.aps.kuleuven.be/sap(bD1ubCZjPTIwMA==)/public/bsp/sap/z_mijnuurrstrs/uurrooster_sem_lijst.htm?sap-params=dGl0ZWxsaWpzdD1TY2hlZHVsZSZvdHlwZT1TTSZvYmppZD01MjM3MDcyNCZiZWdpbndlZWsxPTIwMTc0MCZlaW5kZXdlZWsxPTIwMTc1MSZiZWdpbndlZWsyPTI5OTkwMSZlaW5kZXdlZWsyPTIwMDAwMSZzY19vYmppZD0wMDAwMDAwMCZzZXNzaW9uaWQ9MkUxREUwRjYzNjBEMUVEN0FBRDcxM0NBRTZCQjAwMUMmdHlwZV9ncm9lcD0%3d")!

func downloadSchedule() throws -> HTMLDocument {
	return try HTML(url: distributedURL, encoding: .utf8)
}

let gregorianCalendar = Foundation.Calendar.current
let europeBrussels = TimeZone(identifier: "Europe/Brussels")

func date(dayAndMonth: String, time: [Int]) -> Date {
	let components = dayAndMonth.split(separator: ".").map {Int($0)}
	return DateComponents(
		calendar: gregorianCalendar, timeZone: europeBrussels,
		year: 2017, month: components[1], day: components[0],
		hour: time[0], minute: time[1]
	).date!
}

func events(from htmlDocument: HTMLDocument) -> [Event] {
	var result = [Event]()
	
	let schedule = try! downloadSchedule()
	
	let horizontalRuler = schedule.css("html > body > center > table > tr > td > hr").makeIterator()
	
	for ruler in horizontalRuler {
		let courseInfo = ruler.xpath("../../../preceding::table[1]/tr/td[position() >= 2]").makeIterator()
		let dates = ruler.xpath("../../../tr").first!.css("td > font > i").makeIterator()
		
		let getString: ()->String = {courseInfo.next()!.text!.trimmingCharacters(in: .whitespacesAndNewlines)}
		let timespan = getString()
			.components(separatedBy: " to ")
			.map {
				$0.components(separatedBy: ":")
					.map {Int($0)!}
		}
		let location = getString()
		let courseID = getString()
		let courseName = getString()
		
		for dateElement in dates {
			let dateString = dateElement.text!
			let startDate = date(dayAndMonth: dateString, time: timespan[0])
			let endDate = date(dayAndMonth: dateString, time: timespan[1])
			
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
			print("\(DateFormatter.localizedString(from: startDate, dateStyle: .short, timeStyle: .short)) - \(DateFormatter.localizedString(from: endDate, dateStyle: .none, timeStyle: .short)): \(courseName) in \(location) #\(courseID)")
		}
		
	}
	
	return result
}
