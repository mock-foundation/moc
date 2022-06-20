//
//  TDLibKit+Identifiable.swift
//  
//
//  Created by Егор Яковенко on 26.02.2022.
//
import TDLibKit
import Backend

protocol AutoHashable { }
protocol AutoEquatable { }

extension TDLibKit.ChatFilter: AutoHashable { }

extension ChatFilterInfo: AutoHashable, Identifiable { }

extension TDLibKit.Chat: AutoHashable, Identifiable { }

extension ChatActionBar: AutoHashable { }

extension DraftMessage: AutoHashable { }

extension TDLibKit.Message: AutoHashable { }

extension TDLibKit.MessageSender: AutoHashable { }

extension ChatNotificationSettings: AutoHashable { }

extension TDLibKit.ChatType: AutoHashable { }

extension VideoChat: AutoHashable { }

extension ChatPermissions: AutoHashable { }

extension ChatPhoto: AutoHashable { }

extension ChatJoinRequestsInfo: AutoHashable { }

extension ChatPosition: AutoHashable { }

extension ChatPhotoInfo: AutoHashable { }

extension TdInt64: AutoHashable { }

extension AnimatedChatPhoto: AutoHashable { }

extension File: AutoHashable { }

extension Minithumbnail: AutoHashable { }

extension PhotoSize: AutoHashable { }

extension ChatList: AutoHashable { }

extension ChatSource: AutoHashable { }

extension InputMessageContent: AutoHashable { }

extension LocalFile: AutoHashable { }

extension RemoteFile: AutoHashable { }

extension ChatActionBarReportSpam: AutoHashable { }

extension ChatActionBarReportAddBlock: AutoHashable { }

extension ChatActionBarJoinRequest: AutoHashable { }

extension ChatListFilter: AutoHashable { }

extension ChatSourcePublicServiceAnnouncement: AutoHashable { }

extension InputMessageText: AutoHashable { }

extension InputMessageAudio: AutoHashable { }

extension InputMessageAnimation: AutoHashable { }

extension InputMessageDice: AutoHashable { }

extension InputMessageDocument: AutoHashable { }

extension InputMessagePoll: AutoHashable { }

extension InputMessagePhoto: AutoHashable { }

extension InputMessageSticker: AutoHashable { }

extension InputMessageVideo: AutoHashable { }

extension InputMessageVideoNote: AutoHashable { }

extension InputMessageVoiceNote: AutoHashable { }

extension InputMessageLocation: AutoHashable { }

extension InputMessageVenue: AutoHashable { }

extension InputMessageContact: AutoHashable { }

extension InputMessageGame: AutoHashable { }

extension InputMessageInvoice: AutoHashable { }

extension InputMessageForwarded: AutoHashable { }

extension Contact: AutoHashable { }

extension FormattedText: AutoHashable { }

extension InputFile: AutoHashable { }

extension InputThumbnail: AutoHashable { }

extension MessageCopyOptions: AutoHashable { }

extension Invoice: AutoHashable { }

extension Location: AutoHashable { }

extension PollType: AutoHashable { }

extension Venue: AutoHashable { }

extension TextEntity: AutoHashable { }

extension InputFileId: AutoHashable { }

extension InputFileLocal: AutoHashable { }

extension InputFileGenerated: AutoHashable { }

extension PollTypeRegular: AutoHashable { }

extension PollTypeQuiz: AutoHashable { }

extension LabeledPricePart: AutoHashable { }

extension TextEntityType: AutoHashable { }

extension InputFileRemote: AutoHashable { }

extension TextEntityTypePreCode: AutoHashable { }

extension TextEntityTypeTextUrl: AutoHashable { }

extension TextEntityTypeMentionName: AutoHashable { }

extension TextEntityTypeMediaTimestamp: AutoHashable { }

extension RecommendedChatFilter: AutoHashable { }

extension MessageContent: AutoHashable { }

extension MessageText: AutoHashable { }

extension MessageAnimation: AutoHashable { }

extension MessageAudio: AutoHashable { }

extension MessageDocument: AutoHashable { }

extension MessagePhoto: AutoHashable { }

extension MessageSticker: AutoHashable { }

extension MessageVideoNote: AutoHashable { }

extension MessageVoiceNote: AutoHashable { }

extension MessageLocation: AutoHashable { }

extension MessageVenue: AutoHashable { }

extension MessageContact: AutoHashable { }

extension MessageAnimatedEmoji: AutoHashable { }

extension MessageDice: AutoHashable { }

extension MessageGame: AutoHashable { }

extension MessagePoll: AutoHashable { }

extension MessageInvoice: AutoHashable { }

extension MessageVideo: AutoHashable { }

extension MessageCall: AutoHashable { }

extension MessageVideoChatScheduled: AutoHashable { }

extension MessageVideoChatEnded: AutoHashable { }

extension MessageInviteVideoChatParticipants: AutoHashable { }

extension MessageBasicGroupChatCreate: AutoHashable { }

extension MessageSupergroupChatCreate: AutoHashable { }

extension MessageChatChangeTitle: AutoHashable { }

extension MessageChatChangePhoto: AutoHashable { }

extension MessageChatAddMembers: AutoHashable { }

extension MessageChatDeleteMember: AutoHashable { }

extension MessageChatUpgradeTo: AutoHashable { }

extension MessageChatUpgradeFrom: AutoHashable { }

extension MessageChatSetTheme: AutoHashable { }

extension MessageChatSetTtl: AutoHashable { }

extension MessageCustomServiceAction: AutoHashable { }

extension MessageGameScore: AutoHashable { }

extension MessagePaymentSuccessful: AutoHashable { }

extension MessagePaymentSuccessfulBot: AutoHashable { }

extension MessageWebsiteConnected: AutoHashable { }

extension MessageWebAppDataSent: AutoHashable { }

extension MessageWebAppDataReceived: AutoHashable { }

extension MessagePassportDataSent: AutoHashable { }

extension MessagePassportDataReceived: AutoHashable { }

extension MessageProximityAlertTriggered: AutoHashable { }

extension AnimatedEmoji: AutoHashable { }

extension Animation: AutoHashable { }

extension Audio: AutoHashable { }

extension DiceStickers: AutoHashable { }

extension Document: AutoHashable { }

extension Game: AutoHashable { }

extension Photo: AutoHashable { }

extension EncryptedPassportElement: AutoHashable { }

extension OrderInfo: AutoHashable { }

extension Poll: AutoHashable { }

extension Sticker: AutoHashable { }

extension Thumbnail: AutoHashable { }

extension DatedFile: AutoHashable { }

extension WebPage: AutoHashable { }

extension Video: AutoHashable { }

extension VideoNote: AutoHashable { }

extension VoiceNote: AutoHashable { }

extension Address: AutoHashable { }

extension PollOption: AutoHashable { }

extension ClosedVectorPath: AutoHashable { }

extension StickerType: AutoHashable { }

extension DiceStickersRegular: AutoHashable { }

extension MessageVideoChatStarted: AutoHashable { }

extension MessagePinMessage: AutoHashable { }

extension VectorPathCommand: AutoHashable { }

extension DiceStickersSlotMachine: AutoHashable { }

extension StickerTypeMask: AutoHashable { }

extension MaskPosition: AutoHashable { }

extension VectorPathCommandLine: AutoHashable { }

extension VectorPathCommandCubicBezierCurve: AutoHashable { }

extension Point: AutoHashable { }

extension EncryptedCredentials: AutoHashable { }
