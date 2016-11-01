//
//  File.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 1.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation

struct User: Storable
{
	private let _uid: String
	
	var provider: String
	
	var id: String {return _uid}
	var properties: [String : Any] {return ["provider" : provider]}
	
	init(uid: String, provider: String)
	{
		self._uid = uid
		self.provider = provider
	}
}
