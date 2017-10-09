import iCalendar
import Kanna
import Foundation

public let comparativeLanguagesURL = URL(string: "http://www.kuleuven.be/sapredir/uurrooster/pre_laden.htm?OBJID=52894805&OTYPE=SM&TAAL=E&SEL_JAAR=2017")!
public let distributedURL = URL(string: "http://www.kuleuven.be/sapredir/uurrooster/pre_laden.htm?OBJID=52370724&OTYPE=SM&TAAL=E&SEL_JAAR=2017")!
public let softwareArchitectureURL = URL(string: "http://www.kuleuven.be/sapredir/uurrooster/pre_laden.htm?OBJID=54072110&OTYPE=SM&TAAL=E&SEL_JAAR=2017")!

let gregorianCalendar = Calendar(identifier: .gregorian)
let europeBrussels = TimeZone(identifier: "Europe/Brussels")

func inFirstSemester(month: Int) -> Bool {
	return month > 7
}

func date(dayAndMonth: [Int], time: [Int]) -> Date {
	let today = Date()
	let firstYear: Int
	if inFirstSemester(month: gregorianCalendar.component(.month, from: today)) {
		firstYear = gregorianCalendar.component(.year, from: today)
	} else {
		firstYear = gregorianCalendar.component(.year, from: today) - 1
	}
	let year = inFirstSemester(month: dayAndMonth[1]) ? firstYear : firstYear+1
	return DateComponents(
		calendar: gregorianCalendar, timeZone: europeBrussels,
		year: year, month: dayAndMonth[1], day: dayAndMonth[0],
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

public func events(from schedule: HTMLDocument) throws -> [Event] {
	var result = [Event]()
	
	let horizontalRulers = schedule.css("html > body > center > table > tr > td > hr").makeIterator()
	
	for ruler in horizontalRulers {
		let courseInfo = ruler.xpath("../../../preceding::table[1]/tr/td[position() >= 2]").makeIterator()
		guard let dateSelector = ruler.xpath("../../../tr").first?.css("td > font > i") else {
			throw HTMLParsingError.datesNotFound
		}
		
		if dateSelector.count > 0 {
			let dates = dateSelector.makeIterator()
			
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
				let dateComponents = dateElement.text!.split(separator: ".").map {Int($0)!}
				let startDate = date(dayAndMonth: dateComponents, time: timeComponents[0])
				let endDate = date(dayAndMonth: dateComponents, time: timeComponents[1])
				
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
		
	}
	
	return result
}
