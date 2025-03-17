v//
//  ViewController.swift
//  BiometricsDemo
//
//  Created by naresh chouhan on 3/17/25.
//

import UIKit
import BiometricSDK

class ViewController: UIViewController {
    private let authSDK = BiometricAuthSDK()
    
    private let emailTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Enter your email"
            textField.borderStyle = .roundedRect
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            return textField
        }()
    
    private let submitButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Submit", for: .normal)
            button.backgroundColor = .blue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(authenticateAndSendEmail), for: .touchUpInside)
            return button
        }()

        private let statusLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.textColor = .red
            label.numberOfLines = 0
            return label
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
    }
    private func setupUI() {
            emailTextField.translatesAutoresizingMaskIntoConstraints = false
            submitButton.translatesAutoresizingMaskIntoConstraints = false
            statusLabel.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(emailTextField)
            view.addSubview(submitButton)
            view.addSubview(statusLabel)

            NSLayoutConstraint.activate([
                emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
                emailTextField.widthAnchor.constraint(equalToConstant: 250),
                
                submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                submitButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
                submitButton.widthAnchor.constraint(equalToConstant: 200),
                submitButton.heightAnchor.constraint(equalToConstant: 50),
                
                statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                statusLabel.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
                statusLabel.widthAnchor.constraint(equalToConstant: 300)
            ])
        }
    
    @objc private func authenticateAndSendEmail() {
            guard let email = emailTextField.text, !email.isEmpty else {
                statusLabel.text = "Please enter a valid email."
                return
            }

            statusLabel.text = "Authenticating..."
            authSDK.authenticateUser { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let token):
                        self?.sendEmailToServer(email: email, token: token)
                    case .failure(let error):
                        self?.statusLabel.text = "Authentication failed: \(error)"
                    }
                }
            }
        }
    
    private func sendEmailToServer(email: String, token: String) {
            guard let url = URL(string: "https://localhost:3000/users") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = ["email": email, "auth_token": token]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.statusLabel.text = "Network error: \(error.localizedDescription)"
                    } else {
                        self?.statusLabel.text = "Email verified successfully!"
                    }
                }
            }.resume()
        }


}

