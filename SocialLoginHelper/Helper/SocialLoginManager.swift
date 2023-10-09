//
//  SocialLoginManager.swift
//  XCite
//
//  Created by Theonetech on 31/10/22.
//

import Foundation
import AuthenticationServices
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit

enum SocialLoginType: String {
    case Apple = "a"
    case Google = "g"
    case Facebook = "f"
    case None = "n"
}

protocol SocialLoginManagerDelegate {
    func socialSignupApple(socialType: String, token: String, email: String, firstName: String, lastName: String, googleClientId: String)
}

class SocialLoginManager: NSObject {
    static let shared = SocialLoginManager()
    
    var delegate: SocialLoginManagerDelegate? = nil
    
    override init() {
        super.init()
    }
    
    func appleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func googleLogin(vc: UIViewController) {
        GIDSignIn.sharedInstance().clientID = Environment.googleClientId
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().restorePreviousSignIn()
        
        GIDSignIn.sharedInstance()?.presentingViewController = vc
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func googleLogout() {
        GIDSignIn.sharedInstance().signOut()
    }

}

//MARK:- Facebook login

extension SocialLoginManager {
    func signInWithFacebook(viewController: UIViewController) {
        let manager = LoginManager()
        manager.logIn(permissions: [.publicProfile , .email], viewController: viewController) { loginResult in
            switch loginResult {
            case .failed(let error):
                print("failed", error)
                break
            case .cancelled:
                break
            case .success( _, _, _):
                let connection = GraphRequestConnection()
                let request = GraphRequest.init(graphPath: "me")
                request.parameters = ["fields":"email,first_name,last_name,picture.width(1000).height(1000),birthday,gender"]
                connection.add(request, completionHandler: {
                    (response, result , error) in
                    if let res = result {
                        debugPrint(res)
                        if let response = res as? [String: String] {
                            let email = response["email"]
                            let firstName = response["first_name"]
                            let lastName = response["last_name"]
                            self.delegate?.socialSignupApple(socialType: SocialLoginType.Facebook.rawValue, token: AccessToken.current?.tokenString ?? "", email: email ?? "", firstName: firstName ?? "", lastName: lastName ?? "", googleClientId: "")
                        }
                    }
                })
                connection.start()
            }
        }
    }
}


//MARK:- apple
extension SocialLoginManager : ASAuthorizationControllerDelegate , ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = AppDelegate.shared().window else {
            return UIWindow()
        }
        return window
    }
    
    private func performExistingAccountSetupFlows() {
        let requests = [ASAuthorizationAppleIDProvider().createRequest(), ASAuthorizationPasswordProvider().createRequest()]
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    // ASAuthorizationControllerDelegate function for successful authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let firstName =  "\(appleIDCredential.fullName?.givenName ?? "")"
            let lastName =  "\(appleIDCredential.fullName?.familyName ?? "")"
            let email = appleIDCredential.email ?? ""
            delegate?.socialSignupApple(socialType: SocialLoginType.Apple.rawValue, token: appleIDCredential.user, email: email,firstName: firstName, lastName: lastName, googleClientId: "")
            //API call
        } else if authorization.credential is ASPasswordCredential {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let firstName =  "\(appleIDCredential.fullName?.givenName ?? "")"
                let lastName =  "\(appleIDCredential.fullName?.familyName ?? "")"
                let email = appleIDCredential.email ?? ""
                delegate?.socialSignupApple(socialType: SocialLoginType.Apple.rawValue, token: appleIDCredential.user, email: email,firstName: firstName, lastName: lastName, googleClientId: "")
            }
        }
    }
    
}

//MARK:- google

extension SocialLoginManager : GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                debugPrint("The user has not signed in before or they have since signed out.")
            } else {
                debugPrint("\(error.localizedDescription)")
            }
            return
        } else if (user != nil){
            let userAuthentication = user.authentication.accessToken ?? ""
            let clientId = user.authentication.clientID ?? ""
            let firstName =  "\(user.profile.givenName ?? "")"
            let lastName =  "\(user.profile.familyName ?? "")"
            let email = user.profile.email ?? ""
            debugPrint("access token = \(userAuthentication)")
            delegate?.socialSignupApple(socialType: SocialLoginType.Google.rawValue, token: userAuthentication, email: email,firstName: firstName, lastName: lastName, googleClientId: clientId)        }
        else{
            
        }
    }
    
}
