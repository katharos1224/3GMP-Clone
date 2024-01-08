//
//  NetworkManager.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 31/12/2023.
//

import Moya

enum APIError: Error, Codable {
    case invalidURL
    case noData
    case encodingError
    case decodingError
    case requestFailed(String)
    case serverError(String)
    case noToken
}

enum APIService {
    case provinces, homepage, cart, category
    case agency(provinceID: Int)
    case addCart(id: Int, number: Int)
    case voucher(cartIDs: [Int])
    case discount(cartIDs: [Int], coinStatus: Int, voucherValue: String)
    case codPayment(params: Payment)
    case onlinePayment(params: Payment)
    case categoryType(type: String, page: Int, search: String?)
    case product(page: Int?, category: String?, search: String?, hoatChat: Int?, nhomThuoc: Int?, nhaSanXuat: Int?, hastag: Int?)
    case search(search: String?)
    case login(username: String, password: String)
    case loginCustomer(username: String, password: String)
    case register(registerRequest: Pharmacy, fileData: Data?)
    case registerCustomer(registerRequest: Customer, fileData: Data?)
    case history(page: Int?)
    case historyDetail(id: Int, page: Int?)
    case contact
}

extension APIService: TargetType {
    var baseURL: URL {
        return URL(string: "http://18.138.176.213/api/v2/")!
    }

    var path: String {
        switch self {
        case .provinces:
            return "system/provinces"
        case .agency:
            return "system/provinces/agency_list"
        case .login:
            return "member/login"
        case .loginCustomer:
            return "customer/login"
        case .register:
            return "member/register"
        case .registerCustomer:
            return "customer/register"
        case .homepage:
            return "system/homepage"
        case .addCart:
            return "cart/update"
        case .cart:
            return "cart/index"
        case .voucher:
            return "cart/list_voucher"
        case .discount:
            return "cart/discount"
        case .codPayment, .onlinePayment:
            return "cart/payment"
        case .category:
            return "system/category"
        case .categoryType:
            return "system/category_type"
        case .product:
            return "product/index"
        case .search:
            return "search"
        case .history:
            return "history/payment"
        case .historyDetail:
            return "history/payment_details"
        case .contact:
            return "system/contact"
        }
    }

