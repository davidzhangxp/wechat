//
//  ChatViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/26/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import Gallery
import SKPhotoBrowser

class ChatViewController: MessagesViewController {

    //vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    let refreshController = UIRefreshControl()
    
    let currentUser = MKSender(senderId: FUser.currentId(), displayName: FUser.currentUser()!.userName)
    private var mkmessages:[MKMessage] = []
    var loaderMessageDictionary:[Dictionary<String,Any>] = []
    var initialLoadCompleted = false
    
    var displayingMessageCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    
    var typingCounter = 0
    var gallery: GalleryController!
    //listeners
    var newChatListener: ListenerRegistration?
    var typingListener: ListenerRegistration?
    var updateMessageStatusListener: ListenerRegistration?
    
    //Inits
    init(chatId:String,recipientId:String,recipientName:String){
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        title = recipientName
        configureMessageInputBar()
        configureMessageCollectionView()

        createTypingObserver()
        listenForReadStatusChange()
        downloadChats()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButtonPressed))

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        messageInputBar.inputTextView.becomeFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseListener.shared.resetRecentCounter(chatRoomId: chatId)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirebaseListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListener()
    }
    //MARK:-configure
    private func configureMessageInputBar(){
        messageInputBar.delegate = self
        let button = InputBarButtonItem()
        button.image = UIImage(systemName: "paperclip")
        button.setSize(CGSize(width: 30, height: 30), animated: false)
        button.onTouchUpInside { (item) in
            self.actionAttachMessage()
        }
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground

    }
    private func configureMessageCollectionView(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshController
    }
    private func actionAttachMessage(){
        messageInputBar.inputTextView.resignFirstResponder()

        let alerController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alerController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            self.showImageGalleryFor(camera: true)
        }))
        alerController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (alert) in
            self.showImageGalleryFor(camera: false)
        }))

        alerController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            print("cancel")
        }))
        present(alerController, animated: true, completion: nil)
        
    }
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
    @objc func backButtonPressed(){
        navigationController?.popViewController(animated: true)
        removeListener()
    }
    
    //MARK:-Create Messages
    
    private func messageSend(text: String?,photo:UIImage?){
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, memberIds: [FUser.currentId(),recipientId])
    }
    private func insertMessages(){
        maxMessageNumber = loaderMessageDictionary.count - displayingMessageCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in minMessageNumber ..< maxMessageNumber{
            let messageDictionary = loaderMessageDictionary[i]
            insertMessage(messageDictionary)
            displayingMessageCount += 1
        }
    }
    
    private func insertMessage(_ messageDictionary: Dictionary<String,Any>){
        markMessageAsRead(messageDictionary)
        let incoming = IncomingMessage(collectionView_: self)
        self.mkmessages.append(incoming.createMessage(messageDictionary: messageDictionary)!)
    }
    
    private func insertOldMessage(_ messageDictionary: Dictionary<String,Any>){
        let incoming = IncomingMessage(collectionView_: self)
        self.mkmessages.insert(incoming.createMessage(messageDictionary: messageDictionary)!, at: 0)
    }
    
    
    //MARK:-Download chats
    private func downloadChats(){
        FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).limit(to: 11).order(by: kSENTDATE, descending: true).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else{
                self.initialLoadCompleted = true
                return
            }
            //get dictionary from firebase snapshot documents
            self.loaderMessageDictionary = ((self.dictionaryArrayFromSnapshot(snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kSENTDATE, ascending: true)]) as! [Dictionary<String,Any>]
            //insert messages to chatroom

            self.initialLoadCompleted = true
            self.insertMessages()
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
            //download old chats
            self.getOldMessagesInBackground()
            //listen for new chats
            self.listenForNewChats()
        }
    }
    private func getOldMessagesInBackground(){
        if loaderMessageDictionary.count > kNUMBEROFMESSAGES {
            FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).whereField(kSENTDATE, isLessThan: firstMessageDate()).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else{return}
                self.loaderMessageDictionary = ((self.dictionaryArrayFromSnapshot(snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kSENTDATE, ascending: true)]) as! [Dictionary<String,Any>] + self.loaderMessageDictionary
                
                self.messagesCollectionView.reloadData()
                
                self.maxMessageNumber = self.loaderMessageDictionary.count - self.displayingMessageCount - 1
                self.minMessageNumber = self.maxMessageNumber - kNUMBEROFMESSAGES
                
            }
        }
    }
    
    private func loadMoreMessages(maxNumber: Int,minNumber:Int){
        if loadOld{
            maxMessageNumber = minNumber - 1
            minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        }
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in (minMessageNumber ... maxMessageNumber).reversed(){
            let messageDictionary = loaderMessageDictionary[i]
            insertOldMessage(messageDictionary)
            displayingMessageCount += 1
        }
    }
    
    private func listenForNewChats(){
        newChatListener = FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).whereField(kSENTDATE, isGreaterThan: lastMessageDate()).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else{return}
            if !snapshot.isEmpty{
                for change in snapshot.documentChanges{
                    if change.type == .added{
                        self.insertMessage(change.document.data())
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
                }
            }
        })
    }
    //Mark:Reading status
    private func markMessageAsRead(_ messageDictionary: Dictionary<String,Any>){
        if messageDictionary[kSENDERID] as! String != FUser.currentId(){
            OutgoingMessage.updateMessageStatus(withId: messageDictionary[kOBJECTID] as! String, chatRoomId: chatId, memberIds: [FUser.currentId(),recipientId])
        }
    }
    private func listenForReadStatusChange(){
        updateMessageStatusListener = FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {return}
            if !snapshot.isEmpty{
                snapshot.documentChanges.forEach { (change) in
                    if change.type == .modified{
                        self.updateMessage(change.document.data())
                    }
                }
            }
        })
    }
    
    private func updateMessage(_ messageDictionary:Dictionary<String,Any>){
        for index in 0 ..< mkmessages.count{
            let tempMessage = mkmessages[index]
            if messageDictionary[kOBJECTID] as! String == tempMessage.messageId{
                mkmessages[index].status = messageDictionary[kSTATUS] as? String ?? kSENT
                if mkmessages[index].status == kREAD{
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    private func removeListener(){
        if newChatListener != nil {
            newChatListener?.remove()
        }
        if typingListener != nil{
            typingListener?.remove()
        }
        if updateMessageStatusListener != nil{
            updateMessageStatusListener?.remove()
        }
    }
    //MARK:-UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing{
            if displayingMessageCount < loaderMessageDictionary.count{
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
    }
    //MARK:-Typing indicator
    private func createTypingObserver(){
        TypingListener.shared.createTypingObserver(chatRoomId: chatId) { (isTyping) in
            self.setTypingIndicatorViewHidden(!isTyping, animated: false, whilePerforming: nil) { [weak self] success in
                if success, self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                }
            }
        }
    }
    
    private func typingIndicatorUpdate(){
        typingCounter += 1
        TypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.typingCounterStop()
        }
    }
    
    private func typingCounterStop(){
        typingCounter -= 1
        if typingCounter == 0 {
            TypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
        
    }
    
    func isLastSectionVisible() -> Bool {
        guard !mkmessages.isEmpty else {
            return false
        }
        let lastIndexPath = IndexPath(item: 0, section: mkmessages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    
    //MARK:-Helpers
    private func dictionaryArrayFromSnapshot(_ snapshots:[DocumentSnapshot]) -> [[String:Any]]{
        var allMessages:[Dictionary<String,Any>] = []
        for snapshot in snapshots{
            allMessages.append(snapshot.data()!)
        }
        return allMessages
    }
    private func firstMessageDate()->Date{
        let firstMessageDate = (loaderMessageDictionary.first?[kSENTDATE] as? Timestamp)?.dateValue() ?? Date()
        return Calendar.current.date(byAdding: .second, value: -1, to: firstMessageDate) ?? firstMessageDate
    }
    
    private func lastMessageDate()->Date{
        let lastMessageDate = (loaderMessageDictionary.last?[kSENTDATE] as? Timestamp)?.dateValue() ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    //MARK:- Gallery
    private func showImageGalleryFor(camera:Bool){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .cameraTab
        self.present(gallery, animated: true, completion: nil)
    }
    //MARK:- SKPhotoBrower
    private func showImage(_ images:[UIImage],startIndex: Int){
        var SKImages: [SKPhoto] = []
        for image in images {
            SKImages.append(SKPhoto.photoWithImage(image))
        }
        let browser = SKPhotoBrowser(photos: SKImages)
        browser.initializePageIndex(startIndex)
        self.present(browser, animated: true, completion: nil)
    }
}


extension ChatViewController:InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text != ""{
            typingIndicatorUpdate()
        }
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: "", with: "").isEmpty else {
            return
        }
        messageSend(text: text, photo: nil)

        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}

extension ChatViewController: MessagesDataSource,MessagesDisplayDelegate,MessagesLayoutDelegate{
    func currentSender() -> SenderType {
        return currentUser
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return mkmessages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return mkmessages.count
    }
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0{
            let showLoadMore = (indexPath.section == 0) && loaderMessageDictionary.count > displayingMessageCount
            let text = showLoadMore ? "Pull to more messages" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.boldSystemFont(ofSize: 12) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            return NSAttributedString(string: text, attributes: [.font:font,.foregroundColor:color])
        }
        return nil
    }
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message){
            let message = mkmessages[indexPath.section]
            let status = indexPath.section == mkmessages.count - 1 ? message.status : ""
            return NSAttributedString(string: status, attributes: [.font:UIFont.boldSystemFont(ofSize: 10)])
        }
        return nil
    }
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0{
            return 18
        }
        return 0
    }

    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if mkmessages[indexPath.section].avatarLink != "" {
            StorageManager.shared.downloadImage(imageUrl: mkmessages[indexPath.section].avatarLink!) { (avatar) in
                DispatchQueue.main.async {
                    avatarView.set(avatar: Avatar(image: avatar?.circleMasked, initials: self.mkmessages[indexPath.section].sengderInitials))
                }
            }
        }else{
            avatarView.set(avatar: Avatar(image: nil, initials: mkmessages[indexPath.section].sengderInitials))
        }
        
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        switch detector {
        case .hashtag,.mention:
            return [.foregroundColor: UIColor.blue]
        default:
            return MessageLabel.defaultAttributes
        }
    }
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url,.address,.phoneNumber,.date,.transitInformation,.hashtag,.mention]
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? MessageDefaults.bubbleColorOutgoing : MessageDefaults.bubbleColorIncoming
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail : MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}

extension ChatViewController: MessageCellDelegate{
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        switch message.kind {
                    case .photo(let photoItem):
                        if let img = photoItem.image{
                            self.showImage([img], startIndex: 0)
                        }
                    default:
                        print("Message is not a photo.")
                        break
                }
    }

}

extension ChatViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            images.first?.resolve(completion: { (image) in
                self.messageSend(text: nil, photo: image)
            })

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
