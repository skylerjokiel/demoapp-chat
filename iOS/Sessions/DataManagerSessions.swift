///
//  DataManagerSessions.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import Combine
import DittoSwift
import SwiftUI


extension DataManager {
    var ditto: Ditto {
        DittoInstance.shared.ditto
    }
    
    var store: DittoStore {
        ditto.store
    }
    
    var sessionsCollection: DittoCollection {
        store[sessionsIdKey]
    }
    
    func allSessionsPublisher() -> AnyPublisher<[Session], Never> {
        ditto.store[sessionsIdKey]
            .findAll()
//            .sort(createdOnKey, direction: .ascending)
            .liveQueryPublisher()
            .receive(on: DispatchQueue.main)
            .map { docs, _ in
                docs.map { Session(document: $0) }                
            }
            .eraseToAnyPublisher()        
    }
    
    func sessionPublisher(for session: Session) -> AnyPublisher<Session?, Never> {
        ditto.store[sessionsIdKey]
            .findByID(session.id)
            .singleDocumentLiveQueryPublisher()
            .compactMap { doc, _ in return doc }
            .map { Session(document: $0) }
            .eraseToAnyPublisher()
    }
    
    func allSessionUsersPublisher() -> AnyPublisher<[SessionUser], Never>  {
        return ditto.store[usersKey].findAll().liveQueryPublisher()
            .map { docs, _ in
                docs.map { SessionUser(document: $0) }
            }
            .eraseToAnyPublisher()
    }
}

extension DataManager {
    
    func prePopulate() {
        guard PREPOPULATE else { return }
        
        upsertSessions()
        upsertTypes()
        upsertTeams()
    }
    
    func upsertSessions() {
        let sessions = [
            Session(
                id: UUID().uuidString, title: "Big Peer Anywhere Plan", 
                type: "Discussion", 
                description: "Flesh out more details on a plan for Big Peer Anywhere this year. Ideally this would include Federal.", 
                presenterIds: [:], attendeeIds: [:], 
                chatRoomId: "BPAnywhereChatRoom", messagesId: "BPAnywhereMessages", notesId: "BPAnywhereNotes", 
                createdBy: "", createdOn: Date()
            )
        ]
        
        for session in sessions {
            _ = try? DittoInstance.shared.ditto.store[sessionsIdKey]
                .upsert(session.docDictionary(), writeStrategy: .insertDefaultIfAbsent)
        }        
    }
    
    func upsertTypes() {
        let typesDoc: [String: Any] = [
            dbIdKey:sessionTypesIdKey, 
            typesKey: [
                "Discussion": true,
                "Q&A": true,
                "Talks": true,
                "Hackathon": true,
                "Social": true,
                "Other": true,
                undefinedTypeKey: true
            ]
        ]
        _ = try? DittoInstance.shared.ditto.store[dittoOrgIdKey]
            .upsert(typesDoc, writeStrategy: .insertDefaultIfAbsent)
    }
    
    func upsertTeams() {
        // Teams
        let teamsDoc: [String: Any] = [
            dbIdKey: dittoTeamsIdKey, 
            teamsKey: [
                "Big Peer": true,
                "Cloud Services": true,
                "Customer Experience": true,
                "Executive": true,
                "Federal": true,
                "HR": true,
                "Legal": true,
                "Marketing": true,
                "Operations": true,
                "Product": true,
                "Small Peer": true,
                "Replication": true,
                "Sales": true,
                "Transport": true,
                "Undefined": true
            ]
        ]
        
        _ = try? DittoInstance.shared.ditto.store[dittoOrgIdKey]
            .upsert(teamsDoc, writeStrategy: .insertDefaultIfAbsent)
    }
    
    
}
