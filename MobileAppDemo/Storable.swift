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
	
	// Updates the item's status based on JSON data
	func update(with json: JSON)
	
	// The parent entities for this item. Eg. ["posts"] or ["users", "someExampleCategory"]
	static var parents: [String] {get}
	
	// TODO: Could add a throws keyword here
	static func create(from json: JSON, withId id: String) -> Self
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
	
	func push(overwrite: Bool = false)
	{
		if overwrite
		{
			reference.setValue(properties)
		}
		else
		{
			reference.updateChildValues(properties)
		}
	}
	
	func pushProperty(_ propertyName: String)
	{
		reference.child(propertyName).setValue(properties[propertyName])
	}
	
	// Gets the latest state of the storable instance from the database. The instance status is updated and 
	// completion is called afterwards
	func update(completion: ((Self) -> ())? = nil)
	{
		reference.observeSingleEvent(of: .value, with:
		{
			snapshot in
			
			self.update(with: JSON(snapshot.value))
			completion?(self)
		})
	}
	
	func update(with snapshot: FIRDataSnapshot) {update(with: JSON(snapshot.value))}
	
	func updateProperty(withName propertyName: String, completion: ((Self) -> ())? = nil)
	{
		reference.child(propertyName).observeSingleEvent(of: .value, with:
		{
			snapshot in
			
			self.update(with: snapshot)
			completion?(self)
		})
	}
	
	static func get(id: String, completion: @escaping (Self) -> ())
	{
		reference(forId: id).observeSingleEvent(of: .value, with:
		{
			snapshot in
			completion(create(from: snapshot))
		})
	}
	
	static func getList(completion: @escaping ([Self]) -> ())
	{
		parentReference.observeSingleEvent(of: .value, with:
		{
			snapshot in
			completion(createList(from: snapshot))
		})
	}
	
	static func observe(id: String, forEventsOfType eventType: FIRDataEventType = .value, calling handler: @escaping (Self) -> ()) -> FIRDatabaseHandle
	{
		let handle = reference(forId: id).observe(eventType, with:
		{
			snapshot in
			handler(create(from: snapshot))
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
			handler(createList(from: snapshot))
		})
		
		return handle
	}
	
	static func stopListObserver(withHandle handle: FIRDatabaseHandle)
	{
		parentReference.removeObserver(withHandle: handle)
	}
	
	static func createList(from snapshot: FIRDataSnapshot) -> [Self]
	{
		var items = [Self]()
		if let itemSnapshots = snapshot.children.allObjects as? [FIRDataSnapshot]
		{
			for snapshot in itemSnapshots
			{
				items.append(create(from: snapshot))
			}
		}
		
		return items
	}
	
	static func create(from snapshot: FIRDataSnapshot) -> Self
	{
		return create(from: JSON(snapshot.value), withId: snapshot.key)
	}
}
