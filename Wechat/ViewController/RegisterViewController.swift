//
//  RegisterViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/25/20.
//

import UIKit

class RegisterViewController: UIViewController {


    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    private let userNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "user name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()
    private let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        return field
    }()
    private let lineView3: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    private let passwordField2: UITextField = {
        let field = UITextField()
        field.placeholder = "Password confirm"
        field.isSecureTextEntry = true
        return field
    }()
    private let lineView4: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        return button
    }()

    private let loginLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.text = "You already have an account"
        return label
    }()
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("SignIn", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.link, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewElements()
        emailField.delegate = self
        userNameField.delegate = self
        passwordField.delegate = self
        passwordField2.delegate = self
        setupBackgroundTouch()

        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)

    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        userNameField.frame = CGRect(x: 20,
                                  y: 60,
                                  width: view.width - 40,
                                  height: 42)
        lineView.frame = CGRect(x: 20, y: userNameField.bottom, width: view.width - 40, height: 2)
        emailField.frame = CGRect(x: 20,
                                  y: userNameField.bottom + 20,
                                  width: view.width - 40,
                                  height: 42)
        lineView2.frame = CGRect(x: 20, y: emailField.bottom, width: view.width - 40, height: 2)
        passwordField.frame = CGRect(x: 20,
                                     y: emailField.bottom + 20,
                                     width: view.frame.size.width - 60,
                                     height: 42)
        lineView3.frame = CGRect(x: 20, y: passwordField.bottom, width: view.width - 40, height: 2)
        passwordField2.frame = CGRect(x: 20,
                                     y: passwordField.bottom + 20,
                                     width: view.frame.size.width - 60,
                                     height: 42)
        lineView4.frame = CGRect(x: 20, y: passwordField2.bottom, width: view.width - 40, height: 2)
        registerButton.frame = CGRect(x: 20,
                                     y: passwordField2.bottom + 40,
                                     width: view.width - 40,
                                     height: 42)
       
        loginLabel.frame = CGRect(x: 20, y: view.height - 80, width: view.width - 180, height: 28)
        
        loginButton.frame = CGRect(x: loginLabel.right + 5, y: view.height - 80, width: 80, height: 28)
        
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: loginLabel.bottom + 30)
        
    }
    //MARK:- SetupView
    
    private func setupViewElements(){
        title = "Register"
        view.backgroundColor = .white
        //add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(userNameField)
        scrollView.addSubview(lineView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(lineView2)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(lineView3)
        scrollView.addSubview(passwordField2)
        scrollView.addSubview(lineView4)
        scrollView.addSubview(registerButton)
        scrollView.addSubview(loginLabel)
        scrollView.addSubview(loginButton)
        Utilities.styleTextField(userNameField)
        Utilities.styleTextField(emailField)
        Utilities.styleTextField(passwordField)
        Utilities.styleTextField(passwordField2)
        Utilities.styleLoginButton(registerButton)
    }
    
    //MARK:-Fuctions
    @objc private func registerButtonTapped(){
        userNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        passwordField2.resignFirstResponder()
        if passwordField2.text != passwordField.text {
            alertUserLoginError(with: "Check your Password")
            return
        }
        guard  let email = emailField.text,
               let username = userNameField.text,
               let password = passwordField.text,
               !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            //alert
            alertUserLoginError(with: "Please fill in all fields")
            return
        }
        
        //user login
        FUser.registerUserWith(email: emailField.text!, password: passwordField.text!, userName: userNameField.text!) { (error) in
            
            if error == nil{
                //                ProgressHUD.showSuccess("Verification email sent!")
                let loginView = LoginViewController()
                let nav = UINavigationController(rootViewController: loginView)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }else{
                //                ProgressHUD.showError(error!.localizedDescription)
            }
            
        }
    }
    @objc private func loginButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
    //MARK:- Alert
    private func alertUserLoginError(with message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }


    
    //MARK:- InteractionEnabled
    

    private func setupBackgroundTouch(){
        scrollView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        scrollView.addGestureRecognizer(tapGesture)
    }

    @objc func backgroundTap(){
        self.view.endEditing(false)
    }
  
    
}

//MARK:- Extensions
extension RegisterViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        }else if textField == passwordField {
            passwordField2.becomeFirstResponder()
        }else if textField == passwordField2 {
            registerButtonTapped()
        }
        return true
    }
    
}
