//
//  TdService.swift
//  Moc
//
//  Created by Егор Яковенко on 30.12.2021.
//

import TDLibKit
import Resolver
import Foundation

class TdService {
	@Injected private var tdApi: TdApi
	init() {
		tdApi.client.run {
			do {
				let update = try self.tdApi.decoder.decode(Update.self, from: $0)
				NSLog("CaughtUpdate: \(update)")
				switch update {
					case .updateAuthorizationState(let state):
						switch state.authorizationState {
							case .authorizationStateWaitTdlibParameters:
								Task(priority: .medium) {
									NSLog("something")
									let _ = try! await self.tdApi.setTdlibParameters(parameters: TdlibParameters(
										apiHash: Bundle.main.infoDictionary?["TdApiHash"] as! String,
										apiId: Bundle.main.infoDictionary?["TdApiId"] as! Int,
										applicationVersion: "0.1",
										databaseDirectory: "",
										deviceModel: "MacBook Pro X lol",
										enableStorageOptimizer: true,
										filesDirectory: "",
										ignoreFileNames: false,
										systemLanguageCode: "en-US",
										systemVersion: "Monterey 12.0",
										useChatInfoDatabase: true,
										useFileDatabase: true,
										useMessageDatabase: true,
										useSecretChats: false,
										useTestDc: true
									))
								}
								break
							case .authorizationStateWaitEncryptionKey(_):
								Task(priority: .medium) {
									try! await self.tdApi.checkDatabaseEncryptionKey(encryptionKey: nil)
								}
								break
							case .authorizationStateWaitPhoneNumber:
								NotificationCenter.default.post(name: Notification.Name("AuthorizationPhoneNumberRequired"), object: nil)
								NSLog("phone number")
								break
							case .authorizationStateWaitCode(_):
								NotificationCenter.default.post(name: Notification.Name("AuthorizationCodeRequired"), object: nil)
								NSLog("codeRequired")
								break
							case .authorizationStateWaitRegistration(_):
								NotificationCenter.default.post(name: Notification.Name("AuthorizationWaitRegistration"), object: nil)
								NSLog("registration")
								break
							case .authorizationStateWaitPassword(_):
								NotificationCenter.default.post(name: Notification.Name("AuthorizationPasswordRequired"), object: nil)
								NSLog("password")
								break
							case .authorizationStateReady:
								NotificationCenter.default.post(name: Notification.Name("AuthorizationSuccessful"), object: nil)
								print("auth successful")
								break
							default:
								break
						}
						break
					default:
						break
				}
			} catch {
//							print("Error in update handler \(error.localizedDescription)")
			}
		}
	}
}
