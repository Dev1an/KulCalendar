import Vapor
import App

let drop = try Droplet()
drop.get { request in
	return try createCalendar()
}

try drop.run()
