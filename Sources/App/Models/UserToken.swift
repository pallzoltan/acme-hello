//
//  UserToken.swift
//  Acme-HelloPackageDescription
//
//  Created by Zoltán Páll on 04/04/2019.
//

import Authentication
import FluentSQLite
import Vapor

struct UserToken: SQLiteModel {
    var id: Int?
    var string: String
    var userID: User.ID

    var user: Parent<UserToken, User> {
        return parent(\.userID)
    }
}

extension UserToken: Token {
    /// See `Token`.
    typealias UserType = User

    /// See `Token`.
    static var tokenKey: WritableKeyPath<UserToken, String> {
        return \.string
    }

    /// See `Token`.
    static var userIDKey: WritableKeyPath<UserToken, User.ID> {
        return \.userID
    }
}
