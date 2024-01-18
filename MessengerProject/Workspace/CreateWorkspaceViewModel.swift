//
//  CreateWorkspaceViewModel.swift
//  MessengerProject
//
//  Created by Yeonu Park on 2024/01/18.
//

import Foundation
import Combine
import Moya

class CreateWorkspaceViewModel: ObservableObject {
    
    @Published var name = ""
    @Published var description = ""
    
    @Published var isNameFieldFilled = false
    
    init() {
        fieldCheck()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func fieldCheck() {
        $name
            .map( { !$0.isEmpty } )
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .assign(to: \.isNameFieldFilled, on: self)
            .store(in: &cancellables)
    }
    
    private let provider = MoyaProvider<MarAPI>()
    
    func createWorkspace() {
        let model = NewWorkspacesModel(name: name, description: description, image: "/static/workspaceThumbnail/1701706651161.jpeg")
        provider.request(.createWorkspaces(model: model)) { result in
            
            switch result {
            case .success(let response):
                if (200..<300).contains(response.statusCode) {
                    print("create success - ", response.statusCode, response.data)
                    
                    do {
                        let result = try JSONDecoder().decode(NewWorkspacesResponse.self, from: response.data)
                        print(result)
                        
                    } catch {
                        print("create decoding error")
                    }
                    
                } else if (400..<501).contains(response.statusCode) {
                    print("create failure - ", response.statusCode, response.data)
                    
                }
            case .failure(let error):
                print("create Error - ", error)
            }
        }
    }
}