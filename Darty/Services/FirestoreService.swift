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
    
    private init () {}
    
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
        docRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                guard let user = UserModel(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToUserModel))
                    return
                }
                completion(.success(user))
                self?.currentUser = user
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
                         city: String,
                         country: String,
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
                              pushId: "",
                              city: city,
                              country: country)
        
        StorageService.shared.upload(photo: avatarImage!) { [weak self] (result) in
            switch result {
            
            case .success(let url):
                user.avatarStringURL = url.absoluteString
                
                // Сохранение данных в firestore
                self?.usersRef.document(user.id).setData(user.representation) { (error) in
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
    
    func updateUserInformation(userData: UserModel,
                               completion: @escaping (Result<Void, Error>) -> Void) {
        updateUserInformation(username: userData.username, birthday: userData.birthday, avatarStringURL: userData.avatarStringURL, sex: userData.sex, description: userData.description, personalColor: userData.personalColor, interestsList: userData.interestsList, instagramId: userData.instagramId, completion: completion)
    }
    
    func updateUserInformation(username: String,
                               birthday: Date,
                               avatarStringURL: String,
                               sex: String?,
                               description: String,
                               personalColor: String,
                               interestsList: [Int],
                               instagramId: String?,
                               completion: @escaping (Result<Void, Error>) -> Void) {
        userRef.updateData([
            "description": description,
            "sex": sex,
            "avatarStringURL": avatarStringURL,
            "birthday": birthday,
            "username": username,
            "personalColor": personalColor,
            "interestsList": interestsList,
            "instagramId": instagramId,
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
    
    func savePartyWith(party: CreateCoordinator.PartyInfo,
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

        dg.notify(queue: .main) { [weak self] in
            // Сохранение данных в Firestore
            let party = PartyModel(city: party.city, location: GeoPoint(latitude: party.latitude, longitude: party.longitude), address: party.address, userId: party.userId, imageUrlStrings: imagesUrlStrings, type: party.type.rawValue, maxGuests: party.maxGuests, curGuests: 0, id: partyId, date: party.date, startTime: party.startTime, endTime: party.endTime, name: party.name, moneyPrice: party.moneyPrice, anotherPrice: party.anotherPrice, priceType: party.priceType.rawValue, description: party.description, minAge: party.minAge)
            
            self?.partiesRef.document(party.id).setData(party.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                self?.userRef.collection("myParties").document(party.id).setData( ["uid" : party.id]) { (error) in
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
    
    func searchPartiesWith(
        city: String? = nil,
        type: PartyType? = nil,
        date: Date,
        dateSign: QuerySign? = nil,
        maxGuestsLower: Int? = nil,
        maxGuestsUpper: Int? = nil,
        priceType: PriceType? = nil,
        priceLower: Int? = nil,
        priceUpper: Int? = nil,
        isDateInSearch: Bool,
        isPriceInSearch: Bool,
        isGuestsInSearch: Bool,
        isUserIdInSearch: Bool,
        ascType: FilterManager.AscendingType,
        sortingType: FilterManager.SortingType,
        completion: @escaping (Result<[PartyModel], Error>) -> Void
    ) {
        
        var query: Query = db.collection("parties")
        
        if let city = city, city != "Любой" { query = query.whereField("city", isEqualTo : city) }
        if let type = type { query = query.whereField("type", isEqualTo : type.rawValue) } // WORKING 
        if let dateSign = dateSign {
            switch dateSign {
            case .isGreaterThanOrEqualTo:
                if isDateInSearch {
                    query = query.whereField("date", isGreaterThanOrEqualTo: date)
                }
            case .isLessThanOrEqualTo:
                if isDateInSearch {
                    query = query.whereField("date", isLessThanOrEqualTo: date)
                }
            case .isEqual:
                query = query.whereField("date", isEqualTo : date)
            }
            // WORKING
        }

        if isGuestsInSearch, let maxGuestsLower = maxGuestsLower, let maxGuestsUpper = maxGuestsUpper {
            query = query.whereField("maxGuests", isLessThanOrEqualTo: maxGuestsUpper)
            query = query.whereField("maxGuests", isGreaterThanOrEqualTo: maxGuestsLower)
        }

        if let priceType = priceType {
            query = query.whereField("priceType", isEqualTo: priceType.rawValue)
            if priceType == .money, isPriceInSearch, let priceLower = priceLower, let priceUpper = priceUpper {
                query = query.whereField("moneyPrice", isGreaterThanOrEqualTo: priceLower)
                query = query.whereField("moneyPrice", isLessThanOrEqualTo: priceUpper)
            }
        }

        if isUserIdInSearch {
            query = query.whereField("userId", isNotEqualTo: Auth.auth().currentUser!.uid)
        }

        switch sortingType {
        case .date:
            query = query.order(by: "date", descending: ascType == .desc)
        case .guests:
            query = query.order(by: "maxGuests", descending: ascType == .desc)
        case .price:
            query = query.order(by: "moneyPrice", descending: ascType == .desc)
        }
        
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
        
        let chatRoomId = chatRoomIdFrom(user1Id: self.currentUser.id, user2Id: receiver.id)

        let localMessage = LocalMessage()
        localMessage.id = UUID().uuidString
        localMessage.senderId = currentUser.id
        localMessage.senderName = currentUser.username
        localMessage.senderInitials = String(currentUser.username.first!)
        localMessage.date = Date()
        localMessage.status = GlobalConstants.kSENT
        localMessage.chatRoomId = chatRoomId
        localMessage.message = message
        
        recentChatsRef.whereField("receiverId", isEqualTo: receiver.id).whereField("senderId", isEqualTo: currentUser.id).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshot = snapshot else { return }
            print("aisdjaiodjasido: ", snapshot.isEmpty)
            if !snapshot.isEmpty {
                OutgoingMessage.send(chatId: chatRoomId, text: localMessage.message, photo: nil, video: nil, audio: nil, location: nil, memberIds: [self.currentUser.id, receiver.id]) { result in
                    switch result {
                    
                    case .success():
                        completion(.success(Void()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } else {
                let reference = self.db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
                let messageRef = reference.document(chatRoomId).collection("messages")
                
                let chat = RecentChatModel(chatRoomId: chatRoomId, senderId: self.currentUser.id, senderName: self.currentUser.username, receiverId: receiver.id, receiverName: receiver.username, lastMessageContent: localMessage.message, memberIds: [self.currentUser.id, receiver.id], unreadCounter: 1, avatarLink: self.currentUser.avatarStringURL)
                
                reference.document(chatRoomId).setData(chat.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    messageRef.document(localMessage.id).setData(localMessage.representation) { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            }
        }
    }
    
    func deleteWaitingChat(chat: RecentChatModel, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsRef.document(chat.chatRoomId).delete { [weak self] (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            self?.deleteMessages(chat: chat, completion: completion)
        }
    }
    
    func deleteMessages(chat: RecentChatModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.chatRoomId).collection("messages")
        
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            
            case .success(let messages):
                for message in messages {
                    
                    let documentId = message.id
                    let messageRef = reference.document(documentId)
                    messageRef.delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        if message == messages.last {
                            completion(.success(Void()))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getWaitingChatMessages(chat: RecentChatModel, completion: @escaping (Result<[LocalMessage], Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.chatRoomId).collection("messages")
        var messages = [LocalMessage]()
        reference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                guard let message = LocalMessage(document: document) else { return }
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    func changeToActive(chat: RecentChatModel, user1: UserModel, user2: UserModel, completion: @escaping (Result<Void, Error>) -> Void) {
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            
            case .success(let messages):
                print("asdokasdopaskdoapsdkasodkaodakdasodkasd: ", messages)
                self.deleteWaitingChat(chat: chat) { (result) in
                    switch result {
                    
                    case .success():
                        
                        self.createActiveChat(chat: chat, messages: messages, user1: user1, user2: user2) { (result) in
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
    
    func createActiveChat(chat: RecentChatModel, messages: [LocalMessage], user1: UserModel, user2: UserModel, completion: @escaping (Result<Void, Error>) -> Void) {
    
        let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
        createChat(user1: user1, user2: user2, lastMessage: messages.last?.message ?? " ", countMessages: messages.count) { [weak self] result in
            switch result {
            
            case .success(_):
          
                for message in messages {
                    RealmManager.shared.saveToRealm(message)
                    self?.messagesRef.document(user1.id).collection(chatRoomId).addDocument(data: message.representation) { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        self?.messagesRef.document(user2.id).collection(chatRoomId).addDocument(data: message.representation) { (error) in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }
                            
                            if message == messages.last {
                                completion(.success(Void()))
                            }
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createChat(user1: UserModel, user2: UserModel, lastMessage: String, countMessages: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)

        createRecentItems(chatRoomId: chatRoomId, users: [user1, user2], lastMessage: lastMessage, countMessages: countMessages, completion: completion)
    }
    
    func recreateChat(chatRoomId: String, memberIds: [String], lastMessage: String = "", countMessages: Int = 0, completion: @escaping (Result<String, Error>) -> Void) {
        getUsers(by: memberIds) { [weak self] result in
            switch result {
            
            case .success(let users):
                if users.count > 0 {
                    self?.createRecentItems(chatRoomId: chatRoomId, users: users, lastMessage: lastMessage, countMessages: countMessages) { result in
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
    
    private func createRecentItems(chatRoomId: String, users: [UserModel], lastMessage: String, countMessages: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        
        var memberIdsToCreateRecent = [users.first!.id, users.last!.id]
        
        recentChatsRef.whereField("chatRoomId", isEqualTo: chatRoomId).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                memberIdsToCreateRecent = self.removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
            }
            
            var recentIds: [String] = []
            for userId in memberIdsToCreateRecent {
                
                let senderUser = userId == (AuthService.shared.currentUser!.id) ? AuthService.shared.currentUser! : self.getReceiverFrom(users: users)
                
                let receiverUser = userId == (AuthService.shared.currentUser!.id) ? self.getReceiverFrom(users: users) : AuthService.shared.currentUser!
                
                let recentObject = RecentChatModel(chatRoomId: chatRoomId, senderId: senderUser.id, senderName: senderUser.username, receiverId: receiverUser.id, receiverName: receiverUser.username, lastMessageContent: lastMessage, memberIds: [senderUser.id, receiverUser.id], unreadCounter: countMessages, avatarLink: receiverUser.avatarStringURL)
                
                self.saveRecent(recent: recentObject) { result in
                    switch result {
                    
                    case .success(_):
                        recentIds.append(recentObject.id)
                        if userId == memberIdsToCreateRecent.last {
                            completion(.success(recentIds))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func saveRecent(recent: RecentChatModel, completion: ((Result<Void, Error>) -> Void)? = nil) {
        self.recentChatsRef.document(recent.id).setData(recent.representation) { (error) in
            if let error = error {
                completion?(.failure(error))
                return
            }
            
            completion?(.success(()))
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
    
    func updateRecents(chatRoomId: String, lastMessage: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        recentChatsRef.whereField(GlobalConstants.kCHATROOMID, isEqualTo: chatRoomId).getDocuments { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                completion?(.failure(ChatErrors.noDocForRecent))
                print("No documents for recent update")
                return
            }
            
            let allRecents = documents.compactMap { queryDocumentSnapshot in
                RecentChatModel(document: queryDocumentSnapshot)
            }
            
            for recentChat in allRecents {
                self?.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage, completion: completion)
            }
        }
    }
    
    private func updateRecentItemWithNewMessage(recent: RecentChatModel, lastMessage: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        var tempRecent = recent
        
        if tempRecent.senderId != currentUser.id {
            tempRecent.unreadCounter += 1
        }
        
        tempRecent.lastMessageContent = lastMessage
        tempRecent.date = Date()
        
        self.saveRecent(recent: tempRecent, completion: completion)
    }
    
    private func clearUnreadCounter(recent: RecentChatModel, completion: @escaping (Result<Void, Error>) -> Void) {
        var newRecent = recent
        
        newRecent.unreadCounter = 0
        
        self.saveRecent(recent: newRecent, completion: completion)
    }
    
    func resetRecentCounter(chatRoomId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        recentChatsRef.whereField("chatRoomId", isEqualTo: chatRoomId).whereField("senderId", isEqualTo: currentUser.id).getDocuments { [weak self] snapshot, error in
            
            guard let documents = snapshot?.documents else {
                print("ERROR_LOG no documents for recent with chat room: \(chatRoomId)")
                completion(.failure(ChatErrors.noDocForRecent))
                return
            }
            
            let allRecents = documents.compactMap { queryDocumentSnapshot in
                return RecentChatModel(document: queryDocumentSnapshot)
            }
            
            if allRecents.count > 0 {
                self?.clearUnreadCounter(recent: allRecents.first!, completion: completion)
            }
        }
    }
    
    // MARK: - Check for old chats
    func checkForOldChats(_ documentId: String, collectionId: String) {
        messagesRef.document(documentId).collection(collectionId).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("ERROR_LOG No documents for old chats")
                return
            }
            
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) in
                return LocalMessage(document: queryDocumentSnapshot)
            }
            
            oldMessages.sort(by: { $0.date < $1.date })
            
            for message in oldMessages {
                RealmManager.shared.saveToRealm(message)
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
    
    // MARK: - Update message status
    func updateMessageInFirebase(_ message: LocalMessage, memberIds: [String]) {
        let values = [GlobalConstants.kSTATUS: GlobalConstants.kREAD, GlobalConstants.kREADDATE: Date()] as [String : Any]
         
        for userId in memberIds {
            messagesRef.document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
        }
    }
}
