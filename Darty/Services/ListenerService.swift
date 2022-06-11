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
    
    private init () {}
    
    private let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private var recentsRef: CollectionReference {
        return db.collection("recents")
    }
    
    private var typingRef: CollectionReference {
        return db.collection("typing")
    }
    
    private var messagesRef: CollectionReference {
        return db.collection("messages")
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

    private var rejectedPartiesListener: ListenerRegistration!

    func rejectedPartiesObserve(parties: [PartyModel], completion: @escaping (Result<[PartyModel], Error>) -> Void) {
        
        var parties = parties
        let partiesRef = db.collection(["users", Auth.auth().currentUser!.uid, "rejectedParties"].joined(separator: "/"))
        
        self.rejectedPartiesListener = partiesRef.addSnapshotListener { (querySnapshot, error) in
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
    }

    private var waitingPartiesListener: ListenerRegistration!

    func waitingPartiesObserve(parties: [PartyModel], completion: @escaping (Result<[PartyModel], Error>) -> Void) {
        
        var parties = parties
        let partiesRef = db.collection(["users", Auth.auth().currentUser!.uid, "waitingParties"].joined(separator: "/"))
        
        self.waitingPartiesListener = partiesRef.addSnapshotListener { (querySnapshot, error) in
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
    }

    private var approvedPartiesListener: ListenerRegistration!

    func approvedPartiesObserve(parties: [PartyModel], completion: @escaping (Result<[PartyModel], Error>) -> Void) {
        
        var parties = parties
        let partiesRef = db.collection(["users", Auth.auth().currentUser!.uid, "approvedParties"].joined(separator: "/"))
        
        self.approvedPartiesListener = partiesRef.addSnapshotListener { (querySnapshot, error) in
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
    }


    private var myPartiesListener: ListenerRegistration!

    func myPartiesObserve(parties: [PartyModel], completion: @escaping (Result<[PartyModel], Error>) -> Void) {
        self.myPartyRequestsListeners?.forEach({ myPartyRequestListener in
            myPartyRequestListener.remove()
        })
        self.myPartyRequestsListeners?.removeAll()


        var parties = parties
        let partiesRef = db.collection(["users", currentUserId, "myParties"].joined(separator: "/"))
        
        let dg = DispatchGroup()
        
        self.myPartiesListener = partiesRef.addSnapshotListener { (querySnapshot, error) in
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
    }

    private var myPartyRequestsListeners: [ListenerRegistration]!
    
    func waitingGuestsRequestsObserve(waitingGuestsRequests: [PartyRequestModel],
                                      partyId: String,
                                      completion: @escaping (Result<[PartyRequestModel], Error>) -> Void) {
        
        var waitingGuestsRequests = waitingGuestsRequests
        let reference = db.collection(["parties", partyId, "waitingGuests"].joined(separator: "/"))

        let myPartyRequestsListener = reference.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
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

        self.myPartyRequestsListeners?.append(myPartyRequestsListener)
    }
    
    // MARK: - Chats
    private var recentChatsListener: ListenerRegistration!

    func recentChatsObserve(recents: [RecentChatModel], completion: @escaping (Result<[RecentChatModel], Error>) -> Void) {
        var recents = recents

        let ref = recentsRef.whereField("senderId", isEqualTo: currentUserId)
        self.recentChatsListener = ref.addSnapshotListener { (querySnapshot, error) in
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
                    guard let index = recents.firstIndex(of: recent) else { return }
                    recents[index] = recent
                case .removed:
                    guard let index = recents.firstIndex(of: recent) else { return }
                    recents.remove(at: index)
                }
            }
            
            #warning("Не знаю нужна ли тут эта сортировка")
            recents.sort(by: {$0.date > $1.date })
            completion(.success(recents))
        }
    }

    private var recentWaitingChatsListener: ListenerRegistration!

    func recentWaitingChatsObserve(chats: [RecentChatModel], completion: @escaping (Result<[RecentChatModel], Error>) -> Void) {
        var chats = chats
        let chatsRef = db.collection(["users", currentUserId, "waitingChats"].joined(separator: "/"))
        self.recentWaitingChatsListener = chatsRef.addSnapshotListener { (querySnapshot, error) in
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
    }
    
    // MARK: - Chat listeners
    var updatedChatListener: ListenerRegistration!
    var newChatListener: ListenerRegistration!
    
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        newChatListener = messagesRef.document(documentId).collection(collectionId).whereField(GlobalConstants.kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ querySnapshot, error in
            guard let shanshot = querySnapshot else { return }
            
            for change in shanshot.documentChanges {
                if change.type == .added {
                    let result = Result {
                        LocalMessage(document: change.document)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            if message.senderId != AuthService.shared.currentUser!.id {
                                RealmManager.shared.saveToRealm(message)
                            }
                        } else {
                            print("ERROR_LOG Document doesnt exist")
                        }
                    case .failure(let error):
                        print("ERROR_LOG Error decoding LocalMessage: ", error.localizedDescription)
                    }
                }
            }
        })
    }

    func listenForReadStatusChange(_ documentId: String, collectionId: String, completion: @escaping (_ updateMessage: LocalMessage) -> Void) {
        self.updatedChatListener = messagesRef.document(documentId).collection(collectionId).addSnapshotListener({ querySnapshot, error in
            guard let snaphot = querySnapshot else { return }
            
            for change in snaphot.documentChanges {
                if change.type == .modified {
                    let result = Result {
                        LocalMessage(document: change.document)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            completion(message)
                        } else {
                            print("ERROR_LOG document does not exist")
                        }
                    case .failure(let error):
                        print("ERROR_LOG Error decoding local message: ", error.localizedDescription)
                    }
                }
            }
        })
    }
    
    func removeChatListeners() {
        self.newChatListener?.remove()
        self.updatedChatListener?.remove()
    }
    
    // MARK: - Typing listener
    var typingListener: ListenerRegistration!
    
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        typingListener = typingRef.document(chatRoomId).addSnapshotListener({ [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != self.currentUserId {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                self.typingRef.document(chatRoomId).setData([self.currentUserId: false])
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        shared.typingRef.document(chatRoomId).updateData([shared.currentUserId: typing])
    }
    
    func removeTypingListener() {
        self.typingListener?.remove()
    }

    // MARK: - Remove all listeners for exit from account function
    func removeAllObservers() {
        removeChatListeners()
        removeTypingListener()
        rejectedPartiesListener?.remove()
        waitingPartiesListener?.remove()
        approvedPartiesListener?.remove()
        myPartiesListener?.remove()
        myPartyRequestsListeners?.forEach({ listener in
            listener.remove()
        })

        recentWaitingChatsListener?.remove()
        recentChatsListener?.remove()
    }
}
