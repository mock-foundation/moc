//
//  FormattedTextView.swift
//  Moc
//
//  Created by Егор Яковенко on 06.09.2022.
//

import SwiftUI
import TDLibKit
import Logs

struct FormattedTextView: View {
    @State var text: FormattedText
    @State private var areSpoilersRevealed: Bool = false
    private var logger = Logger(category: "UI", label: "FormattedTextView")
    
    init(_ text: FormattedText) {
        self._text = State(initialValue: text)
    }
    
    var body: some View {
        Text(generateAttributedString(from: text))
    }
    
    private func generateAttributedString(from formattedText: FormattedText) -> AttributedString {
        var resultString = AttributedString(formattedText.text)
                
        for entity in formattedText.entities {
            let range = attrStringRange(
                from: range(
                    for: formattedText.text,
                    start: entity.offset,
                    length: entity.length),
                for: resultString)
            let rawStringPart = String(formattedText.text[self.range(
                for: formattedText.text,
                start: entity.offset,
                length: entity.length)])
                        
            switch entity.type {
                case .bold:
                    if #available(macOS 13, iOS 16, *) {
                        resultString[range].font = .system(.body, weight: .bold)
                    } else {
                        resultString[range].font = .body.bold()
                    }
                case .italic:
                    if #available(macOS 13, iOS 16, *) {
                        resultString[range].font = .system(.body).italic()
                    } else {
                        resultString[range].font = .body.italic()
                    }
                    // TODO: Fix coloring of links for outgoing messages
                case .url:
                    resultString[range].link = URL(string: rawStringPart)
                    resultString[range].underlineStyle = .single
                    #if os(macOS)
                    resultString[range].cursor = .pointingHand
                    #endif
                case let .textUrl(info):
                    resultString[range].link = URL(string: info.url)
                    resultString[range].underlineStyle = .single
                    #if os(macOS)
                    resultString[range].cursor = .pointingHand
                    #endif
                case .phoneNumber:
                    resultString[range].link = URL(string: "tel:\(rawStringPart)")
                    #if os(macOS)
                    resultString[range].cursor = .pointingHand
                    #endif
                case .emailAddress:
                    resultString[range].link = URL(string: "mailto:\(rawStringPart)")
                    #if os(macOS)
                    resultString[range].cursor = .pointingHand
                    #endif
                default:
                    break
            }
        }
        
        return resultString
    }
    
    private func range(
        for string: String,
        start: Int,
        length: Int
    ) -> Range<String.Index> {
        let startIndex = string.utf16.index(string.startIndex, offsetBy: start)
        let endIndex = string.utf16.index(startIndex, offsetBy: length)
        return startIndex..<endIndex
    }
    
    private func attrStringRange(
        from stringRange: Range<String.Index>,
        for attrString: AttributedString
    ) -> Range<AttributedString.Index> {
        let lowerBound = AttributedString.Index(stringRange.lowerBound, within: attrString)!
        let upperBound = AttributedString.Index(stringRange.upperBound, within: attrString)!
        return lowerBound..<upperBound
    }
}

struct FormattedTextView_Previews: PreviewProvider {
    static var previews: some View {
        FormattedTextView(FormattedText(
            entities: [
                TextEntity(length: 10, offset: 0, type: .bold)
            ], text: """
            mention hashtag cashtag botCommand url emailAddress \
            phoneNumber bankCardNumber bold italic underline strikethrough \
            spoiler code pre preCode textUrl mentionName mediaTimestamp
            """))
    }
}
