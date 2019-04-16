import Vapor
import Random
import Crypto

/// Controls basic CRUD operations on `User`s.
final class UserController {

    /// Saves a decoded `NewUser` to the database.
    func create(_ req: Request) throws -> Future<AuthenticatedUser> {

        return try req.content.decode(NewUser.self).flatMap({ newUser in

            return User.query(on: req).filter(\.email, .equal, newUser.email).first().flatMap({ firstUser in

                guard firstUser == nil else {
                    throw Abort(.badRequest,
                                reason: "A user with this email already exists",
                                identifier: nil)
                }

                let digest = try req.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUser.password)
                let user = User(id: nil, email: newUser.email, passwordHash: hashedPassword)

                return user.save(on: req).flatMap({ savedUser in
                    let tokenString = try URandom().generateData(count: 32).base64EncodedString()
                    let token = UserToken(id: nil, string: tokenString, userID: savedUser.id!)

                    return token.save(on: req).map({ savedToken in
                        return AuthenticatedUser(email: user.email, token: tokenString)
                    })
                })
            })
        })
    }

    func password(_ req: Request) throws -> Future<String> {

        let emailAddress = try req.parameters.next(String.self)

        return User.query(on: req).filter(\.email, .equal, emailAddress).first().map({ user -> String in

            guard let user = user else {
                throw Abort(.badRequest,
                            reason: "A user with this email doesn't exists",
                            identifier: nil)
            }

            return user.passwordHash
        })
    }
}
