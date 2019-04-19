import Vapor
import Random
import Crypto

/// Controls basic CRUD operations on `User`s.
final class UserController {

    /// Saves a decoded `UnauthenticatedUser` to the database.
    func create(_ req: Request) throws -> Future<AuthenticatedUser> {

        return try req.content.decode(UnauthenticatedUser.self).flatMap({ [weak self] newUser in

            return User.query(on: req).filter(\.email, .equal, newUser.email).first().flatMap({ firstUser in

                guard firstUser == nil else {
                    throw Abort(.badRequest,
                                reason: "A user with this email already exists.")
                }

                let digest = try req.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUser.password)
                let user = User(id: nil, email: newUser.email, passwordHash: hashedPassword)

                return user.save(on: req).flatMap({ savedUser in

                    guard let userID = savedUser.id else {
                        throw Abort(.internalServerError,
                                    reason: "Saved user has no ID.")
                    }

                    guard let self = self else {
                        throw Abort(.internalServerError,
                                    reason: "Reference to userController lost.")
                    }

                    return try self.generateToken(on: req, for: userID)
                })
            })
        })
    }

    func login(_ req: Request) throws -> Future<AuthenticatedUser> {
        return try req.content.decode(UnauthenticatedUser.self).flatMap({ [weak self] loginUser in

            return User.query(on: req).filter(\.email, .equal, loginUser.email).first().flatMap({ foundUser in

                let digest = try req.make(BCryptDigest.self)

                guard let self = self else {
                    throw Abort(.notFound,
                                reason: "Reference to userController lost.")
                }

                guard let foundUser = foundUser, let userID = foundUser.id else {
                    throw Abort(.notFound,
                                reason: "User doesn't exist.")
                }

                if try !digest.verify(loginUser.password, created: foundUser.passwordHash) {
                    throw Abort(.unauthorized,
                                reason: "Wrong credentials.")
                }

                return try self.generateToken(on: req, for: userID)
            })
        })
    }
}

extension UserController {

    func generateToken(on req: Request, for userID: Int) throws -> Future<AuthenticatedUser> {
        let tokenString = try URandom().generateData(count: 32).base64EncodedString()
        let token = UserToken(id: nil, string: tokenString, userID: userID)

        return token.save(on: req).map({ savedToken in
            return AuthenticatedUser(token: tokenString)
        })
    }

    func password(_ req: Request) throws -> Future<String> {

        let emailAddress = try req.parameters.next(String.self)

        return User.query(on: req).filter(\.email, .equal, emailAddress).first().map({ user -> String in

            guard let user = user else {
                throw Abort(.notFound,
                            reason: "A user with this email doesn't exists.")
            }

            return user.passwordHash
        })
    }
}
