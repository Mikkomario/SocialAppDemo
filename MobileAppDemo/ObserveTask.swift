//
//  ObservingStopper.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 4.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ObserveTask
{
	let ref: FIRDatabaseQuery
	let handle: FIRDatabaseHandle
	
	private var _isActive = true
	var isActive: Bool {return _isActive}
	
	init(ref: FIRDatabaseQuery, handle: FIRDatabaseHandle)
	{
		self.ref = ref
		self.handle = handle
	}
	
	func stop()
	{
		if isActive
		{
			_isActive = false
			ref.removeObserver(withHandle: handle)
		}
	}
}
