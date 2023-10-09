//
//  ViewController.swift
//  SocialLoginHelper
//
//  Created by theonetech on 29/09/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnGoogle: UIButton!
    @IBOutlet weak var btnApple: UIButton!
    @IBOutlet weak var btnBiomatric: UIButton!
    
    private let biometricIDAuth = BiometricLoginManager()
    
    @IBOutlet weak var textfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let myImage = UIImage(named: "my_image") {
            textfield.withImage(direction: .Right, image: myImage, colorSeparator: UIColor.clear, colorBorder: UIColor.black)
        }
    }

    @IBAction func btnFacebookAction(_ sender: UIButton) {
        
    }
    
    @IBAction func btnGoogleAction(_ sender: UIButton) {
        
    }
    
    @IBAction func btnBiomatricAction(_ sender: UIButton) {
        biometricIDAuth.canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                alert(title: "Error",
                      message: canEvaluateError?.localizedDescription ?? "Face ID/Touch ID may not be configured",
                      okActionTitle: "Darn!")
                return
            }
            
            biometricIDAuth.evaluate { [weak self] (success, error) in
                guard success else {
                    self?.alert(title: "Error",
                                message: error?.localizedDescription ?? "Face ID/Touch ID may not be configured",
                                okActionTitle: "Darn!")
                    return
                }
                
                self?.alert(title: "Success",
                            message: "You have a free pass, now",
                            okActionTitle: "Yay!")
            }
        }
    }
    
    @IBAction func btnAppleAction(_ sender: UIButton) {
        
    }
    
    
    
    func alert(title: String, message: String, okActionTitle: String) {
        let alertView = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: okActionTitle, style: .default)
        alertView.addAction(okAction)
        present(alertView, animated: true)
    }
    
}

extension UITextField {

    enum Direction {
        case Left
        case Right
    }

    // add image to textfield
    func withImage(direction: Direction, image: UIImage, colorSeparator: UIColor, colorBorder: UIColor){
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        mainView.layer.cornerRadius = 5
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
//        view.layer.borderWidth = CGFloat(0.5)
//        view.layer.borderColor = colorBorder.cgColor
        mainView.addSubview(view)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 12.0, y: 10.0, width: 24.0, height: 24.0)
        imageView.backgroundColor = UIColor.clear   
        view.addSubview(imageView)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = colorSeparator
        mainView.addSubview(seperatorView)
        
        if(Direction.Left == direction){ // image left
            seperatorView.frame = CGRect(x: 45, y: 0, width: 5, height: 45)
            self.leftViewMode = .always
            self.leftView = mainView
        } else { // image right
            seperatorView.frame = CGRect(x: 0, y: 0, width: 5, height: 45)
            self.rightViewMode = .always
            self.rightView = mainView
        }
        
        self.layer.borderColor = colorBorder.cgColor
        self.layer.borderWidth = CGFloat(0.5)
        self.layer.cornerRadius = 5
    }
    
}
