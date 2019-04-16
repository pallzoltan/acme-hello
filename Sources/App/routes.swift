import Vapor

var accessToken: String = ""

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let userController = UserController()
    router.post("register", use: userController.create)
    router.post("login", use: userController.login)

    router.get("password", String.parameter, use: userController.password)

    // Use user model to create an authentication middleware
    let token = User.tokenAuthMiddleware()

    // Create a route closure wrapped by this middleware
    router.grouped(token).get("hello", use: { request -> String in
        let user = try request.requireAuthenticated(User.self)
        return "Hello, \(user.email)."
    })



//    router.get("pay", use: { req -> Response in
//        var token: String!
//        do {
//            token = try req.query.get(String.self, at: "access_token")
//        } catch {
//            return req.redirect(to: "https://webapi.developers.erstegroup.com/api/csas/sandbox/v1/sandbox-idp/auth?redirect_uri=http://localhost:8080/code&client_id=73b6df1d-3743-49ac-acd1-ebba51676224&response_type=code&state=csas-auth")
//        }
//
//        //        let r = Response(http: HTTPResponse(), using: req.sharedContainer)
//        //        try r.content.encode(token)
//        //
//        //        return r
//
////
//        "https://webapi.developers.erstegroup.com/api/csas/sandbox/v1/payment-initiation/my/accounts?size=100&page=0&sort=iban&order=desc"
//    })
//
//    router.get("code", use: { req -> Future<Response> in
//
//        let code = try req.query.get(String.self, at: "code")
//
//        let headers = HTTPHeaders.init([("Content-Type", "application/x-www-form-urlencoded")])
//        let body = HTTPBody(string: "grant_type=authorization_code&code=\(code)&client_id=73b6df1d-3743-49ac-acd1-ebba51676224&client_secret=\(clientSecret)&redirect_uri=http%3A%2F%2Flocalhost:8080%2Fpay")
//
//        let httpRequest = HTTPRequest(method: .POST,
//                                      url: "https://webapi.developers.erstegroup.com/api/csas/sandbox/v1/sandbox-idp/token",
//                                      version: HTTPVersion(major: 1, minor: 1),
//                                      headers: headers,
//                                      body: body)
//
//        let exchangeRequest = Request(http: httpRequest, using: req.sharedContainer)
//        let exchangeResponse = try req.sharedContainer.client().send(exchangeRequest)
//
//        let map = exchangeResponse.flatMap({ response in
//            return try response.content.decode(TokenResponse.self)
//        })
//
//        return map.map({ (tokenResponse: TokenResponse) in
//            accessToken = tokenResponse.access_token
//
//            return req.redirect(to: "http://localhost:8080/pay?access_token=\(accessToken)")
//        })
//    })

}
