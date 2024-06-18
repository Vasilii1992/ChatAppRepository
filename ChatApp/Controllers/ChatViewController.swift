//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Василий Тихонов on 16.06.2024.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
   public var sender: any MessageKit.SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKit.MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
  public var photoURL: String
  public var senderId: String
  public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        
        return formatter
    }()
    
    public let otherUserEmail: String
    public var isNewConversation = false
        
    
    private var messages = [Message]()
    
    private var selfSender: Sender?  {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        
      return Sender(photoURL: "",
               senderId: email ,
               displayName: "Vasilii Tikhonov")
    }
    
    
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemCyan
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()

    }

}
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageId = createMessageId() else { return }
        // Send Message
        
        print("Отправили этот текст \(text)")
        if isNewConversation {
            // create convo in database
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message) { sucsess in
                if sucsess {
                    print("message sent")
                }
                else {
                    print("failed of send")
                }
            }
        }
        else {
            // append to existing conversation data
        }
    }
    
    private func createMessageId() -> String? {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
        print("created message is \(newIdentifier)")
        return newIdentifier
    }
    
    
}

extension ChatViewController: MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate {
    func currentSender() -> any MessageKit.SenderType {
        
        
        if let sender = selfSender  { return sender }
        
        fatalError("Self Sender is nil, email should be chaced")
        return Sender(photoURL: "", senderId: "12", displayName: "Default")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> any MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
    
    
}
