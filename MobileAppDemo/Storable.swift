//
//  Storable.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 1.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation

protocol Storable
{
	var id: String {get}
	var properties: [String : Any] {get}
}
