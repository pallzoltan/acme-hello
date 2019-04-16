import Authentication
import FluentSQLite
import Vapor

struct User: SQLiteModel {
    var id: Int?
    var email: String
    var passwordHash: String

    var tokens: Children<User, UserToken> {
        return children(\.userID)
    }
}

extension User: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = UserToken
}

extension User: Migration {}
