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
	
	static func get(from query: FIRDatabaseQuery, completion: @escaping (Self) -> ())
	{
		query.observeSingleEvent(of: .value, with:
		{
			snapshot in
			completion(create(from: snapshot))
		})
	}
	
	static func get(id: String, completion: @escaping (Self) -> ())
	{
		get(from: reference(forId: id), completion: completion)
	}
	
	static func getList(from query: FIRDatabaseQuery, completion: @escaping ([Self]) -> ())
	{
		query.observeSingleEvent(of: .value, with:
		{
			snapshot in
			completion(createList(from: snapshot))
		})
	}
	
	static func getList(completion: @escaping ([Self]) -> ())
	{
		getList(from: parentReference, completion: completion)
	}
	
	static func observe(from query: FIRDatabaseQuery, forEventsOfType eventType: FIRDataEventType = .value, calling handler: @escaping (Self) -> ()) -> ObserveTask
	{
		let handle = query.observe(eventType, with:
			{
				snapshot in
				handler(create(from: snapshot))
		})
		
		return ObserveTask(ref: query, handle: handle)
	}
	
	static func observe(id: String, forEventsOfType eventType: FIRDataEventType = .value, calling handler: @escaping (Self) -> ()) -> ObserveTask
	{
		return observe(from: reference(forId: id), calling: handler)
	}
	
	static func observeList(from query: FIRDatabaseQuery, forEventsOfType eventType: FIRDataEventType = .value, calling handler: @escaping ([Self]) -> ()) -> ObserveTask
	{
		let handle = query.observe(eventType, with:
		{
			snapshot in
			handler(createList(from: snapshot))
		})
		
		return ObserveTask(ref: query, handle: handle)
	}
	
	static func observeList(forEventsOfType eventType: FIRDataEventType = .value, calling handler: @escaping ([Self]) -> ()) -> ObserveTask
	{
		return observeList(from: parentReference, forEventsOfType: eventType, calling: handler)
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
