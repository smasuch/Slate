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
            switch event.eventType {
            case .MessageEvent(let message):
                
                if let channelID = message.channelID {
                    if var channelForMessage = newState.channels[channelID] {
                        channelForMessage.incorporateEvent(event)
                        newState.channels[channelID] = channelForMessage // Unsure if this is necessary in Swift, honestly
                    }
                }
                
                for attachment in message.attachments {
                    requests.append(SlackRequest.AttachmentImage(message.channelID!, event.timestamp, attachment))
                    if attachment.authorIconURL != nil {
                        requests.append(SlackRequest.AuthorIcon(message.channelID!, event.timestamp, attachment))
                    }
                }
            
                switch message.subtype {
                case .Changed(let event):
                    switch event.eventType {
                    case .MessageEvent(let editedMessage):
                        for attachment in editedMessage.attachments {
                            requests.append(SlackRequest.AttachmentImage(message.channelID!, event.timestamp, attachment))
                            if attachment.authorIconURL != nil {
                                requests.append(SlackRequest.AuthorIcon(message.channelID!, event.timestamp, attachment))
                            }
                        }
                    default:
                        println("Message changed, but changed event isn't a message event?")
                    }
                case .FileShare(let file, let sharedOnUpload):
                    if let thumbURL = file.thumb360 {
                        requests.append(SlackRequest.FileThumbnail(file))
                    }
                default:
                    println("Message event recieved by team state, with no current way to handle it.")
                }
                
            case .Channel(let channelEvent):
                switch channelEvent {
                case .ChannelJoined(let channel):
                    newState.channels[channel.id] = channel
                    let timestamp = channel.lastRead
                    if let lastEvent = channel.eventTimeline.last {
                        // We want the newest 10 unread messages, to start
                        if timestamp != lastEvent.timestamp {
                            requests.append(SlackRequest.ChannelHistory(channel, lastEvent.timestamp, timestamp, true, 10))
                        }
                    }
                case .ChannelLeft(let channelID):
                    newState.channels.removeValueForKey(channelID)
                case .ChannelRename(let channel):
                    newState.channels[channel.id]?.name = channel.name
                default:
                    println("Channel event received, but unused type")
                }
                
            case .File(let fileEvent):
                switch fileEvent {
                case .FileShared(let file):
                    for channelID in file.channels {
                        if var channelForMessage = newState.channels[channelID] {
                            channelForMessage.incorporateEvent(event)
                            newState.channels[channelID] = channelForMessage
                        }
                    }
                default:
                    println("File event, but no way to incorporate it")
                }
                
                
            default:
                println("Unknown sort of event to incorporate")
            }
            
            
        case .UserResult(let user):
            newState.users[user.id] = user
            if user.image48Image == nil {
                requests.append(SlackRequest.UserImage(user, "48"))
            }
            
        case .ChannelResult(let channel):
            newState.channels[channel.id] = channel
            let timestamp = channel.lastRead
            if let lastEvent = channel.eventTimeline.last {
                // We want the newest 10 unread messages, to start
                if timestamp != lastEvent.timestamp {
                    requests.append(SlackRequest.ChannelHistory(channel, lastEvent.timestamp, timestamp, true, 10))
                }
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
            if image != nil {
                for channelID in file.channels {
                    newState.channels[channelID]?.incorporateFileThumbnail(file, thumbnail: image!)
                }
            }
            
        case .AttachmentImageResult(let channelID, let timestamp, let attachmentID, let image):
            if let channel = newState.channels[channelID], image = image {
                var changedChannel = channel
                changedChannel.incorporateAttachmentImage(timestamp, attachmentID: attachmentID, image: image)
                newState.channels[channelID] = changedChannel
            }
            
        case .AuthorIconResult(let channelID, let timestamp, let attachmentID, let icon):
            if let channel = newState.channels[channelID], icon = icon {
                var changedChannel = channel
                changedChannel.incorporateAuthorIcon(timestamp, attachmentID: attachmentID, icon: icon)
                newState.channels[channelID] = changedChannel
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