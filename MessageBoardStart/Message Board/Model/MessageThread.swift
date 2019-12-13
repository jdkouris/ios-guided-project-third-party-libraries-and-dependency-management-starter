//
//  MessageThread.swift
//  Message Board
//
//  Created by Spencer Curtis on 8/7/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import MessageKit

class MessageThread: Codable, Equatable {
    
    let title: String
    var messages: [MessageThread.Message]
    let identifier: String
    
    init(title: String, messages: [MessageThread.Message] = [], identifier: String = UUID().uuidString) {
        self.title = title
        self.messages = messages
        self.identifier = identifier
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let title = try container.decode(String.self, forKey: .title)
        let identifier = try container.decode(String.self, forKey: .identifier)
        if let messages = try container.decodeIfPresent([String: Message].self, forKey: .messages) {
            self.messages = Array(messages.values)
        } else {
            self.messages = []
        }
        
        self.title = title
        self.identifier = identifier
    }
    
    
    struct Message: Codable, Equatable {
        
        let text: String
        let timestamp: Date
        let displayName: String
        
        let senderID: String
        
        init(text: String, displayName: String, senderID: String = UUID().uuidString, timestamp: Date = Date()) {
            self.text = text
            self.displayName = displayName
            self.timestamp = timestamp
            self.senderID = senderID
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.text = try container.decode(String.self, forKey: .text)
            self.displayName = try container.decode(String.self, forKey: .displayName)
            if let senderID = try? container.decode(String.self, forKey: .senderID) {
                self.senderID = senderID
            } else {
                self.senderID = UUID().uuidString
            }
            
            self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        }
        
    }
    
    static func ==(lhs: MessageThread, rhs: MessageThread) -> Bool {
        return lhs.title == rhs.title &&
            lhs.identifier == rhs.identifier &&
            lhs.messages == rhs.messages
    }
}

extension MessageThread.Message: MessageType {
    var sender: SenderType {
        return Sender(senderId: senderID, displayName: displayName)
    }
    
    var messageId: String {
        return UUID().uuidString
    }
    
    var sentDate: Date {
        return timestamp
    }
    
    var kind: MessageKind {
        return .text(text)
    }
}

public struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}
