//
//  TeamState.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-01-28.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

//  The TeamState is an object representing the current contents of the team.
//  The channels array holds most of what will be displayed onscreen.

import Foundation


struct TeamState {
    var users:              Dictionary<String, User>
    var channels:           Dictionary<String, Channel> // Messages are contained within channels
    var looseEnds:          Array<SlackRequest>
    var hasUnreadMessages:  Bool {
        var channelHasUnreadMessages = false
        
        for channel in channels.values {
            channelHasUnreadMessages = channel.hasUnreadMessages
            if channelHasUnreadMessages { break }
        }
        
        return channelHasUnreadMessages
    }
    
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
            
        case .EventResult(let event):
            if let contents = event.contents {
                switch contents {
                case .ContainsMessage(let message):
                    if let userID = message.userID {
                        message.user = state.users[userID]
                    }
                    
                    if let channelID = message.channelID {
                        if var channelForMessage = newState.channels[channelID] {
                            channelForMessage.incorporateEvent(event)
                            newState.channels[channelID] = channelForMessage // Unsure if this is necessary in Swift, honestly
                        }
                    }
                    
                    for attachment in message.attachments {
                        requests.append(SlackRequest.AttachmentImage(message, attachment))
                        if attachment.authorIconURL != nil {
                            requests.append(SlackRequest.AuthorIcon(message, attachment))
                        }
                    }
                    
                    if let submessage = message.submessage {
                        submessage.channelID = message.channelID
                        for attachment in submessage.attachments {
                            requests.append(SlackRequest.AttachmentImage(submessage, attachment))
                        }
                    }
                    
                case .ContainsFile(let file):
                    for channelID in file.channels {
                        if var channelForMessage = newState.channels[channelID] {
                            channelForMessage.incorporateEvent(event)
                            newState.channels[channelID] = channelForMessage
                        }
                    }
                    
                default:
                    println("Unknown sort of event to incorporate")
                }
            }
            
            
        case .UserResult(let user):
            newState.users[user.id] = user
            if user.image48Image == nil {
                requests.append(SlackRequest.UserImage(user, "48"))
            }
            
        case .ChannelResult(let channel):
            newState.channels[channel.id] = channel
            if let timestamp = channel.lastRead {
                requests.append(SlackRequest.ChannelHistory(channel, nil, timestamp, true, 10))
            }
            
        case .ChannelMarkedResult(let channelID, let timestamp):
            if var markedChannel = newState.channels[channelID] {
                markedChannel.lastRead = timestamp
                newState.channels[channelID] = markedChannel
            }
            
        case .MessageResult(let message):
            println("Raw message delivered")
            
        case .FileResult(let file):
            println("Raw file delivered")
            
        case .FileThumbnailResult(let file, let image):
            println("File thumbnail delivered")
            
        case .AttachmentImageResult(let message, let attachment, let image):
            if let channelID = message.channelID {
                if let channel = newState.channels[channelID] {
                    if let timestamp = message.timestamp {
                        if let correspondingMessage = channel.messageWithTimestamp(timestamp) {
                            var (correspondingAttachment, index) = correspondingMessage.attachmentForID(attachment.id)
                            correspondingAttachment?.image = image
                            if index != nil {
                                correspondingMessage.attachments[index!] = correspondingAttachment!
                            }
                        }
                    }
                }
            }
            
        case .AuthorIconResult(let message, let attachment, let icon):
            if let channelID = message.channelID {
                if let channel = newState.channels[channelID] {
                    if let timestamp = message.timestamp {
                        if let correspondingMessage = channel.messageWithTimestamp(timestamp) {
                            var (correspondingAttachment, index) = correspondingMessage.attachmentForID(attachment.id)
                            correspondingAttachment?.authorIcon = icon
                            if index != nil {
                                correspondingMessage.attachments[index!] = correspondingAttachment!
                            }
                        }
                    }
                }
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
            for event in channel.eventTimeline {
                //message.isRead = true
            }
        }
    }
    
    func trimReadMessages() {
        for channel in channels.values {
           //channel.trimReadMessages()
        }
    }
}