    var method: Moya.Method {
        switch self {
        case .provinces, .agency, .homepage, .voucher, .category, .contact:
            return .get
        case .login, .loginCustomer, .register, .registerCustomer, .addCart, .cart, .discount, .codPayment, .onlinePayment, .categoryType, .product, .search, .history, .historyDetail:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .provinces:
            return .requestPlain

        case let .agency(provinceID):
            return .requestParameters(parameters: ["province_id": provinceID], encoding: URLEncoding.default)

        case let .login(username, password):
            return .requestParameters(parameters: ["username": username, "password": password], encoding: JSONEncoding.default)

        case let .loginCustomer(username, password):
            return .requestParameters(parameters: ["username": username, "password": password], encoding: JSONEncoding.default)

        case let .register(registerRequest, fileData):
            var formData: [Moya.MultipartFormData] = []
            let mirror = Mirror(reflecting: registerRequest)

            for child in mirror.children {
                guard let key = child.label, let value = child.value as? String else {
                    continue
                }

                formData.append(MultipartFormData(provider: .data(value.data(using: .utf8)!),
                                                  name: key))
            }

            if let imageData = fileData {
                formData.append(MultipartFormData(provider: .data(imageData),
                                                  name: "img",
                                                  fileName: "image.jpg",
                                                  mimeType: "image/jpeg"))
            }

            return .uploadMultipart(formData)

        case let .registerCustomer(registerRequest, fileData):
            var formData: [Moya.MultipartFormData] = []
            let mirror = Mirror(reflecting: registerRequest)

            for child in mirror.children {
                guard let key = child.label, let value = child.value as? String else {
                    continue
                }

                formData.append(MultipartFormData(provider: .data(value.data(using: .utf8)!), name: key))
            }

            if let imageData = fileData {
                formData.append(MultipartFormData(provider: .data(imageData),
                                                  name: "img",
                                                  fileName: "image.jpg",
                                                  mimeType: "image/jpeg"))
            }

            return .uploadMultipart(formData)

        case .homepage:
            return .requestPlain

        case let .addCart(id, number):
            return .requestParameters(parameters: ["id": id, "number": number as Any], encoding: JSONEncoding.default)

        case .cart:
            return .requestPlain

        case let .voucher(cartIDs):
            let productIDQueryItems = cartIDs.map { ["data_id[]": "\($0)"] }
            let parameters = ["data_id": productIDQueryItems]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

        case let .discount(cartIDs, coinStatus, voucherValue):
            let parameters: [String: Any] = [
                "data_id": cartIDs,
                "coin": coinStatus,
                "voucher": voucherValue,
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case let .codPayment(params), let .onlinePayment(params):
            var parameters: [String: Any] = [
                "device": params.device,
                "ten": params.ten,
                "sdt": params.sdt,
                "email": params.email ?? "",
                "dia_chi": params.diaChi,
                "ma_so_thue": params.maSoThue ?? "",
                "ghi_chu": params.ghiChu ?? "",
                "ck_truoc": params.ckTruoc,
                "voucher": params.voucher ?? "",
                "coin": params.coin,
                "total_price": params.totalPrice,
            ]
            let cartsParams: [String: Any] = params.dataId.enumerated().reduce(into: [:]) { result, element in
                let (index, value) = element
                result["data_id[\(index)]"] = value
            }
            parameters.merge(cartsParams) { _, new in new }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

        case .category:
            return .requestPlain

        case let .categoryType(type, page, search):
            let parameters: [String: Any] = ["type": type, "page": page, "search": search as Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case let .product(page, category, search, hoatChat, nhomThuoc, nhaSanXuat, hastag):
            var parameters: [String: Any] = [:]

            if let page = page { parameters["page"] = page }
            if let category = category { parameters["category"] = category }
            if let search = search { parameters["search"] = search }
            if let hoatChat = hoatChat { parameters["hoat_chat"] = hoatChat }
            if let nhomThuoc = nhomThuoc { parameters["nhom_thuoc"] = nhomThuoc }
            if let nhaSanXuat = nhaSanXuat { parameters["nha_san_xuat"] = nhaSanXuat }
            if let hastag = hastag { parameters["hastag"] = hastag }
            
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case let .search(search):
            return .requestParameters(parameters: ["search": search as Any], encoding: JSONEncoding.default)
            
        case let .history(page):
            var parameters: [String: Any] = [:]

            if let page = page { parameters["page"] = page }
            
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case let .historyDetail(id, page):
            return .requestParameters(parameters: ["id": id, "page": page as Any], encoding: JSONEncoding.default)
        case .contact:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        guard let userToken = KeychainService.getToken() else {
            return ["Content-Type": "application/json"]
        }

        return ["Authorization": "Bearer \(userToken)", "Content-Type": "application/json"]
    }
}

class NetworkManager {
    static let shared: NetworkManager = .init()
    private let provider: MoyaProvider<APIService>

    private init() {
        provider = MoyaProvider<APIService>()
    }

    private func request<T: Decodable>(endpoint: APIService, completion: @escaping (Result<T, APIError>) -> Void) {
        provider.request(endpoint) { result in
            switch result {
            case let .success(response):
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(T.self, from: response.data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(.decodingError))
                }

            case let .failure(error):
                completion(.failure(.requestFailed(error.localizedDescription)))
            }
        }
    }

    // MARK: - Database Service
    
    // Info
    func fetchProvinces(completion: @escaping (Result<ProvincesData, APIError>) -> Void) {
        let endpoint = APIService.provinces
        request(endpoint: endpoint, completion: completion)
    }

    func fetchAgency(provinceID: Int, completion: @escaping (Result<AgenciesData, APIError>) -> Void) {
        let endpoint = APIService.agency(provinceID: provinceID)
        request(endpoint: endpoint, completion: completion)
    }

    // Homepage
    func fetchHomepage(completion: @escaping (Result<HomepageResponse, APIError>) -> Void) {
        let endpoint = APIService.homepage
        request(endpoint: endpoint, completion: completion)
    }

    // Cart
    func updateCart(id: Int, number: Int, completion: @escaping (Result<AddedProductsResponse, APIError>) -> Void) {
        let endpoint = APIService.addCart(id: id, number: number)
        request(endpoint: endpoint, completion: completion)
    }

    func fetchCart(completion: @escaping (Result<CartResponse, APIError>) -> Void) {
        let endpoint = APIService.cart
        request(endpoint: endpoint, completion: completion)
    }
    
    func fetchVouchers(cartIDs: [Int], completion: @escaping (Result<VoucherResponse, APIError>) -> Void) {
        let endpoint = APIService.voucher(cartIDs: cartIDs)
        request(endpoint: endpoint, completion: completion)
    }

    func fetchDiscount(cartIDs: [Int], coinStatus: Int, voucherValue: String, completion: @escaping (Result<DiscountResponse, APIError>) -> Void) {
        let endpoint = APIService.discount(cartIDs: cartIDs, coinStatus: coinStatus, voucherValue: voucherValue)
        request(endpoint: endpoint, completion: completion)
    }

    // Payment
    func fetchCODPayment(params: Payment, completion: @escaping (Result<CODPaymentResponse, APIError>) -> Void) {
        let endpoint = APIService.codPayment(params: params)
        request(endpoint: endpoint, completion: completion)
    }

    func fetchOnlinePayment(params: Payment, completion: @escaping (Result<OnlinePaymentResponse, APIError>) -> Void) {
        let endpoint = APIService.onlinePayment(params: params)
        request(endpoint: endpoint, completion: completion)
    }

    // Category
    func fetchCategory(completion: @escaping (Result<CategoryResponse, APIError>) -> Void) {
        let endpoint = APIService.category
        request(endpoint: endpoint, completion: completion)
    }

    func fetchProducts(page: Int?, category: String?, search: String?, hoatChat: Int?, nhomThuoc: Int?, nhaSanXuat: Int?, hastag: Int?, completion: @escaping (Result<CategoryProducts, APIError>) -> Void) {
        let endpoint = APIService.product(page: page, category: category, search: search, hoatChat: hoatChat, nhomThuoc: nhomThuoc, nhaSanXuat: nhaSanXuat, hastag: hastag)
        request(endpoint: endpoint, completion: completion)
    }

    func fetchCategoryType(type: String, page: Int, search: String?, completion: @escaping (Result<CategoryDetailResponse, APIError>) -> Void) {
        let endpoint = APIService.categoryType(type: type, page: page, search: search)
        request(endpoint: endpoint, completion: completion)
    }

    // Search
    func fetchSearchResult(search: String?, completion: @escaping (Result<SearchResult, APIError>) -> Void) {
        let endpoint = APIService.search(search: search)
        request(endpoint: endpoint, completion: completion)
    }
    
    // History
    func fetchHistory(page: Int?, completion: @escaping (Result<OrderHistoryResponse, APIError>) -> Void) {
        let endpoint = APIService.history(page: page)
        request(endpoint: endpoint, completion: completion)
    }
    
    func fetchOrderDetail(id: Int, page: Int?, completion: @escaping (Result<OrderDetailResponse, APIError>) -> Void) {
        let endpoint = APIService.historyDetail(id: id, page: page)
        request(endpoint: endpoint, completion: completion)
    }
    
    func fetchContact(completion: @escaping (Result<ContactInfo, APIError>) -> Void) {
        let endpoint = APIService.contact
        request(endpoint: endpoint, completion: completion)
    }

    // MARK: - Authentication Service

    // Register
    func register(registerRequest: Pharmacy, fileData: Data?, completion: @escaping (Result<PharmacyRegisterResponse, APIError>) -> Void) {
        let endpoint = APIService.register(registerRequest: registerRequest, fileData: fileData)
        request(endpoint: endpoint, completion: completion)
    }

    func registerCustomer(registerRequest: Customer, fileData: Data?, completion: @escaping (Result<CustomerRegisterResponse, APIError>) -> Void) {
        let endpoint = APIService.registerCustomer(registerRequest: registerRequest, fileData: fileData)
        request(endpoint: endpoint, completion: completion)
    }

    // Login
    func login(username: String, password: String, completion: @escaping (Result<PharmacyLoginResponse, APIError>) -> Void) {
        let endpoint = APIService.login(username: username, password: password)
        request(endpoint: endpoint, completion: completion)
    }

    func loginCustomer(username: String, password: String, completion: @escaping (Result<CustomerLoginResponse, APIError>) -> Void) {
        let endpoint = APIService.loginCustomer(username: username, password: password)
        request(endpoint: endpoint, completion: completion)
    }
}