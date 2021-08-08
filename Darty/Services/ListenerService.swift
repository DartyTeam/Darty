//
//  ListenerService.swift
//  Darty
//
//  Created by Руслан Садыков on 07.07.2021.
//

import Firebase
import FirebaseFirestore

class ListenerService {
    
    static let shared = ListenerService()
    
    private let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private var recentsRef: CollectionReference {
        return db.collection("recents")
    }
    
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    //    func usersObserve(users: [PUser], completion: @escaping (Result<[PUser], Error>) -> Void) -> ListenerRegistration? {
    //        let usersLestener = usersRef.addSnapshotListener { (querySnapshot, error) in
    //            guard let snapshot = querySnapshot else {
    //                completion(.failure(error!))
    //                return
    //            }
    //
    //            snapshot.documentChanges.forEach { (diff) in
    //                guard let user = PUser(document: diff.document) else { return }
    //            }
    //        }
    //
    //        return usersLestener
    //    }
    
    func rejectedPartiesObserve(parties: [PartyModel], completion: @escaping (Result<[PartyModel], Error>) -> Void) -> ListenerRegistration? {
        
        var parties = parties
        let partiesRef = db.collection(["users", Auth.auth().currentUser!.uid, "rejectedParties"].joined(separator: "/"))
        
        let partiesListener = partiesRef.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            let dg = DispatchGroup()
       
            snapshot.documentChanges.forEach { (diff) in
                dg.enter()
                FirestoreService.shared.getPartyBy(uid: diff.document.documentID) { (result) in
                    switch result {
                    case .success(let party):
                        switch diff.type {
                        case .added:
                            guard !parties.contains(party) else { return }
                            parties.append(party)
                            dg.leave()
                        case .modified:
                            guard let index = parties.firstIndex(of: party) else { return }
                            parties[index] = party
                            dg.leave()
                        case .removed:
                            guard let index = parties.firstIndex(of: party) else { return }
                            parties.remove(at: index)
                            dg.leave()
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    } // switch result
                } // FirestoreService.shared.getPartyBy
            } //snapshot.documentChanges.forEach
            
            dg.notify(queue: .main) {
                completion(.success(parties))
            }
        } //let partiesListener = partiesRef.addSnapshotListener
        
        return partiesListener
    }
    
    func waitingPartiesObserve(parties: [PartyModel], completion: @escaping (Result<[PartyModel], Error>) -> Void) -> ListenerRegistration? {
        
        var parties = parties
        let partiesRef = db.collection(["users", Auth.auth().currentUser!.uid, "waitingParties"].joined(separator: "/"))
        
        let partiesListener = partiesRef.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            let dg = DispatchGroup()
       
            snapshot.documentChanges.forEach { (diff) in
                dg.enter()
                FirestoreService.shared.getPartyBy(uid: diff.document.documentID) { (result) in
                    switch result {
                    case .success(let party):
                        switch diff.type {
                        case .added:
                            guard !parties.contains(party) else { return }
                            parties.append(party)
                            dg.leave()
                        case .modified:
                            guard let index = parties.firstIndex(of: party) else { return }
                            parties[index] = party
                            dg.leave()
                        case .removed:
                            guard let index = parties.firstIndex(of: party) else { return }
                            parties.remove(at: index)
                            dg.leave()
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    } // switch result
                } // FirestoreService.shared.getPartyBy
            } //snapshot.documentChanges.forEach
            
            dg.notify(queue: .main) {
                completion(.success(parties))
            }
        } //let partiesListener = partiesRef.addSnapshotListener
        
        return partiesListener
    }
    
    func approvedPartiesObserve(parties: [PartyModel], completion: @escaping (Result<[PartyModel], Error>) -> Void) -> ListenerRegistration? {
        
        var parties = parties
        let partiesRef = db.collection(["users", Auth.auth().currentUser!.uid, "approvedParties"].joined(separator: "/"))
        
        let partiesListener = partiesRef.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            let dg = DispatchGroup()
           
            snapshot.documentChanges.forEach { (diff) in
                dg.enter()
                FirestoreService.shared.getPartyBy(uid: diff.document.documentID) { (result) in
                    switch result {
                    case .success(let party):
                        switch diff.type {
                        case .added:
                            guard !parties.contains(party) else { return }
                            parties.append(party)
                            dg.leave()
                        case .modified:
                            guard let index = parties.firstIndex(of: party) else { return }
                            parties[index] = party
                            dg.leave()
                        case .removed:
                            guard let index = parties.firstIndex(of: party) else { return }
                            parties.remove(at: index)
                            dg.leave()
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    } // switch result
                } // FirestoreService.shared.getPartyBy
            } //snapshot.documentChanges.forEach
            
            dg.notify(queue: .main) {
                completion(.success(parties))
            }
        } //let partiesListener = partiesRef.addSnapshotListener
        
        return partiesListener
    }
    
