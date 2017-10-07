import XCTest
@testable import KulCalendar
import iCalendar
import Kanna


class KulCalendarTests: XCTestCase {
	
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
		
		let start = gregorianCalendar.date(
			from: DateComponents(
				timeZone: europeBrussels,
				year: 2017, month: 10, day: 02,
				hour: 22, minute: 0, second: 0
			)
		)!
		let basicEvent = Event(uid: "A", startDate: start, endDate: start.addingTimeInterval(3600))
		let calendar = Calendar(events: [basicEvent])
		
		XCTAssertEqual(
			Writer.write(calendar: calendar),
			"""
			BEGIN:VCALENDAR
			PRODID;X-RICAL-TZSOURCE=TZINFO:-//Michael Brown//iCalendar//EN
			CALSCALE:GREGORIAN
			VERSION:2.0
			BEGIN:VEVENT
			DTEND;VALUE=DATE-TIME:20171002T230000
			DTSTART;VALUE=DATE-TIME:20171002T220000
			UID:A
			END:VEVENT
			END:VCALENDAR

			""".replacingOccurrences(of: "\n", with: "\r\n")
		)
		
		try? Writer.write(calendar: calendar).write(toFile: "/tmp/testke.ics", atomically: true, encoding: .utf8)
    }
	
	func testParseSchedule() {
		do {
			let distrubutedSchedule = try HTML(url: distributedURL, encoding: .utf8)
			let comparativeSchedule = try HTML(url: comparativeLanguagesURL, encoding: .utf8)
			let calendar = try Calendar(events: events(from: distrubutedSchedule) + events(from: comparativeSchedule) )
			try Writer.write(calendar: calendar).write(toFile: "/tmp/testke.ics", atomically: true, encoding: .utf8)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

    static var allTests = [
        ("testExample", testExample),
    ]
}
