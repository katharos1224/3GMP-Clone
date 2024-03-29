import Foundation

/// These functions are default mappings to `MoyaProvider`'s properties: endpoints, requests, session etc.
public extension MoyaProvider {
    final class func defaultEndpointMapping(for target: Target) -> Endpoint {
        Endpoint(
            url: URL(target: target).absoluteString,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }

    final class func defaultRequestMapping(for endpoint: Endpoint, closure: RequestResultClosure) {
        do {
            let urlRequest = try endpoint.urlRequest()
            closure(.success(urlRequest))
        } catch let MoyaError.requestMapping(url) {
            closure(.failure(MoyaError.requestMapping(url)))
        } catch let MoyaError.parameterEncoding(error) {
            closure(.failure(MoyaError.parameterEncoding(error)))
        } catch {
            closure(.failure(MoyaError.underlying(error, nil)))
        }
    }

    final class func defaultAlamofireSession() -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default

        return Session(configuration: configuration, startRequestsImmediately: false)
    }
}
