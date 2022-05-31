//
//  TDLibKit+Identifiable.swift
//  
//
//  Created by Егор Яковенко on 26.02.2022.
//
import TDLibKit

protocol AutoHashable { }

extension ChatFilter: AutoHashable { }

extension ChatFilterInfo: AutoHashable, Identifiable { }

extension Chat: AutoHashable, Identifiable { }

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
