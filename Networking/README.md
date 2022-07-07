# Networking

Networking layout for REST Api  
Async/await and generic by protocols 

 1. Make Serviceable protocol
    func getSome() async throws -> Some
2. Make Service: HTTPClient, Serviceable
    func getSome() async throws -> Some{}
3. Use in viewModel 
    
