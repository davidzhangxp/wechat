import UIKit
import FirebaseAuth
import Gallery
import ProgressHUD
import JGProgressHUD

class ProfileViewController: UIViewController {

    private let scrollView :UIScrollView = {
        let view = UIScrollView()
        view.frame = view.bounds
        view.clipsToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .systemGray5
        return view
    }()
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.gray.cgColor
        return imageView
    }()
    private let userIdLabel:UILabel = {
        let label = UILabel()
        label.text = "userId"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    private let nameLabel:UILabel = {
        let label = UILabel()
        label.text = "usename"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    private let countryCityLabel:UILabel = {
        let label = UILabel()
        label.text = "Country/City"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    private let cameraButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "camera.fill")

        button.tintColor = .white
        button.layer.masksToBounds = true
        button.setBackgroundImage(image, for: .normal)
        return button
    }()
    
    private let settingButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "gearshape")

        button.tintColor = .white
        button.layer.masksToBounds = true
        button.setBackgroundImage(image, for: .normal)
        return button
    }()
    private let editeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "square.and.pencil")

        button.tintColor = .white
        button.layer.masksToBounds = true
        button.setBackgroundImage(image, for: .normal)
        return button
    }()
    
    private let informationLabel:UILabel = {
        let label = UILabel()
        label.text = "Information"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .medium)
        return label
    }()

    private let genderLabel:UILabel = {
        let label = UILabel()
        label.text = "Gender:"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    private let genderField: UITextField = {
        let field = UITextField()
        field.returnKeyType = .continue
        field.placeholder = "Male or Female"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()
    private let countryLabel:UILabel = {
        let label = UILabel()
        label.text = "Country"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let countryField: UITextField = {
        let field = UITextField()
        field.returnKeyType = .continue
        field.placeholder = "country"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()
    private let cityLabel:UILabel = {
        let label = UILabel()
        label.text = "City:"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    private let cityField: UITextField = {
        let field = UITextField()
        field.returnKeyType = .continue
        field.placeholder = "city"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()
    private let dateOfBirthLabel:UILabel = {
        let label = UILabel()
        label.text = "Birthday:"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let dateOfBirthField: UITextField = {
        let field = UITextField()
        field.returnKeyType = .continue
        field.placeholder = "birthday"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()

    private let jobLabel:UILabel = {
        let label = UILabel()
        label.text = "Job:"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    private let jobField: UITextField = {
        let field = UITextField()
        field.returnKeyType = .continue
        field.placeholder = "Job title"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()

    private let aboutLabel:UILabel = {
        let label = UILabel()
        label.text = "About"
        label.layer.masksToBounds = true
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .medium)
        return label
    }()

    private let aboutTextView: UITextView = {
        let field = UITextView()
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.text = "User information"
        field.backgroundColor = .white
        return field
    }()

    
    var editingMode = false
    var avatarImage : UIImage?
    var alertTextField : UITextField!
    var gallery: GalleryController!
    var itemImages: [UIImage?] = []
    let datePicker = UIDatePicker()

    var genderPickerView: UIPickerView!
    var genderOptions = ["Male","Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        
        validateAuth()
        
        setupBackgroundTouch()
        setupPickerView()
        editeButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(showSettingOptions), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(showCameraGallery), for: .touchUpInside)
        
        setupDatePicker()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            loadUserData()
            updateEditingMode()
  
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        backgroundView.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: 320)
        backgroundView.layer.cornerRadius = 88
        backgroundView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        imageView.frame = CGRect(x: view.width/2 - view.width/6, y: 30, width: view.width/3, height: view.width/3)
        imageView.layer.cornerRadius = view.width/6
        userIdLabel.frame = CGRect(x: 20, y: imageView.bottom + 5, width: view.width - 40, height: 25)
        nameLabel.frame = CGRect(x: view.width/2 - view.width/6, y: userIdLabel.bottom + 5, width: view.width/3, height: 25)
        countryCityLabel.frame = CGRect(x: view.width/2 - view.width/6, y: nameLabel.bottom + 5, width: view.width/3, height: 25)
        
        settingButton.frame = CGRect(x: view.width/2 - 100, y: countryCityLabel.bottom + 10, width: 50, height: 40)
        cameraButton.frame = CGRect(x: view.width/2 - 25, y: countryCityLabel.bottom + 10, width: 50, height: 40)
        editeButton.frame = CGRect(x: view.width/2 + 50, y: countryCityLabel.bottom + 10, width: 50, height: 40)
        informationLabel.frame = CGRect(x: 20, y: backgroundView.bottom + 10, width: view.width - 40, height: 40)
        
        dateOfBirthLabel.frame = CGRect(x: 20, y: informationLabel.bottom + 10, width: 75, height: 28)
        dateOfBirthField.frame = CGRect(x: dateOfBirthLabel.right + 5, y: informationLabel.bottom + 10, width: view.width - 45 - dateOfBirthLabel.width, height: 28)
        genderLabel.frame = CGRect(x: 20, y: dateOfBirthField.bottom + 10, width: 75, height: 28)
        genderField.frame = CGRect(x: genderLabel.right + 5, y: dateOfBirthField.bottom + 10, width: view.width - 45 - genderLabel.width, height: 28)

        jobLabel.frame = CGRect(x: 20, y: genderLabel.bottom + 10, width: 75, height: 28)
        jobField.frame = CGRect(x: jobLabel.right + 5, y: genderLabel.bottom + 10, width: view.width - 45 - jobLabel.width, height: 28)
        countryLabel.frame = CGRect(x: 20, y: jobLabel.bottom + 10, width: 75, height: 28)
        countryField.frame = CGRect(x: countryLabel.right + 5, y: jobLabel.bottom + 10, width: view.width - 45 - countryLabel.width, height: 28)
        cityLabel.frame = CGRect(x: 20, y: countryField.bottom + 10, width: 75, height: 28)
        cityField.frame = CGRect(x: cityLabel.right + 5, y: countryField.bottom + 10, width: view.width - 45 - cityLabel.width, height: 28)
        aboutLabel.frame = CGRect(x: 20, y: cityField.bottom + 10, width: view.width - 40, height: 40)
        aboutTextView.frame = CGRect(x: 20, y: aboutLabel.bottom + 10, width: view.width - 40, height: 100)

        
        scrollView.addSubview(backgroundView)
        
        backgroundView.addSubview(imageView)
        backgroundView.addSubview(userIdLabel)
        backgroundView.addSubview(nameLabel)
        backgroundView.addSubview(countryCityLabel)
        backgroundView.addSubview(editeButton)
        backgroundView.addSubview(settingButton)
        backgroundView.addSubview(cameraButton)
        scrollView.addSubview(informationLabel)
        scrollView.addSubview(genderLabel)
        scrollView.addSubview(genderField)
        scrollView.addSubview(dateOfBirthLabel)
        scrollView.addSubview(dateOfBirthField)
        scrollView.addSubview(jobLabel)
        scrollView.addSubview(jobField)
        scrollView.addSubview(countryLabel)
        scrollView.addSubview(countryField)
        scrollView.addSubview(cityLabel)
        scrollView.addSubview(cityField)
        scrollView.addSubview(aboutLabel)
        scrollView.addSubview(aboutTextView)

        scrollView.contentSize = CGSize(width: view.width, height: aboutTextView.bottom + 20)
    }
    
    //MARK:-loginAuth
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }


    //MARK:-Button @obj func
    @objc func editButtonPressed(){
        editingMode.toggle()
        updateEditingMode()
        showSaveButton()
    }
    @objc private func showCameraGallery(){
        itemImages = []
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab,.cameraTab]
        Config.Camera.imageLimit = 1
        present(self.gallery, animated: true, completion: nil)
        
    }
//background touch
    private func setupBackgroundTouch(){
        backgroundView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        scrollView.addGestureRecognizer(tapGesture)
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap(){
        self.datePicker.endEditing(false)
        self.aboutTextView.endEditing(false)
        self.cityField.endEditing(false)
        self.dateOfBirthField.endEditing(false)
        self.countryField.endEditing(false)
        self.genderField.endEditing(false)
        self.jobField.endEditing(false)
    }
    //MARK:- Helper
    private func showSaveButton(){
   
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(editeUserData))
        navigationItem.rightBarButtonItem = editingMode ? saveButton : nil
    }

    private func setupPickerView(){
        genderPickerView = UIPickerView()
        genderPickerView.delegate = self
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //barBtn
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneBtn], animated: true)
        
        genderField.inputView = genderPickerView
        genderField.inputAccessoryView = toolbar
    }
    @objc func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    @objc private func editeUserData(){
        
        let user = FUser.currentUser()!
        user.about = aboutTextView.text
        user.jobTitle = jobField.text ?? ""
        user.isMale = genderField.text == "Male"
        user.city = cityField.text ?? ""
        user.country = countryField.text ?? ""
 
        if itemImages.count > 0 {
            StorageManager.shared.uploadImages(images: itemImages) { (imageLinkArray) in
                user.imageLinks = imageLinkArray
                user.avatarLink = imageLinkArray.first!
                DispatchQueue.main.async {
                    self.saveUserData(user: user)
                    self.loadUserData()
                }
            }
        }else{
            //save
            saveUserData(user: user)
            loadUserData()
        }
        editingMode = false
        updateEditingMode()
        showSaveButton()
    }
    private func saveUserData(user:FUser){
        user.saveUserLocally()
        user.saveUserToFirestore()
    }
    
    //MARK:-setup UI
    private func loadUserData(){
        if FUser.currentUser() != nil{
            let currentUser = FUser.currentUser()!
            userIdLabel.text = "ID:" + currentUser.objectId
            nameLabel.text = "Name:" + currentUser.userName
            countryCityLabel.text = "Location:" + currentUser.country + " " + currentUser.city
            aboutTextView.text = currentUser.about != "" ? currentUser.about : "A little bit about me..."
            
            jobField.text = currentUser.jobTitle
            genderField.text = currentUser.isMale ? "Male" : "Female"
            cityField.text = currentUser.city
            countryField.text = currentUser.country
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            dateOfBirthField.text = formatter.string(from: currentUser.dateOfBirth)
            
            if currentUser.avatarLink != "" {
                StorageManager.shared.downloadImage(imageUrl: currentUser.avatarLink) { (avatar) in
                    DispatchQueue.main.async {
                        self.imageView.image = avatar?.circleMasked
                    }
                }
            }
        }
    }
    //Editing Mode
    private func updateEditingMode(){
        aboutTextView.isUserInteractionEnabled = editingMode
        jobField.isUserInteractionEnabled = editingMode
        genderField.isUserInteractionEnabled = editingMode
        cityField.isUserInteractionEnabled = editingMode
        countryField.isUserInteractionEnabled = editingMode
        dateOfBirthField.isUserInteractionEnabled = editingMode

    }
    
    //settings
    @objc private func showSettingOptions(){
        let alerController = UIAlertController(title: "Edit Account", message: "You are about to edit account information", preferredStyle: .actionSheet)
        alerController.addAction(UIAlertAction(title: "Account Settings", style: .default, handler: { (alert) in
            self.settings()
        }))
        alerController.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (UIAlertAction) in
            self.logoutBtnPressed()
        }))
        alerController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            print("cancel")
        }))
        present(alerController, animated: true, completion: nil)
    }

    private func settings(){
        let vc = AccountSettingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
 
    private func logoutBtnPressed(){
        FUser.logoutCurrentUser { (error) in
            if error == nil {
                print("log out")
                let loginView = LoginViewController()
                let nav = UINavigationController(rootViewController: loginView)
                DispatchQueue.main.async {
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                }
            } else {
                print("error logout", error!.localizedDescription)
            }
            
        }
    }

    //MARK:-SetupDatePicker
    private func setupDatePicker(){
        if #available(iOS 13.4, *){
            datePicker.preferredDatePickerStyle = .wheels
        }
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //barBtn
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        //assign toolbar
        dateOfBirthField.inputAccessoryView = toolbar
        //assign date picker to textField
        dateOfBirthField.inputView = datePicker
        datePicker.datePickerMode = .date
    }
        @objc func donePressed(){
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            dateOfBirthField.text = formatter.string(from: datePicker.date)
            if let currentUser = FUser.currentUser(){
                currentUser.dateOfBirth = datePicker.date

                saveUserData(user: currentUser)
                loadUserData()
            }

            self.view.endEditing(false)
        }
    

}


extension ProfileViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            Image.resolve(images: images) { (resolvedImages) in
                self.itemImages = resolvedImages
                self.editingMode = true
                self.imageView.image = resolvedImages.first!?.circleMasked
                self.showSaveButton()
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

extension ProfileViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row]
    }
    
}
extension ProfileViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderField.text = genderOptions[row]
    }
}