    func myPartiesObserve(parties: [PartyModel], completion: @escaping (Result<[PartyModel], Error>) -> Void) -> ListenerRegistration? {
        
        var parties = parties
        let partiesRef = db.collection(["users", currentUserId, "myParties"].joined(separator: "/"))
        
        let dg = DispatchGroup()
        
        let partiesListener = partiesRef.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                dg.enter()
                FirestoreService.shared.getPartyBy(uid: diff.document.documentID) { (result) in
                    switch result {
                    case .success(let party):
                        switch diff.type {
                        case .added:
                            guard !parties.contains(party) else { return }
                            parties.append(party)
                            dg.leave()
                        case .modified:
                            guard let index = parties.firstIndex(of: party) else { return }
                            parties[index] = party
                            dg.leave()
                        case .removed:
                            guard let index = parties.firstIndex(of: party) else { return }
                            parties.remove(at: index)
                            dg.leave()
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    } // switch result
                } // FirestoreService.shared.getPartyBy
            } //snapshot.documentChanges.forEach
            
            dg.notify(queue: .main) {
                completion(.success(parties))
            }
        } //let partiesListener = partiesRef.addSnapshotListener
        
        return partiesListener
    }
    
    func waitingGuestsRequestsObserve(waitingGuestsRequests: [PartyRequestModel], partyId: String, completion: @escaping (Result<[PartyRequestModel], Error>) -> Void) -> ListenerRegistration? {
        
        var waitingGuestsRequests = waitingGuestsRequests
        let reference = db.collection(["parties", partyId, "waitingGuests"].joined(separator: "/"))
        
        
        let requestsListener = reference.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                print("asdiojasidoajd: ", diff)
                print("asidjasidojasoidjasd: ", diff)
                
                guard let partyRequest = PartyRequestModel(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !waitingGuestsRequests.contains(partyRequest) else { return }
                    waitingGuestsRequests.append(partyRequest)
                case .modified:
                    guard let index = waitingGuestsRequests.firstIndex(of: partyRequest) else { return }
                    waitingGuestsRequests[index] = partyRequest
                case .removed:
                    guard let index = waitingGuestsRequests.firstIndex(of: partyRequest) else { return }
                    waitingGuestsRequests.remove(at: index)
                }
                
            } //snapshot.documentChanges.forEach

            completion(.success(waitingGuestsRequests))
            
        } //let requestsListener = partiesRef.addSnapshotListener
        
        return requestsListener
    }
    
    
    // MARK: - Chats
    func waitingChatsObserve(chats: [ChatModel], completion: @escaping (Result<[ChatModel], Error>) -> Void) -> ListenerRegistration? {
        var chats = chats
        let chatsRef = db.collection(["users", currentUserId, "waitingChats"].joined(separator: "/"))
        let chatsListener = chatsRef.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let chat = ChatModel(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            
            completion(.success(chats))
        }
        
        return chatsListener
    }
    
    func activeChatsObserve(chats: [ChatModel], completion: @escaping (Result<[ChatModel], Error>) -> Void) -> ListenerRegistration? {
        var chats = chats
        let chatsRef = db.collection(["users", currentUserId, "activeChats"].joined(separator: "/"))
        let chatsListener = chatsRef.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let chat = ChatModel(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            
            completion(.success(chats))
        }
        
        return chatsListener
    }
    
    func messagesObserve(chat: ChatModel, completion: @escaping (Result<MessageModel, Error>) -> Void) -> ListenerRegistration? {
        let ref = usersRef.document(currentUserId).collection("activeChats").document(chat.friendId).collection("messages")
        let messagesListener = ref.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let message = MessageModel(document: diff.document) else { return }
                
                switch diff.type {
                
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
        }
        return messagesListener
    }
    
    func recentChatsObserve(recents: [RecentChatModel], completion: @escaping (Result<[RecentChatModel], Error>) -> Void) -> ListenerRegistration? {
        var recents = recents

        let ref = recentsRef.whereField("senderId", isEqualTo: currentUserId)
        let recentsListener = ref.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
 
            snapshot.documentChanges.forEach { (diff) in
                guard let recent = RecentChatModel(document: diff.document), !recent.lastMessageContent.isEmpty else { return }
                switch diff.type {
                case .added:
                    guard !recents.contains(recent) else { return }
                    recents.append(recent)
                case .modified:
                    print("asdiojasoidaoijsdas")
                    guard let index = recents.firstIndex(of: recent) else { return }
                    recents[index] = recent
                case .removed:
                    print("asdiojasdasd")
                    guard let index = recents.firstIndex(of: recent) else { return }
                    recents.remove(at: index)
                }
            }
            
//            recents.sort(by: {$0.date > $1.date })
            completion(.success(recents))
        }
        
        return recentsListener
    }
    
    func recentWaitingChatsObserve(chats: [RecentChatModel], completion: @escaping (Result<[RecentChatModel], Error>) -> Void) -> ListenerRegistration? {
        var chats = chats
        let chatsRef = db.collection(["users", currentUserId, "waitingChats"].joined(separator: "/"))
        let chatsListener = chatsRef.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let chat = RecentChatModel(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            
            completion(.success(chats))
        }
        
        return chatsListener
    }
}
