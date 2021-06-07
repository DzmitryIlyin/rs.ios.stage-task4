import Foundation

final class CallStation {
    var usersArray = [User]()
    var callsArray = [Call]()
}

extension CallStation: Station {
    
    func calls(user: User) -> [Call] {
        return callsArray.filter{$0.incomingUser.id == user.id || $0.outgoingUser.id == user.id}
    }
    
    func users() -> [User] {
        return usersArray
    }
    
    func add(user: User) {
        if !usersArray.contains(where: {$0.id == user.id}) {
            usersArray.append(user)
        }
    }
    
    func remove(user: User) {
        if usersArray.contains(where: {$0.id == user.id}) {
            usersArray.removeAll(where: {$0.id == user.id})
        }
    }
    
    func execute(action: CallAction) -> CallID? {
        
        var callID: CallID?
        var status = CallStatus.ended(reason: .error)
        var currentUserType: (userType: UserType, incomingUser: User?, outgoingUser: User?) = (.none, nil, nil)
        
        switch action {
        case .start(let outgoingUser, let incomingUser):
            currentUserType = (.none, incomingUser, outgoingUser)
            
            if areAllUsersAdded(incomingUser: currentUserType.incomingUser!, outgoingUser: currentUserType.outgoingUser!) {
                callID = CallID()
                status = calls(user: incomingUser).count >= 1 ? .ended(reason: .userBusy) : .calling
            }
            
        case .answer(let user):
            let currentCall = currentCall(user: user)
            currentUserType = userType(currentCall!, user)
            
            if areAllUsersAdded(incomingUser: currentUserType.incomingUser!, outgoingUser: currentUserType.outgoingUser!) {
                status = .talk
            }
            
            callID = currentCall?.id
            
        case .end(let user):
            let currentCall = currentCall(user: user)
            currentUserType = userType(currentCall!, user)
            
            if currentCall?.status == .calling {
                status = .ended(reason: .cancel)
            } else if currentCall?.status == .talk {
                status = .ended(reason: .end)
            } else if currentCall == nil {
                status = .ended(reason: .userBusy)
            }
            
            callID = currentCall?.id
            
        }
        
        if currentUserType.userType != .none {
            cleanPreviousCallState(userType: currentUserType.userType, user: currentUserType.incomingUser!)
        }
        
        callsArray.append(Call(id: callID, incomingUser: currentUserType.incomingUser!, outgoingUser: currentUserType.outgoingUser!, status: status))
        
        return status != .ended(reason: .error) ? callID : nil
    }
    
    private func areAllUsersAdded(incomingUser: User, outgoingUser: User) -> Bool {
        return usersArray.contains(where: {$0.id == incomingUser.id}) && usersArray.contains(where: {$0.id == outgoingUser.id})
    }

    private func cleanPreviousCallState(userType: UserType, user: User) {
        if userType == .incoming {
            callsArray.removeAll{ $0.incomingUser.id == user.id }
        } else {
            callsArray.removeAll{ $0.outgoingUser.id == user.id }
        }
    }
    
    func calls() -> [Call] {
        return callsArray
    }
    
    private func userType(_ currenCall: Call, _ user: User) -> (UserType, User, User) {
        if currenCall.incomingUser.id == user.id {
            return (UserType.incoming, user, currenCall.outgoingUser)
        } else {
            return (UserType.outgoing, user, currenCall.incomingUser)
        }
    }
    
    func call(id: CallID) -> Call? {
        return callsArray.first{$0.id == id}
    }
    
    func currentCall(user: User) -> Call? {
        if let call = callsArray.first(where: { ($0.incomingUser.id == user.id || $0.outgoingUser.id == user.id) && ($0.status == .calling || $0.status == .talk)}) {
            return call
        } else {
            return nil
        }
    }
    
    private enum UserType {
        case incoming
        case outgoing
        case none
    }
}
