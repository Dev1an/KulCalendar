import iCalendar
import Kanna
import Foundation

let comparativeLanguagesURL = URL(string: "https://webwsp.aps.kuleuven.be/sap(bD1ubCZjPTIwMA==)/public/bsp/sap/z_mijnuurrstrs/uurrooster_sem_lijst.htm?sap-params=dGl0ZWxsaWpzdD1TY2hlZHVsZSZvdHlwZT1TTSZvYmppZD01Mjg5NDgwNSZiZWdpbndlZWsxPTIwMTc0MCZlaW5kZXdlZWsxPTIwMTc1MCZiZWdpbndlZWsyPTI5OTkwMSZlaW5kZXdlZWsyPTIwMDAwMSZzY19vYmppZD0wMDAwMDAwMCZzZXNzaW9uaWQ9MkUxREUwRjYzNjBEMUVEN0FBQ0FFNUExQjdDRDgwMDgmdHlwZV9ncm9lcD0%3d")!

let distributedURL = URL(string: "https://webwsp.aps.kuleuven.be/sap(bD1ubCZjPTIwMA==)/public/bsp/sap/z_mijnuurrstrs/uurrooster_sem_lijst.htm?sap-params=dGl0ZWxsaWpzdD1TY2hlZHVsZSZvdHlwZT1TTSZvYmppZD01MjM3MDcyNCZiZWdpbndlZWsxPTIwMTc0MCZlaW5kZXdlZWsxPTIwMTc1MSZiZWdpbndlZWsyPTI5OTkwMSZlaW5kZXdlZWsyPTIwMDAwMSZzY19vYmppZD0wMDAwMDAwMCZzZXNzaW9uaWQ9MkUxREUwRjYzNjBEMUVEN0FBRDcxM0NBRTZCQjAwMUMmdHlwZV9ncm9lcD0%3d")!

public func downloadSchedule() throws -> HTMLDocument {
	return try HTML(url: distributedURL, encoding: .utf8)
}
