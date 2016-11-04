//
//  Post.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 1.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation
import SwiftyJSON
import FirebaseDatabase

final class Post: Storable
{
	static let parents = ["posts"]

	let id: String
	
	var caption: String
	var imageUrl: String
	var likes: Int

	private let clientCreated = NSDate()
	private var serverCreated: NSDate?
	var created: NSDate
	{
		if let serverCreated = serverCreated
		{
			return serverCreated
		}
		else
		{
			return clientCreated
		}
	}
	
	private var createdPropertyValue: Any
	{
		if let serverCreated = serverCreated
		{
			return serverCreated.timeIntervalSince1970
		}
		else
		{
			return FIRServerValue.timestamp()
		}
	}
	var properties: [String : Any] { return ["caption" : caption, "imageUrl" : imageUrl, "likes" : likes, "created" : createdPropertyValue] }
	
	init(id: String, caption: String, imageUrl: String, likes: Int = 0, createdOnServer created: NSDate? = nil)
	{
		self.id = id
		self.caption = caption
		self.imageUrl = imageUrl
		self.likes = likes
		self.serverCreated = created
	}
	
	// Creates a new instance by posting it to database
	static func post(caption: String, imageUrl: String, likes: Int = 0) -> Post
	{
		let reference = parentReference.childByAutoId()
		let post = Post(id: reference.key, caption: caption, imageUrl: imageUrl, likes: likes)
		reference.setValue(post.properties)
		
		// Updates the correct creation time as well
		post.getProperty(withName: "created")
		
		return post
	}
	
	// Creates a new instance from data read from database
	static func fromJSON(_ json: JSON, id: String) -> Post
	{
		let post = Post(id: id, caption: "", imageUrl: "")
		post.updateWithJSON(json)
		return post
	}
	
	func updateWithJSON(_ json: JSON)
	{
		if let caption = json["caption"].string
		{
			self.caption = caption
		}
		if let imageUrl = json["imageUrl"].string
		{
			self.imageUrl = imageUrl
		}
		if let likes = json["likes"].int
		{
			self.likes = likes
		}
		if let created = json["created"].double
		{
			self.serverCreated = NSDate(timeIntervalSince1970: created)
		}
	}
	
	func updateLikes() {updateProperty("likes")}
}
