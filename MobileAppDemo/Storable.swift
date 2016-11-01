//
//  Storable.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 1.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation
import FirebaseDatabase

let REF_BASE = FIRDatabase.database().reference()

protocol Storable
{
	var id: String {get}
	var properties: [String : Any] {get}
	// The parent entities for this item. Eg. ["posts"] or ["users", "someExampleCategory"]
	static var parents: [String] {get}
}

extension Storable
{
	static var parentReference: FIRDatabaseReference
	{
		get
		{
			var parentRef = REF_BASE
			for part in parents
			{
				parentRef = parentRef.child(part)
			}
			
			return parentRef
		}
	}
	
	var reference: FIRDatabaseReference { get {return type(of: self).parentReference.child(id)} }
	
	func update() { reference.updateChildValues(properties) }
}
