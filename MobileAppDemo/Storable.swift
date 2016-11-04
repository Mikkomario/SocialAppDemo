//
//  Storable.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 1.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

fileprivate let REF_BASE = FIRDatabase.database().reference()

protocol Storable
{
	var id: String {get}
	var properties: [String : Any] {get}
	// The parent entities for this item. Eg. ["posts"] or ["users", "someExampleCategory"]
	static var parents: [String] {get}
	
	// TODO: Could add a throws keyword here
	static func fromJSON(_ json: JSON, id: String) -> Self
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
	
	var reference: FIRDatabaseReference { get {return type(of: self).reference(forId: id)} }
	
	static func reference(forId id: String) -> FIRDatabaseReference
	{
		return parentReference.child(id)
	}
	
	func update() { reference.updateChildValues(properties) }
	
	func set() { reference.setValue(properties) }
	
	func updateProperty(_ propertyName: String)
	{
		reference.updateChildValues([propertyName : properties[propertyName]!])
	}
	
	func setProperty(_ propertyName: String)
	{
		reference.child(propertyName).setValue(properties[propertyName])
	}
	
	static func get(id: String, completion: @escaping (Self) -> ())
	{
		reference(forId: id).observeSingleEvent(of: .value, with:
		{
			snapshot in
			completion(fromJSON(JSON(snapshot.value), id: id))
		})
	}
	
	static func getList(completion: @escaping ([Self]) -> ())
	{
		parentReference.observeSingleEvent(of: .value, with:
		{
			snapshot in
			
			var items = [Self]()
			if let itemSnapshots = snapshot.children.allObjects as? [FIRDataSnapshot]
			{
				for snapshot in itemSnapshots
				{
					items.append(fromJSON(JSON(snapshot.value), id: snapshot.key))
				}
			}
			
			completion(items)
		})
	}
	
	static func observe(id: String, forEventsOfType eventType: FIRDataEventType = .value, calling handler: @escaping (Self) -> ()) -> FIRDatabaseHandle
	{
		let handle = reference(forId: id).observe(eventType, with:
		{
			snapshot in
			handler(fromJSON(JSON(snapshot.value), id: id))
		})
		
		return handle
	}
	
	static func stopObserver(ofId id: String, withHandle handle: FIRDatabaseHandle)
	{
		reference(forId: id).removeObserver(withHandle: handle)
	}
	
	static func observeList(forEventsOfType eventType: FIRDataEventType = .value, calling handler: @escaping ([Self]) -> ()) -> FIRDatabaseHandle
	{
		let handle = parentReference.observe(eventType, with:
		{
			snapshot in
			
			var items = [Self]()
			if let itemSnapshots = snapshot.children.allObjects as? [FIRDataSnapshot]
			{
				for snapshot in itemSnapshots
				{
					items.append(fromJSON(JSON(snapshot.value), id: snapshot.key))
				}
			}
			
			handler(items)
		})
		
		return handle
	}
	
	static func stopListObserver(withHandle handle: FIRDatabaseHandle)
	{
		parentReference.removeObserver(withHandle: handle)
	}
}
