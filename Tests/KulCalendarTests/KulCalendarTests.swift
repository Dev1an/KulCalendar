import XCTest
@testable import KulCalendar
import iCalendar
import Kanna

class KulCalendarTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

		let gregorianCalendar = Foundation.Calendar.current
		let europeBrussels = TimeZone(identifier: "Europe/Brussels")
		
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
		let comparativeLanguagesSchedule = try! downloadSchedule()
		let courseInfo = comparativeLanguagesSchedule.xpath("/html/body/center/table[8]/tr/td[position() >= 2 and not(position() > 5)]").makeIterator()
		for element in courseInfo {
			print("info:", element.text!.trimmingCharacters(in: .whitespacesAndNewlines))
		}
		let dates = comparativeLanguagesSchedule.xpath("/html/body/center/table[9]/tr").first!.css("td > font > i").makeIterator()
		
		for date in dates {
			print("date:", date.text!)
		}
	}

    static var allTests = [
        ("testExample", testExample),
    ]
}
