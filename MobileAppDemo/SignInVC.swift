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

fileprivate struct RegisterInfo
{
	let email: String
	let password: String
}

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
		if User.currentUserId != nil
		{
			print("AUTH: USING EXISTING KEYCHAIN")
			User.startTrackingCurrentUser()
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
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		print("AUTH: Preparing for segue \(segue.identifier)")
		
		if let registrationVC = segue.destination as? RegisterVC
		{
			print("AUTH: Found registration VC")
			
			if let info = sender as? RegisterInfo
			{
				print("AUTH: Sending email (\(info.email)) and password (\(info.password.characters.count) chars) information: ")
				registrationVC.setBaseInfo(email: info.email, password: info.password)
			}
		}
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
						print("AUTH: Sending email \(email) and password \(password.characters.count) characters")
						self.performSegue(withIdentifier: "RegisterUser", sender: RegisterInfo(email: email, password: password))
						/*
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
						}*/
					default: print("AUTH: ERROR IN EMAIL LOGIN \(error)") // TODO: Inform user
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
		// (Already logged in to FB)
		if let fbAccessToken = FBSDKAccessToken.current()
		{
			print("AUTH: Already logged in to FB")
			firebaseAuth(with: FIRFacebookAuthProvider.credential(withAccessToken: fbAccessToken.tokenString))
		}
		else
		{
			let facebookLogin = FBSDKLoginManager()
			facebookLogin.logIn(withReadPermissions: ["public_profile", "email"], from: self)
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
						self.firebaseAuth(with: credential)
					}
				}
			}
		}
	}
	
	fileprivate func firebaseAuth(with credential: FIRAuthCredential)
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
				if let user = user
				{
					print("AUTH: SUCCESSFULLY AUTHENTICATED WITH FIREBASE")
					
					// Updates current user data
					var userName = "User"
					var image: UIImage?
					
					if let retrievedName = user.displayName
					{
						userName = retrievedName
					}
					if let retrievedImageUrl = user.photoURL
					{
						if let data = try? Data(contentsOf: retrievedImageUrl)
						{
							image = UIImage(data: data)
						}
					}
					
					User.post(uid: user.uid, provider: user.providerID, userName: userName, image: image)
					{
						user in
						
						User.currentUser = user
						User.startTrackingCurrentUser()
						
						self.performSegue(withIdentifier: "ToFeed", sender: nil)
					}
				}
			}
		}
	}
	
	private func completeLogin(user: FIRUser?)
	{
		if let user = user
		{
			// TODO: FIX THIS
			let currentUser = User(uid: user.uid, provider: user.providerID, userName: "", imageUrl: "")
			currentUser.update()
			
			User.currentUserId = currentUser.id
			User.startTrackingCurrentUser()
			// TODO: It would appear one wants to use credential.provider instead. Let's see if it makes any difference first
			
		}
		performSegue(withIdentifier: "ToFeed", sender: nil)
	}
}

