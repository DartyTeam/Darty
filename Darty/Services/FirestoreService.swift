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
                         sex: Sex,
                         birthday: Date,
                         interestsList: [Int],
                         completion: @escaping (Result<UserModel, Error>) -> Void) {

        var user = UserModel(username: username,
                              phone: phone,
                              avatarStringURL: "",
                              description: description,
                              sex: sex.rawValue,
                              birthday: birthday,
                              interestsList: interestsList,
                              personalColor: "",
                              id: id)
        
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
    
    func createWaitingChat(message: String, receiver: UserModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        let messageRef = reference.document(self.currentUser.id).collection("messages")
        
        let message = MessageModel(user: currentUser, content: message)
        let chat = ChatModel(friendUsername: currentUser.username,
                         friendAvatarStringUrl: currentUser.avatarStringURL,
                         lastMessageContent: message.content,
                         friendId: currentUser.id)
        
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
    
    private var partiesRef: CollectionReference {
        return db.collection("parties")
    }
    
    func savePartyWith(party: SetuppedParty,
                       completion: @escaping (Result<PartyModel, Error>) -> Void) {

        let partyId = UUID().uuidString
        
        var imagesUrlStrings: [String] = []
        let dg = DispatchGroup()
        for partyImage in party.images {
            dg.enter()
            StorageService.shared.uploadPartyImage(photo: partyImage, partyId: partyId) { (result) in
                switch result {
                case .success(let url):
                    imagesUrlStrings.append(url.absoluteString)
                case .failure(let error):
                    completion(.failure(error))
                }
                
                dg.leave()
            }
        }

        dg.notify(queue: .main) {
            // Сохранение данных в Firestore
            let party = PartyModel(city: party.city, location: party.location, userId: party.userId, imageUrlStrings: imagesUrlStrings, type: party.type.rawValue, maxGuests: party.maxGuests, curGuests: 0, id: partyId, date: party.date, startTime: party.startTime, endTime: party.endTime, name: party.name, moneyPrice: party.moneyPrice, anotherPrice: party.anotherPrice, priceType: party.priceType.rawValue, description: party.description, minAge: party.minAge)
            
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
                print("v8v87vvy7vuiybgiibybyu: ", uid)
                completion(.success(party))
            } else {
                print("asdjasdoiasjd: ", uid)
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
        
        print("saidojaisdjasidojasdiasjdaiosdj: ", Auth.auth().currentUser!.uid)
//        query = query.whereField("userId", isNotEqualTo: Auth.auth().currentUser!.uid)
        
        print("sdjoasiodjaiosoidjas: ", query)
        
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
        
        guestRef.setData(["uid": self.currentUser.id]) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            waitingPartiesReference.document(receiver).setData(["uid": receiver, "message": message]) { (error) in
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
    
    func getWaitingGuestsId(party: PartyModel, completion: @escaping (Result<[String], Error>) -> Void) {
        let reference = db.collection(["parties", party.id, "waitingGuests"].joined(separator: "/"))
        
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
                    completion(.failure(PartyError.noWaitingGuests))
                    return
                }
                
                completion(.success(usersId))
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
}
