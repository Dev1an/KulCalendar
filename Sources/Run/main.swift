import Vapor
import App

let drop = try Droplet()
drop.get("*") { request in
	return "The vapor hosted version of KulCal is currently in private beta."
}

if let privateKey = drop.config["keys", "damiaan"]?.string {
	drop.get("key", privateKey) { request in
		return createCalendar()
	}
} else {
	drop.get("key", "*") { request in
		return "Key not found. Make sure to set up a private key in the keys config file."
	}
}

try drop.run()
