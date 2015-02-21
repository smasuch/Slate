//
//  FileEvent.swift
//  MenuSlack
//
//  Created by Steven Masuch on 2015-02-19.
//  Copyright (c) 2015 Zanopan. All rights reserved.
//

import Foundation

enum FileEvent {
    case FileCreated(File)
    case FileShared(File)
    case FileUnshared(File)
    case FilePublic(File)
    case FilePrivate(String)
        // File ID
    case FileChanged(File)
    case FileDeleted(String)
        // File ID
    case FileCommentAdded(File, FileComment)
    case FileCommentEdited(File, FileComment)
    case FilecommentDeleted(File, String)
        // File, comment ID
}