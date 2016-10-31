//
//  ViewController.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 27.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class SignInVC: UIViewController
{

	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func facebookButtonPressed(_ sender: UIButton)
	{
		let facebookLogin = FBSDKLoginManager()
		facebookLogin.logIn(withReadPermissions: ["email"], from: self)
		{
			(result, error) in
			
			if let error = error
			{
				print("AUTH: UNABLE TO AUTHENTICATE WITH FACEBOOK")
				print("AUTH: \(error)")
			}
			else if let result = result
			{
				if result.isCancelled
				{
					print("AUTH: USER CANCELLED FACEBOOK AUTH")
				}
				else
				{
					print("AUTH: FACEBOOK AUTH SUCCESS")
					let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
					self.firebaseAuth(credential)
				}
			}
		}
	}
	
	private func firebaseAuth(_ credential: FIRAuthCredential)
	{
		FIRAuth.auth()?.signIn(with: credential)
		{
			(user, error) in
			
			if let error = error
			{
				print("AUTH: UNABLE TO AUTHENTICATE TO FIREBASE")
				print("AUTH: \(error)")
			}
			else
			{
				print("AUTH: SUCCESSFULLY AUTHENTICATED WITH FIREBASE")
			}
		}
		
		/*
		FIRAuth.signIn(with: credential, completion:
		{
			(user, error) in
			
			
			
		})
*/
	}
}

