//
//  Extensions.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 3.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation

extension Dictionary
{
	init(elements: [(Key, Value)])
	{
		self.init()
		for (key, value) in elements
		{
			updateValue(value, forKey: key)
		}
	}
}
