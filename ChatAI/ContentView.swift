//
//  ContentView.swift
//  ChatAI
//
//  Created by Sarah Lee on 1/31/23.
//

import SwiftUI
import OpenAISwift

final class ViewModel: ObservableObject {
    init() {
        
    }
    private var client: OpenAISwift?
    
    func setup() {
        // Add your auth token
        client = OpenAISwift(authToken: "")
    }
    
    func send(text: String,
              completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, model: .gpt3(.ada), completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                let trimmed = output.trimmingCharacters(in: .whitespaces)
                completion(trimmed)
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(models, id: \.self) { string in
                Text(string)
            }
            Spacer()
            HStack {
                TextField("Type here...", text: $text)
                Button("Send") {
                    send()
                }
            }
        }
        .onAppear {
            viewModel.setup()
        }
        .padding()
    }
    
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        models.append("Me: \(text)")
        viewModel.send(text: text){ response in
            DispatchQueue.main.async {
                self.models.append("ChatGPT: " + response)
                self.text = ""
            }
        }
    }
}
