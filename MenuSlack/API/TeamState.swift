//
//  TeamState.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

//  The TeamState is an object representing the

import Foundation



struct TeamState {
    var users:      Dictionary<String, User>
    var channels:   Dictionary<String, Channel> // Messages are contained within channels
    var looseEnds:  Array<SlackRequest>
    
    init() {
        users = [String: User]()
        channels = [String: Channel]()
        looseEnds = [SlackRequest]()
    }
    
    func incorporateResult(result: SlackResult) -> (TeamState, Array<SlackRequest>) {
        return TeamState.incorporateResultIntoState(self, result: result)
    }
    
    static func incorporateResultIntoState(state: TeamState, result: SlackResult) -> (TeamState, Array<SlackRequest>) {
        
        var newState = state
        var requests = Array<SlackRequest>()
        
        switch result {
            
        case .UserResult(let user):
            newState.users[user.id] = user
            if user.image48Image == nil {
                requests.append(SlackRequest.UserImage(user, "48"))
            }
            
        case .ChannelResult(let channel):
            newState.channels[channel.id] = channel
            
        case .MessageResult(let message):
            if let userID = message.userID {
                message.user = state.users[userID]
            }
            
            if let channelID = message.channelID {
                if var channelForMessage = newState.channels[channelID] {
                    channelForMessage.incorporateMessage(message)
                    newState.channels[channelID] = channelForMessage // Unsure if this is necessary in Swift, honestly
                }
            }
            
            for attachment in message.attachments {
                requests.append(SlackRequest.AttachmentImage(message, attachment))
            }
            
            if let submessage = message.submessage {
                submessage.channelID = message.channelID
                for attachment in submessage.attachments {
                    requests.append(SlackRequest.AttachmentImage(submessage, attachment))
                }
            }
            
        case .AttachmentImageResult(let message, let attachment, let image):
            if let channelID = message.channelID {
                if let channel = newState.channels[channelID] {
                    if let timestamp = message.timestamp {
                        if let correspondingMessage = channel.messageWithTimestamp(timestamp) {
                            var correspondingAttachment = correspondingMessage.attachmentForID(attachment.id)
                            correspondingAttachment?.image = image
                        } else {
                            println("couldn't find the right corresponding message")
                        }
                    } else {
                        println("couldn't find the right timestamp")
                    }
                } else {
                    println("couldn't find the right channel")
                }
            } else {
                println("couldn't even find the channel id on the message?")
            }
            
        case .UserImageResult(let user, let key, let image):
            if let correspondingUser = newState.users[user.id] {
                correspondingUser.image48Image = image
            }
            
        default:
            println("No way found to incorporate result.")
        }
        
        return (newState, requests)
    }
    
    func markMessagesAsRead() {
        // Tell the channels the messages were viewed
        for channel in channels.values {
            for message in channel.messages {
                message.isRead = true
            }
        }
    }
    
    func trimReadMessages() {
        for channel in channels.values {
           //channel.trimReadMessages()
        }
    }
}