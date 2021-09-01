//
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

class FeedImageMapper {
	static let HTTP_200 = 200

	static func map(_ data: Data, with httpResponse: HTTPURLResponse) throws -> [FeedImage] {
		guard httpResponse.statusCode == HTTP_200 else {
			throw RemoteFeedLoader.Error.invalidData
		}

		return try map(data)
	}

	static func map(_ data: Data) throws -> [FeedImage] {
		let paylaod = try JSONDecoder().decode(Payload.self, from: data)
		return paylaod.images.map { $0.feedImage }
	}

	private struct Payload: Decodable {
		let images: [Image]

		enum CodingKeys: String, CodingKey {
			case images = "items"
		}
	}

	private struct Image: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		var feedImage: FeedImage {
			return FeedImage(id: id,
			                 description: description,
			                 location: location,
			                 url: url)
		}

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}

	private init() {}
}
