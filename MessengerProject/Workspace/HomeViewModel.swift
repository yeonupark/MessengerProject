//
//  HomeViewModel.swift
//  MessengerProject
//
//  Created by Yeonu Park on 2024/01/17.
//

import Foundation
import Combine
import Moya

class HomeViewModel: ObservableObject {
    
    @Published var isEmptyView = true
    @Published var workspace: [WorkspacesResponseData] = []
    @Published var isLogout = true
    
    init() {
        
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let provider = MoyaProvider<MarAPI>()
    
    func fetchWorkspaces() {
        
        provider.request(.getWorkspaces) { result in
            switch result {
            case .success(let response):
                if (200..<300).contains(response.statusCode) {
                    
                    do {
                        let result = try JSONDecoder().decode([WorkspacesResponseData].self, from: response.data)
                        
                        self.isEmptyView = result.isEmpty
                        self.workspace = result
                        self.isLogout = false
                        
                    } catch {
                        print("fetchWorkspaces decoding error")
                    }
                    
                } else if (400..<501).contains(response.statusCode) {
                    print("fetchWorkspaces failure - ", response.statusCode, response.data)
                                    
                }
            case .failure(let error):
                print("fetchWorkspaces Error - ", error)
            }
        }
    }
}