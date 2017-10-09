//
//  main.swift
//  kullerPackageDescription
//
//  Created by Damiaan on 9/10/17.
//

import Vapor
import HTTP
import Foundation

public final class Follower: Middleware {
	
	public static let finalDestinationHeader: HeaderKey = "Final destination"
	
	public private(set) var lastClient: EngineClient?
	
	public init() {}

	public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
		let intermediateResponse = try next.respond(to: request)
		switch intermediateResponse.status {
		case .multipleChoices, .movedPermanently, .found, .seeOther, .useProxy, .switchProxy, .temporaryRedirect, .permanentRedirect:
			if let previousURL = URL(string: request.uri.description),
			   let relativeLocation = intermediateResponse.headers["location"],
			   let newURL = URL(string: relativeLocation, relativeTo: previousURL)
			{
				let newClient: EngineClient
				if let engine = lastClient, engine.client.hostname == newURL.host && engine.client.scheme == newURL.scheme {
					newClient = engine
				} else {
					print("⏺ spinning up new client")
					newClient = try EngineClient(
						     hostname: newURL.host!,
						         port: newURL.scheme == "https" ? 443 : 80,
						securityLayer: newURL.scheme == "https" ? .tls(EngineClient.defaultTLSContext()) : .none
					)
				}
				lastClient = newClient
				print("⏭ redirecting to", newURL.absoluteString)
				let finalResponse = try newClient.respond(to: Request(method: request.method, uri: newURL.absoluteString), through: [self])
				if (finalResponse.headers[Follower.finalDestinationHeader] == nil) {
					finalResponse.headers[Follower.finalDestinationHeader] = newURL.absoluteString
				}
				return finalResponse
			} else {
				return intermediateResponse
			}
		default:
			return intermediateResponse
		}
	}
}
