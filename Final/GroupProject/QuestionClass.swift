//
//  QuestionModel.swift
//  Askr
//
//  Created by Richard Friedman on 3/6/19.
//  Copyright © 2019 UTS. All rights reserved.
//

class QuestionStruct {
    
    var question: String?
    var votes: Int!
    var answer: String?
    var id: String?
    var reply: Bool
    
    init(question: String?, votes: Int!, answer: String?, id: String?, reply: Bool) {
        
        self.question = question
        self.votes = votes
        self.answer = answer
        self.id = id
        self.reply = reply
        
    }
}
