//
//  AuthenticatedUser.swift
//  App
//
//  Created by Zoltán Páll on 04/04/2019.
//

import Vapor

struct AuthenticatedUser: Decodable {
    var email: String
    var token: String
}

extension AuthenticatedUser: Content {}
