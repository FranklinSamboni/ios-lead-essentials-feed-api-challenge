//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { response in
			switch response {
			case .success((let data, let httpResponse)):
				let json = try? JSONDecoder().decode(Payload.self, from: data)
				if httpResponse.statusCode != 200 || json == nil {
					completion(.failure(Error.invalidData))
				} else if let items = json {
					let feedImages: [FeedImage] = items.images.map { $0.feedImage }
					completion(.success(feedImages))
				} else {
					completion(.failure(Error.connectivity))
				}
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
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
}
