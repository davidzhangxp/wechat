import UIKit
import FirebaseAuth
import ProgressHUD


class LoginViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
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
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login ", for: .normal)
        button.backgroundColor = .systemRed
        return button
    }()

    private let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot password ", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.link, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .light)
        button.contentHorizontalAlignment = .left
        return button
    }()
    private let signupLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.text = "You don't have an account"
        return label
    }()
    private let signupButton: UIButton = {
        let button = UIButton()
        button.setTitle("Signup ", for: .normal)
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
        passwordField.delegate = self
 
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonPressed), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        setupBackgroundTouch()

    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds

        emailField.frame = CGRect(x: 20,
                                  y: 60,
                                  width: view.width - 40,
                                  height: 42)
        lineView.frame = CGRect(x: 20, y: emailField.bottom, width: view.width - 40, height: 2)
        passwordField.frame = CGRect(x: 20,
                                     y: emailField.bottom + 20,
                                     width: view.frame.size.width - 60,
                                     height: 42)
        lineView2.frame = CGRect(x: 20, y: passwordField.bottom, width: view.width - 40, height: 2)
        loginButton.frame = CGRect(x: 20,
                                     y: passwordField.bottom + 40,
                                     width: view.width - 40,
                                     height: 42)
        forgotPasswordButton.frame = CGRect(x: 20,
                                            y: loginButton.bottom + 20,
                                     width: view.frame.size.width/2,
                                     height: 42)
        signupLabel.frame = CGRect(x: 20, y: view.height - 80, width: view.width - 180, height: 28)
        
        signupButton.frame = CGRect(x: signupLabel.right + 5, y: view.height - 80, width: 80, height: 28)
        
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: signupLabel.bottom + 30)
        
    }
    //MARK:- SetupView
    
    private func setupViewElements(){
        title = "Login"
        view.backgroundColor = .white
        view.clipsToBounds = true
        //add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(lineView)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(lineView2)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(forgotPasswordButton)
        scrollView.addSubview(signupLabel)
        scrollView.addSubview(signupButton)
        Utilities.styleTextField(emailField)
        Utilities.styleTextField(passwordField)
        Utilities.styleLoginButton(loginButton)
    }
    
    //MARK:-Functions
      @objc private func loginButtonTapped(){
          emailField.resignFirstResponder()
          passwordField.resignFirstResponder()
          guard  let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty else {
              //alert
              alertUserLoginError(with: "Please enter all fields")
              return
          }
 
          //user login
        if emailField.text != "" && passwordField.text != "" {
            ProgressHUD.show()
            FUser.loginUserWith(email: emailField.text!, password: passwordField.text!) { (error, isEmailVerified) in
                if error == nil{
//                    if isEmailVerified{
                        //login
                        self.gotoApp()
                        ProgressHUD.showSuccess("login")
//                    }else{
//                        ProgressHUD.showError("Please verify email")
//                    }
                }else{
                    ProgressHUD.showError(error!.localizedDescription)
                }
            }
        }else{
            ProgressHUD.showError("All fielfs are required")
        }
      }
    
    @objc func forgotPasswordButtonPressed(_ sender: Any) {
        if emailField.text != ""{
            FUser.resetPasswordFor(email: emailField.text!) { (error) in
                if error == nil{
                    ProgressHUD.showSuccess("Email has sent")
                }else{
                    ProgressHUD.showError(error!.localizedDescription)
                }
            }
        }else{
            ProgressHUD.showError("Please fill in your email")
        }
    }
    
      private func alertUserLoginError(with message:String){
          let alert = UIAlertController(title: "Error", message:message , preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
          present(alert, animated: true, completion: nil)
      }
      
      @objc func didTapRegister(){
          let vc = RegisterViewController()
          vc.title = "Register"
//        present(vc, animated: true, completion: nil)
          navigationController?.pushViewController(vc, animated: true)
      }
      
      private func setupBackgroundTouch(){
          scrollView.isUserInteractionEnabled = true
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
          scrollView.addGestureRecognizer(tapGesture)
      }
      
      @objc func backgroundTap(){
          self.view.endEditing(false)
      }

    private func gotoApp(){
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "mainView") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }

}
extension LoginViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}


