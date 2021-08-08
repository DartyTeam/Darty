//
//  FirestoreService.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import Firebase
import FirebaseFirestore

class FirestoreService {
    
    static let shared = FirestoreService()
    
    let db = Firestore.firestore()
    
    private var recentChatsRef: CollectionReference {
        return db.collection("recents")
    }
    
    private var messagesRef: CollectionReference {
        return db.collection("messages")
    }
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private var waitingChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }
    
    private var activeChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "activeChats"].joined(separator: "/"))
    }
    
    var currentUser: UserModel!
    
    func getUser(by uid: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        let docRef = usersRef.document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let user = UserModel(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToUserModel))
                    return
                }
                completion(.success(user))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    func getUsers(by uids: [String], completion: @escaping (Result<[UserModel], Error>) -> Void) {
        let docRef = usersRef.whereField("uid", in: uids)
        docRef.getDocuments { queryDocument, error in
            if let queryDocument = queryDocument {

                let users: [UserModel] = queryDocument.documents.compactMap { queryDocumentSnapshot in
                    return UserModel(document: queryDocumentSnapshot)
                }
           
                completion(.success(users))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    func getUserData(user: User, completion: @escaping (Result<UserModel, Error>) -> Void ) {
        let docRef = usersRef.document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let user = UserModel(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToUserModel))
                    return
                }
                completion(.success(user))
                self.currentUser = user
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    func saveProfileWith(id: String,
                         phone: String,
                         username: String,
                         avatarImage: UIImage?,
                         description: String,
                         sex: Sex?,
                         birthday: Date,
                         interestsList: [Int],
                         completion: @escaping (Result<UserModel, Error>) -> Void) {

        var user = UserModel(username: username,
                              phone: phone,
                              avatarStringURL: "",
                              description: description,
                              sex: sex?.rawValue,
                              birthday: birthday,
                              interestsList: interestsList,
                              personalColor: "",
                              id: id,
                              pushId: "")
        
        StorageService.shared.upload(photo: avatarImage!) { (result) in
            switch result {
            
            case .success(let url):
                user.avatarStringURL = url.absoluteString
                
                // Сохранение данных в firestore
                self.usersRef.document(user.id).setData(user.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(user))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private var userRef: DocumentReference {
        return usersRef.document(Auth.auth().currentUser!.uid)
    }
    
    func updateUserInformation(username: String,
                               birthday: String,
                               avatarStringURL: String,
                               sex: String,
                               description: String,
                               personalColor: String,
                               interestsList: String,
                               completion: @escaping (Result<Void, Error>) -> Void) {
        userRef.updateData([
            "description": description,
            "sex": sex,
            "avatarStringURL": avatarStringURL,
            "birthday": birthday,
            "username": username,
            "personalColor": personalColor,
            "interestsList": interestsList
        ]) { err in
            if let err = err {
                completion(.failure(err))
                print("Error updating document: \(err)")
            } else {
                completion(.success(Void()))
                print("Document successfully updated")
            }
        }
    }
    
    private var partiesRef: CollectionReference {
        return db.collection("parties")
    }
    
    func savePartyWith(party: SetuppedParty,
                       completion: @escaping (Result<PartyModel, Error>) -> Void) {

        
        
        let partyId = UUID().uuidString
        
        print("sadijasidosad: ", party.images)
        var imagesUrlStrings: [String] = []
        let dg = DispatchGroup()
        for partyImage in party.images {
            dg.enter()
            StorageService.shared.uploadPartyImage(photo: partyImage, partyId: partyId) { (result) in
                switch result {
                case .success(let url):
                    print("asdoijasiodjasdoijasd: ", url)
                    imagesUrlStrings.append(url.absoluteString)
                case .failure(let error):
                    completion(.failure(error))
                }
                
                dg.leave()
            }
        }
        
        print("asdijaido: ", imagesUrlStrings)

        dg.notify(queue: .main) {
            // Сохранение данных в Firestore
            let party = PartyModel(city: party.city, location: GeoPoint(latitude: party.latitude, longitude: party.longitude), address: party.address, userId: party.userId, imageUrlStrings: imagesUrlStrings, type: party.type.rawValue, maxGuests: party.maxGuests, curGuests: 0, id: partyId, date: party.date, startTime: party.startTime, endTime: party.endTime, name: party.name, moneyPrice: party.moneyPrice, anotherPrice: party.anotherPrice, priceType: party.priceType.rawValue, description: party.description, minAge: party.minAge)
            
            self.partiesRef.document(party.id).setData(party.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                self.userRef.collection("myParties").document(party.id).setData( ["uid" : party.id]) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    }
                    
                    completion(.success(party))
                }
            }
        }
    }
    
    func getPartyBy(uid: String, completion: @escaping (Result<PartyModel, Error>) -> Void) {
        let docRef = partiesRef.document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let party = PartyModel(document: document) else {
                    completion(.failure(PartyError.cannotUnwrapToParty))
                    return
                }
                completion(.success(party))
            } else {
                completion(.failure(PartyError.cannotGetPartyInfo))
            }
        }
    }
    
    func searchPartiesWith(city: String? = nil, type: PartyType? = nil, date: Date? = nil, dateSign: QuerySign? = nil, maxGuestsLower: Int? = nil, maxGuestsUpper: Int? = nil, priceType: PriceType? = nil, priceLower: Int? = nil, priceUpper: Int? = nil, completion: @escaping (Result<[PartyModel], Error>) -> Void) {
        
        var query: Query = db.collection("parties")
        
        if let city = city, city != "Любой" { query = query.whereField("city", isEqualTo : city) }
        if let type = type { query = query.whereField("type", isEqualTo : type.rawValue) } // WORKING 
        if let dateSign = dateSign {
            switch dateSign {
                
            case .isGreaterThanOrEqualTo:
                if let date = date { query = query.whereField("date", isGreaterThanOrEqualTo: date) }
            case .isLessThanOrEqualTo:
                if let date = date { query = query.whereField("date", isLessThanOrEqualTo: date) }
            case .isEqual:
                if let date = date { query = query.whereField("date", isEqualTo : date) }
            }
            // WORKING
        }
        if let maxGuestsLower = maxGuestsLower, let maxGuestsUpper = maxGuestsUpper {
            print("asdasjdajsjdasjidasoijajisdas")
            query = query.whereField("maxGuests", isLessThanOrEqualTo: maxGuestsUpper)
            query = query.whereField("maxGuests", isGreaterThanOrEqualTo: maxGuestsLower)
        }
        if let priceType = priceType {
            query = query.whereField("priceType", isEqualTo: priceType.rawValue)
            if priceType == .money {
                if let priceLower = priceLower, let priceUpper = priceUpper {
                    query = query.whereField("moneyPrice", isGreaterThanOrEqualTo: priceLower)
                    query = query.whereField("moneyPrice", isLessThanOrEqualTo: priceUpper)
                }
            }
        }
        
        query = query.whereField("userId", isNotEqualTo: Auth.auth().currentUser!.uid)
        
//        query = query.order(by: <#T##String#>, descending: <#T##Bool#>)
        
        query.getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                completion(.failure(err))
            } else {
                
                var parties: [PartyModel] = []
                
                for document in querySnapshot!.documents {
                    //                    print("\(document.documentID) => \(document.data())")
                    
                    guard let party = PartyModel(document: document) else { return }
                    
                    parties.append(party)
                }
                
                completion(.success(parties))
            }
        }
    }
    
    func createWaitingGuest(receiver: String, message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let waitingPartiesReference = userRef.collection("waitingParties")
        
        let waitingGuestsReference = db.collection(["parties", receiver, "waitingGuests"].joined(separator: "/"))
        
        let guestRef = waitingGuestsReference.document(self.currentUser.id)
        
        let waitingGuestRequest = PartyRequestModel(userId: self.currentUser.id, message: message)
        
        guestRef.setData(waitingGuestRequest.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            waitingPartiesReference.document(receiver).setData(waitingGuestRequest.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
            }
            
            completion(.success(Void()))
        }
    }
    
    // ToDO - Костыльно сделано: провека на то что дата в документе не нил
    func checkWaitingGuest(receiver: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection(["parties", receiver, "waitingGuests"].joined(separator: "/"))
        let guestRef = reference.document(self.currentUser.id)
        
        guestRef.getDocument { (document, error) in
            if let error = error {
                
                completion(.failure(error))
                return
            }
            
            guard document?.data() != nil else {
                return
            }
            
            completion(.success(Void()))
        }
    }
    
    func getApprovedGuestsId(party: PartyModel, completion: @escaping (Result<[String], Error>) -> Void) {
        let reference = db.collection(["parties", party.id, "approvedGuests"].joined(separator: "/"))
        
        reference.getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                completion(.failure(err))
            } else {
                
                var usersId: [String] = []
                
                for document in querySnapshot!.documents {
                    
                    guard let userId = document.data()["uid"] as? String else { return }
                    
                    usersId.append(userId)
                }
                
                guard usersId != [] else {
                    completion(.failure(PartyError.noApprovedGuests))
                    return
                }
                
                completion(.success(usersId))
            }
        }
    }
    
    func getWaitingGuestsRequests(party: PartyModel, completion: @escaping (Result<[PartyRequestModel], Error>) -> Void) {
        let reference = db.collection(["parties", party.id, "waitingGuests"].joined(separator: "/"))
        
        reference.getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                completion(.failure(err))
            } else {
                
                var waitingGuestsRequests: [PartyRequestModel] = []
                
                for document in querySnapshot!.documents {
                    
                    guard let waitingGuestRequest = PartyRequestModel(document: document) else { return }
                    
                    waitingGuestsRequests.append(waitingGuestRequest)
                }
                
                guard waitingGuestsRequests != [] else {
                    completion(.failure(PartyError.noWaitingGuests))
                    return
                }
                
                completion(.success(waitingGuestsRequests))
            }
        }
    }
    
    func deleteWaitingGuest(user: UserModel, party: PartyModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let userId = user.id
        let partyId = party.id
        
        let waitingPartiesReference = usersRef.document(userId).collection("waitingParties")
        
        let waitingGuestsReference = db.collection(["parties", partyId, "waitingGuests"].joined(separator: "/"))
        
        let guestRef = waitingGuestsReference.document(userId)
        
        guestRef.delete() { err in
            if let err = err {
                completion(.failure(err))
                print("Error removing document: \(err)")
            }
            
            waitingPartiesReference.document(partyId).delete() { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
            }
            
            completion(.success(Void()))
            print("Document successfully removed!")
        }
    }
    
    func changeToApproved(user: UserModel, party: PartyModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let userId = user.id
        let partyId = party.id
        
        let approvedPartiesReference = usersRef.document(userId).collection("approvedParties")
        let approvedGuestsReference = db.collection(["parties", partyId, "approvedGuests"].joined(separator: "/"))
        
        let waitingPartiesReference = usersRef.document(userId).collection("waitingParties")
        let waitingGuestsReference = db.collection(["parties", partyId, "waitingGuests"].joined(separator: "/"))
        
        let waitingGuestRef = waitingGuestsReference.document(userId)
        
        waitingGuestRef.delete() { err in
            if let err = err {
                completion(.failure(err))
                print("Error removing document: \(err)")
            }
            
            waitingPartiesReference.document(partyId).delete() { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
            }
            
            approvedGuestsReference.addDocument(data: ["uid": userId], completion: { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                approvedPartiesReference.addDocument(data: ["uid": partyId]) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                    print("Guest will be change to approved!")
                }
            })
        }
    }
    
    func changeToRejected(user: UserModel, party: PartyModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let userId = user.id
        let partyId = party.id
        
        let approvedPartiesReference = usersRef.document(userId).collection("rejectedParties")
        let approvedGuestsReference = db.collection(["parties", partyId, "rejectedParties"].joined(separator: "/"))
        
        let waitingPartiesReference = usersRef.document(userId).collection("waitingParties")
        let waitingGuestsReference = db.collection(["parties", partyId, "waitingGuests"].joined(separator: "/"))
        
        let waitingGuestRef = waitingGuestsReference.document(userId)
        
        waitingGuestRef.delete() { err in
            if let err = err {
                completion(.failure(err))
                print("Error removing document: \(err)")
            }
            
            waitingPartiesReference.document(partyId).delete() { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
            }
            
            approvedGuestsReference.addDocument(data: ["uid": userId], completion: { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                approvedPartiesReference.addDocument(data: ["uid": partyId]) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                    print("Guest will be change to rejected!")
                }
            })
        }
    }
    
    // MARK: - Will be need in future
    //    func getWaitingParties(completion: @escaping (Result<[Party], Error>) -> Void) {
    //
    //        var query: Query = db.collection("parties").document().collection("waitingGuests")
    //
    //        query = query.whereField("uid", isEqualTo : self.currentUser.id)
    //
    //        query.getDocuments() { (querySnapshot, err) in
    //
    //            if let err = err {
    //                completion(.failure(err))
    //            } else {
    //
    //                var parties: [Party] = []
    //
    //                for document in querySnapshot!.documents {
    //
    //                    guard let party = Party(document: document) else { return }
    //
    //                    print(party)
    //                    parties.append(party)
    //                }
    //
    //                completion(.success(parties))
    //            }
    //        }
    //    }
    
    func setOnline(status: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        userRef.updateData([
            "isOnline": status,
        ]) { err in
            if let err = err {
                completion(.failure(err))
                print("Error updating document: \(err)")
            } else {
                completion(.success(Void()))
                print("Document successfully updated")
            }
        }
    }
    
    // MARK: - Chat funcs
    func createWaitingChat(message: String, receiver: UserModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        let messageRef = reference.document(self.currentUser.id).collection("messages")
 
        let message = MessageModel(user: currentUser, content: message)
        
        let chatRoomId = chatRoomIdFrom(user1Id: self.currentUser.id, user2Id: receiver.id)
        let chat = RecentChatModel(chatRoomId: chatRoomId, senderId: self.currentUser.id, senderName: self.currentUser.username, receiverId: receiver.id, receiverName: receiver.username, lastMessageContent: message.content, memberIds: [currentUser.id, receiver.id], unreadCounter: 1, avatarLink: currentUser.avatarStringURL)
        
        reference.document(currentUser.id).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            messageRef.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(Void()))
            }
        }
    }
    
    func deleteWaitingChat(chat: ChatModel, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsRef.document(chat.friendId).delete { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteMessages(chat: chat, completion: completion)
        }
    }
    
    func deleteMessages(chat: ChatModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else { return }
                    let messageRef = reference.document(documentId)
                    messageRef.delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getWaitingChatMessages(chat: ChatModel, completion: @escaping (Result<[MessageModel], Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        var messages = [MessageModel]()
        reference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                guard let message = MessageModel(document: document) else { return }
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    func changeToActive(chat: ChatModel, completion: @escaping (Result<Void, Error>) -> Void) {
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            
            case .success(let messages):
                self.deleteWaitingChat(chat: chat) { (result) in
                    switch result {
                    
                    case .success():
                        self.createActiveChat(chat: chat, messages: messages) { (result) in
                            switch result {
                            
                            case .success():
                                completion(.success(Void()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func createActiveChat(chat: ChatModel, messages: [MessageModel], completion: @escaping (Result<Void, Error>) -> Void) {
        let messageRef = activeChatsRef.document(chat.friendId).collection("messages")
        activeChatsRef.document(chat.friendId).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            for message in messages {
                messageRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    completion(.success(Void()))
                }
            }
        }
    }
    
    func createChat(user1: UserModel, user2: UserModel, completion: @escaping (Result<String, Error>) -> Void) {
        let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)

        createRecentItems(chatRoomId: chatRoomId, users: [user1, user2], completion: completion)
    }
    
    func recreateChat(chatRoomId: String, memberIds: [String], completion: @escaping (Result<String, Error>) -> Void) {
        getUsers(by: memberIds) { result in
            switch result {
            
            case .success(let users):
                if users.count > 0 {
                    self.createRecentItems(chatRoomId: chatRoomId, users: users) { result in
                        switch result {
                        
                        case .success(_):
                            completion(.success(""))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func createRecentItems(chatRoomId: String, users: [UserModel], completion: @escaping (Result<String, Error>) -> Void) {
        
        var memberIdsToCreateRecent = [users.first!.id, users.last!.id]
        
        recentChatsRef.whereField("chatRoomId", isEqualTo: chatRoomId).getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                memberIdsToCreateRecent = self.removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
            }
            
            for userId in memberIdsToCreateRecent {
                
                print("asdoikasidojad: ", userId)
                let senderUser = userId == (AuthService.shared.currentUser!.id) ? AuthService.shared.currentUser! : self.getReceiverFrom(users: users)
                
                let receiverUser = userId == (AuthService.shared.currentUser!.id) ? self.getReceiverFrom(users: users) : AuthService.shared.currentUser!
                
                let recentObject = RecentChatModel(chatRoomId: chatRoomId, senderId: senderUser.id, senderName: senderUser.username, receiverId: receiverUser.id, receiverName: receiverUser.username, lastMessageContent: "", memberIds: [senderUser.id, receiverUser.id], unreadCounter: 0, avatarLink: receiverUser.avatarStringURL)
                
                self.saveRecent(recent: recentObject) { result in
                    switch result {
                    
                    case .success(_):
                        completion(.success(chatRoomId))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func saveRecent(recent: RecentChatModel, completion: @escaping (Result<String, Error>) -> Void) {
        self.recentChatsRef.document(recent.id).setData(recent.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(""))
        }
    }
    
    private func getReceiverFrom(users: [UserModel]) -> UserModel {
        var allUsers = users
        
        allUsers.remove(at: allUsers.firstIndex(of: AuthService.shared.currentUser!)!)
        
        return allUsers.first!
    }
    
    private func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
        var memberIdsToCreateRecent = memberIds
        
        for recentData in snapshot.documents {
            
            let currentRecent = recentData.data() as Dictionary
            
            if let currentUserId = currentRecent["senderId"] as? String {
                if memberIdsToCreateRecent.contains(currentUserId) {
                    memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId)!)
                }
            }
        }
        
        return memberIdsToCreateRecent
    }
    
    private func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
        
        var chatRoomId = ""
        
        let value = user1Id.compare(user2Id).rawValue
        
        chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
        
        return chatRoomId
    }
    
    func deleteRecentChat(_ recent: RecentChatModel) {
        recentChatsRef.document(recent.id).delete()
    }
    
    func clearUnreadCounter(recent: RecentChatModel, completion: @escaping (Result<String, Error>) -> Void) {
        var newRecent = recent
        
        newRecent.unreadCounter = 0
        
        self.saveRecent(recent: recent, completion: completion)
    }
    
    func resetRecentCounter(chatRoomId: String, completion: @escaping (Result<String, Error>) -> Void) {
        recentChatsRef.whereField("chatRoomId", isEqualTo: chatRoomId).whereField("senderId", isEqualTo: currentUser.id).getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                print("ERROR_LOG no documents for recent with chat room: \(chatRoomId)")
                completion(.failure(ChatErrors.noDocForRecent))
                return
            }
            
            let allRecents = documents.compactMap { queryDocumentSnapshot in
                return RecentChatModel(document: queryDocumentSnapshot)
            }
            
            if allRecents.count > 0 {
                self.clearUnreadCounter(recent: allRecents.first!, completion: completion)
            }
        }
    }
    
    // MARK: - Messages
    func sendMessage(chat: ChatModel, message: MessageModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendRef = usersRef.document(chat.friendId).collection("activeChats").document(currentUser.id) // Добрались до активного чата со мной до активного друга
        
        let friendMessageRef = friendRef.collection("messages")
        let myMessageRef = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendId).collection("messages")
        
        // Отзеркаливаем друга и currentUser
        let chatForFriend = ChatModel(friendUsername: currentUser.username, friendAvatarStringUrl: currentUser.avatarStringURL, lastMessageContent: message.content, friendId: currentUser.id)
        
        friendRef.setData(chatForFriend.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            friendMessageRef.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                myMessageRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    completion(.success(Void()))
                }
            }
        }
    }
    
    // MARK: Add, Update, Delete messages
    func addMessage(_ message: LocalMessage, memberId: String, completion: @escaping (Result<Void, Error>) -> Void) {
            messagesRef.document(memberId).collection(message.chatRoomId).document(message.id).setData(message.representation) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
}
