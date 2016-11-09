//
//  RegisterVC.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 9.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController
{
	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var confirmPasswordField: UITextField!
	
	var email = ""
	var password = ""
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		emailField.text = email
		passwordField.text = password
    }

	@IBAction func RegisterBtnPressed(_ sender: AnyObject) {
	}
	@IBAction func cancelBtnPressed(_ sender: AnyObject) {
	}

	func setBaseInfo(email: String, password: String)
	{
		self.email = email
		self.password = password
	}
}
