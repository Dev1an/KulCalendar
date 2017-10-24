import Vapor
import App

let drop = try Droplet()
drop.get("*") { request in
	print(Date(), "private beta")
	return "The vapor hosted version of KulCal is currently in private beta."
}

drop.get("custom") { request in
	return drop.config["app", "custom"]?.string ?? "Custom config variable not defined"
}

if let privateKey = drop.config["keys", "damiaan"]?.string {
	print("private key", privateKey)
	drop.get("key", privateKey) { request in
		print("start private request")
		return createCalendar()
	}
} else {
	drop.get("key", "*") { request in
		return "Key not found. Make sure to set up a private key in the keys config file."
	}
}

print("Version 0.0.1")

try drop.run()
