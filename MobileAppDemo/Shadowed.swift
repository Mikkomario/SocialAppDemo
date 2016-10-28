//
//  Shadowed.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 28.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit

protocol Shadowed
{
	func setDefaultShadow()
}

extension Shadowed where Self: UIView
{
	func setDefaultShadow()
	{
		layer.shadowColor = SHADOW_GRAY.cgColor
		layer.shadowRadius = 4
		layer.shadowOpacity = 1
		layer.shadowOffset = CGSize(width: 2, height: 2)
	}
}
