//
//  todoTask.swift
//  to do list app
//
//  Created by Maxim Soloho on 2026-10-19.
//
import Foundation
import SwiftData

@Model // this class represents one task in this app
final class TodoTask {
    
    var id: UUID // unique identifier for each task
    var title: String
    var isCompleted: Bool
    var priority: Int = 1
    var createdAt: Date
    var dueDate: Date?
    
    
    init(title: String, dueDate: Date? = nil) {
        
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
        self.dueDate = dueDate
        
        
    }
    
}

