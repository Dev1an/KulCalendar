//
//  ScheduleLoader.swift
//  testjePackageDescription
//
//  Created by Damiaan on 9/10/17.
//

import Vapor
import Kanna
import Foundation

public final class ScheduleLoader: Middleware {
	public static let shared = ScheduleLoader()
	
	public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
		let intermediateResponse = try next.respond(to: request)
		if let bytes = intermediateResponse.body.bytes {
			let html = try HTML(html: Data(bytes: bytes), encoding: .utf8)
			let inputQuery = html.xpath("//form[@name='ladenform' or @name='continueform']/input")
			if inputQuery.count > 0 {
				let inputs = inputQuery.makeIterator()
				var body = try Node(node: [String:String]())
				for input in inputs {
					try body.set(input["name"]!, input["value"])
				}
				
				let lastURI = intermediateResponse.headers[Follower.finalDestinationHeader] ?? request.uri.description
				
				let post = Request(method: .get, uri: lastURI)
				post.formURLEncoded = body
				print("🔄 posting loading form")
				let result = try next.respond(to: post, through: [self])
				return result
			}
		}
		return intermediateResponse
	}
}
