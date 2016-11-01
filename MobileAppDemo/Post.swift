//
//  Post.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 1.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation

struct Post: Storable
{
	static let parents = ["posts"]

	let id: String
	
	var caption: String
	var imageUrl: String
	var likes = 0
	
	var properties: [String : Any] { return ["caption" : caption, "imageUrl" : imageUrl, "likes" : likes] }
	
	init(id: String, caption: String, imageUrl: String, likes: Int = 0)
	{
		self.id = id
		self.caption = caption
		self.imageUrl = imageUrl
		self.likes = likes
	}
}
