//
//  DataService.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 1.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase


@available(*, deprecated, message: "Use Storable interface instead")
class DataService
{
	static let instance = DataService()
	
	let REF_BASE = FIRDatabase.database().reference()
	
	//var REF_POSTS: FIRDatabaseReference {return REF_BASE.child("posts")}
	//var REF_USERS: FIRDatabaseReference {return REF_BASE.child("users")}
	
	// Hidden initializer
	private init() {}
	
	func updateItem(_ item: Storable)
	{
		item.reference.updateChildValues(item.properties)
	}
}
