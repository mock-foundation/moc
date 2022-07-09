//
//  ChatView+InputField.swift
//  Moc
//
//  Created by Егор Яковенко on 08.07.2022.
//

import SwiftUI
import UniformTypeIdentifiers

extension ChatView {
    @ViewBuilder
    var inputFieldAttaches: some View {
        if !viewModel.inputMedia.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        withAnimation(.spring()) {
                            viewModel.inputMedia.removeAll()
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                    }
                    .padding()
                    
                    ForEach(viewModel.inputMedia, id: \.self) { url in
                        Group {
                            if UTType(url)!.conforms(toAtLeastOneOf: [
                                .image,
                                .video,
                                .mpeg,
                                .mpeg2Video,
                                .mpeg4Movie,
                                .appleProtectedMPEG4Video,
                                .quickTimeMovie]
                            ) {
                                url.thumbnail
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                VStack {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 22))
                                    Text(url.lastPathComponent)
                                        .font(.system(.body, design: .rounded))
                                        .lineLimit(2)
                                        .truncationMode(.middle)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(8)
                                .background(.ultraThinMaterial, in: Rectangle())
                            }
                        }
                        .frame(width: 100, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation(.spring()) {
                                    viewModel.inputMedia.removeAll(where: { $0 == url })
                                }
                            } label: {
                                Image(systemName: "trash")
                                Text("Remove")
                            }
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    var inputField: some View {
        VStack(spacing: 8) {
            inputFieldAttaches
            
            HStack(spacing: 16) {
                #if os(iOS)
                if viewModel.isHideKeyboardButtonShown {
                    Button {
                        isInputFieldFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .padding(8)
                            .foregroundColor(.black)
                    }
                    .background(Color.white)
                    .clipShape(Circle())
                    .transition(.scale.combined(with: .opacity))
                }
                #endif
                Image(systemName: "paperclip")
                    .font(.system(size: 16))
                Group {
                    if #available(macOS 13, iOS 16, *) {
                        TextField(
                            viewModel.isChannel ? "Broadcast..." : "Message...",
                            text: $viewModel.inputMessage,
                            axis: .vertical
                        ).lineLimit(20)
                    } else {
                        TextField(viewModel.isChannel ? "Broadcast..." : "Message...", text: $viewModel.inputMessage)
                    }
                }
                .textFieldStyle(.plain)
                .padding(6)
                .onChange(of: viewModel.inputMessage) { value in
                    logger.debug("Input message changed, value: \(value)")
                    viewModel.updateAction(with: .actionTyping)
                    viewModel.updateDraft()
                }
                .onSubmit {
                    viewModel.sendMessage()
                }
                .focused($isInputFieldFocused)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        self.isInputFieldFocused = true
                    }
                }
                Image(systemName: "face.smiling")
                    .font(.system(size: 16))
                if viewModel.inputMessage.isEmpty && viewModel.inputMedia.isEmpty {
                    Image(systemName: "mic")
                        .font(.system(size: 16))
                        .transition(.scale.combined(with: .opacity))
                }
                if !viewModel.inputMessage.isEmpty || !viewModel.inputMedia.isEmpty {
                    Button {
                        viewModel.sendMessage()
                    } label: {
                        Image(systemName: "arrow.up")
                            #if os(macOS)
                            .font(.system(size: 16))
                            .padding(6)
                            #elseif os(iOS)
                            .padding(8)
                            #endif
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onChange(of: isInputFieldFocused) { value in
            viewModel.isHideKeyboardButtonShown = value
        }
        .animation(.spring(dampingFraction: 0.7), value: viewModel.inputMessage.isEmpty)
        .animation(.spring(dampingFraction: 0.7), value: viewModel.inputMedia.isEmpty)
        .animation(.spring(dampingFraction: 0.7), value: viewModel.inputMedia)
        .animation(.spring(dampingFraction: 0.7), value: viewModel.isHideKeyboardButtonShown)
    }
}
