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
import SwiftKeychainWrapper

class SignInVC: UIViewController
{
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!

	override func viewDidLoad()
	{
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		if let _ = KeychainWrapper.standard.string(forKey: KEY_UID)
		{
			print("AUTH: USING EXISTING KEYCHAIN")
			performSegue(withIdentifier: "ToFeed", sender: nil)
		}
		else
		{
			print("AUTH: NO EXSTING KEYCHAIN")
		}
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func signInButtonPressed(_ sender: UIButton)
	{
		if let email = emailField.text, let password = passwordField.text
		{
			FIRAuth.auth()?.signIn(withEmail: email, password: password)
			{
				(user, error) in
				
				if let error = error
				{
					// TODO: Handle other errors here as well
					switch FIRAuthErrorCode(rawValue: error._code)!
					{
					case .errorCodeUserNotFound:
						print("AUTH: USER NOT FOUND -> CREATING NEW USER")
						FIRAuth.auth()?.createUser(withEmail: email, password: password)
						{
							(user, error) in
							
							if let error = error
							{
								print("AUTH: FAILED TO CREATE USER \(error)")
							}
							else
							{
								print("AUTH: SUCCESSFULLY CREATED NEW USER")
								self.completeLogin(user: user)
							}
						}
					default: print("AUTH: ERROR IN EMAIL LOGIN \(error)")
					}
				}
				else
				{
					print("AUTH: EMAIL AUTH SUCCESSFUL")
					self.completeLogin(user: user)
				}
			}
		}
		// TODO: Inform user that the field contents are missing
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
	
	fileprivate func firebaseAuth(_ credential: FIRAuthCredential)
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
				self.completeLogin(user: user)
			}
		}
	}
	
	private func completeLogin(user: FIRUser?)
	{
		if let user = user
		{
			if KeychainWrapper.standard.set(user.uid, forKey: KEY_UID)
			{
				print("AUTH: UID SAVED TO KEYCHAIN")
			}
			else
			{
				print("AUTH: FAILED TO SAVE UID TO KEYCHAIN")
			}
		}
		performSegue(withIdentifier: "ToFeed", sender: nil)
	}
}

