//
//  File.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 1.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftKeychainWrapper
import FirebaseDatabase

final class User: Storable
{
	static let parents = ["users"]
	
	private static var currentListeningTask: ObserveTask?
	
	var provider: String
	var userName: String
	var imageUrl: String?
	var likedPostIds = [String]()
	
	let id: String
	var properties: [String : Any]
	{
		let likes = Dictionary(elements: likedPostIds.map({(postId) in (postId, true)})) as NSDictionary
		var dict = ["provider" : provider, "userName" : userName, "likes" : likes] as [String : Any]
		if let imageUrl = imageUrl
		{
			dict["imageUrl"] = imageUrl
		}
		return dict
	}
	
	private static var _currentUser: User?
	static var currentUser: User?
	{
		get {return _currentUser}
		set {currentUserId = newValue?.id}
	}
	
	static var currentUserId: String?
	{
		get
		{
			if let currentUser = currentUser
			{
				return currentUser.id
			}
			else
			{
				return KeychainWrapper.standard.string(forKey: KEY_UID)
			}
		}
		set
		{
			// Stops previous user tracking (if applicable)
			if let currentListeningTask = currentListeningTask
			{
				currentListeningTask.stop()
				self.currentListeningTask = nil
			}
			
			if let uid = newValue
			{
				KeychainWrapper.standard.set(uid, forKey: KEY_UID)
				
				// Starts new user tracking (if applicable)
				startUserTracking(forId: uid)
			}
			else
			{
				KeychainWrapper.standard.removeObject(forKey: KEY_UID)
				_currentUser = nil
			}
		}
	}
	
	static var currentUserReference: FIRDatabaseReference?
	{
		if let currentUserId = currentUserId
		{
			return parentReference.child(currentUserId)
		}
		else
		{
			return nil
		}
	}
	
	init(uid: String, provider: String, userName: String, imageUrl: String? = nil)
	{
		self.id = uid
		self.provider = provider
		self.userName = userName
		self.imageUrl = imageUrl
	}
	
	static func create(from json: JSON, withId id: String) -> User
	{
		let user = User(uid: id, provider: "", userName: "")
		user.update(with: json)
		return user
	}
	
	static func post(uid: String, provider: String, userName: String, image: UIImage? = nil, completionHandler: @escaping (User) -> ())
	{
		func imagePosted(url: String?)
		{
			let user = User(uid: uid, provider: provider, userName: userName, imageUrl: url)
			user.push(overwrite: true)
			completionHandler(user)
		}
		
		// May need to post the image to storage first
		if let image = image
		{
			Storage.upload(image: image, to: Storage.REF_USER_IMAGES)
			{
				(url, error) in
				
				if let _ = url
				{
					print("STORAGE: User image posted")
				}
				if let error = error
				{
					print("STORAGE: Error. Couldn't save user image. \(error)")
				}
				
				imagePosted(url: url)
			}
		}
		else
		{
			imagePosted(url: nil)
		}
	}
	
	func update(with json: JSON)
	{
		if let provider = json["provider"].string
		{
			self.provider = provider
		}
		if let likeDict = json["likes"].dictionary
		{
			likedPostIds = likeDict.map() { (key, value) in key }
		}
		if let userName = json["userName"].string
		{
			self.userName = userName
		}
		if let imageUrl = json["imageUrl"].string
		{
			self.imageUrl = imageUrl
		}
	}
	
	func likes(post: Post) -> Bool {return likedPostIds.contains(post.id)}
	
	func like(post: Post)
	{
		if !likes(post: post)
		{
			likedPostIds.append(post.id)
		}
	}
	
	func unlike(post: Post)
	{
		likedPostIds = likedPostIds.filter({$0 != post.id})
	}
	
	func pushLikes() {pushProperty("likes")}
	
	static func startTrackingCurrentUser()
	{
		if let userId = currentUserId
		{
			startUserTracking(forId: userId)
		}
	}
	
	private static func startUserTracking(forId id: String)
	{
		if currentListeningTask == nil || !currentListeningTask!.isActive
		{
			currentListeningTask = User.observe(id: id)
			{
				user in
				_currentUser = user
			}
		}
	}
}
