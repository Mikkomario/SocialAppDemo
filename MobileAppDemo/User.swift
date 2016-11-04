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
	
	private static var currentUserListeningHandle: FIRDatabaseHandle?
	
	var provider: String
	var likedPostIds = [String]()
	
	let id: String
	var properties: [String : Any]
	{
		let likes = Dictionary(elements: likedPostIds.map({(postId) in (postId, true)})) as NSDictionary
		return ["provider" : provider, "likes" : likes]
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
			if let handle = currentUserListeningHandle, let userId = currentUserId
			{
				User.stopObserver(ofId: userId, withHandle: handle)
				currentUserListeningHandle = nil
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
	
	init(uid: String, provider: String)
	{
		self.id = uid
		self.provider = provider
	}
	
	static func create(from json: JSON, withId id: String) -> User
	{
		let user = User(uid: id, provider: "")
		user.update(with: json)
		return user
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
		if currentUserListeningHandle == nil
		{
			currentUserListeningHandle = User.observe(id: id)
			{
				user in
				_currentUser = user
			}
		}
	}
}
