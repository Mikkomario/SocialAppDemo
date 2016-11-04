//
//  Post.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 1.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation
import SwiftyJSON

final class Post: Storable
{
	static let parents = ["posts"]

	let id: String
	
	var caption: String
	var imageUrl: String
	var likes: Int
	
	var properties: [String : Any] { return ["caption" : caption, "imageUrl" : imageUrl, "likes" : likes] }
	
	init(id: String, caption: String, imageUrl: String, likes: Int = 0)
	{
		self.id = id
		self.caption = caption
		self.imageUrl = imageUrl
		self.likes = likes
	}
	
	// Creates a new instance by posting it to database
	static func post(caption: String, imageUrl: String, likes: Int = 0) -> Post
	{
		let reference = parentReference.childByAutoId()
		let post = Post(id: reference.key, caption: caption, imageUrl: imageUrl, likes: likes)
		reference.setValue(post.properties)
		
		return post
	}
	
	// Creates a new instance from data read from database
	static func fromJSON(_ json: JSON, id: String) -> Post
	{
		return Post(id: id, caption: json["caption"].stringValue, imageUrl: json["imageUrl"].stringValue, likes: json["likes"].intValue)
	}
	
	func updateLikes() {updateProperty("likes")}
}
