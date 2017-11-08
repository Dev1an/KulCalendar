import Vapor
import App

var count: UInt = 0

let drop = try Droplet()
drop.get("*") { request in
	print(Date(), "private beta")
	return "The vapor hosted version of KulCal is currently in private beta.\ncrawled \(count) times"
}

drop.get("custom") { request in
	return drop.config["app", "custom"]?.string ?? "Custom config variable not defined"
}

drop.get("debug") { request in
	print("start debug task")
	
	return debugCalendar()
}

if let privateKey = drop.config["keys", "damiaan"]?.string {
	print("private key", privateKey)
	drop.get("key", privateKey) { request in
		print("start private request")
		let calendar = createCalendar()
		count += 1
		return calendar
	}
} else {
	drop.get("key", "*") { request in
		return "Key not found. Make sure to set up a private key in the keys config file."
	}
}

print("Version 0.0.1")

try drop.run()
