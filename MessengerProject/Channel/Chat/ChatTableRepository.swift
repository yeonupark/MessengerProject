//
//  ChatTableRepository.swift
//  MessengerProject
//
//  Created by Yeonu Park on 2024/01/30.
//

import Foundation
import RealmSwift

protocol ChatTableRepositoryType: AnyObject {
    
    func fetch() -> Results<ChatTable>
    func addItem(item: ChatTable)
}

class ChatTableRepository: ChatTableRepositoryType {
    
    private let realm = try! Realm()
    
    func fetch() -> RealmSwift.Results<ChatTable> {
        
        let data = realm.objects(ChatTable.self)
        return data
    }
    
    func addItem(item: ChatTable) {
        do {
            try realm.write {
                realm.add(item)
            }
        }
        catch {
            print(error)
        }
    }
    
}