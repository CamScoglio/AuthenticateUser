//
//  AuthView.swift
//  AuthenticateUser
//
//  Created by Cam Scoglio on 6/22/25.
//

import Foundation
import SwiftUI
import Supabase

struct AuthView: View {
  @State var email = ""
  @State var isLoading = false
  @State var result: Result<Void, Error>?

  var body: some View {
    ZStack {
      // White background
      Color.white
        .ignoresSafeArea()
      
      VStack(spacing: 40) {
        Spacer()
        
        // Modern centered title
        VStack(spacing: 16) {
          Text("Welcome to")
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
          
          Text("FitAI")
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
          
          Text("The AI-powered fitness companion")
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        
        // Email input and sign in section
        VStack(spacing: 24) {
          // Email input field
          VStack(alignment: .leading, spacing: 8) {
            Text("Email Address")
              .font(.headline)
              .foregroundColor(.primary)
            
            TextField("Enter your email", text: $email)
              .textFieldStyle(ModernTextFieldStyle())
              .textContentType(.emailAddress)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
          }
          
          // Modern sign in button
          Button(action: signInButtonTapped) {
            HStack {
              if isLoading {
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle(tint: .white))
                  .scaleEffect(0.8)
              } else {
                Text("Sign In")
                  .font(.headline)
                  .fontWeight(.semibold)
              }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
              LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
          }
          .disabled(isLoading || email.isEmpty)
          .opacity((isLoading || email.isEmpty) ? 0.6 : 1.0)
          
          // Result message
          if let result {
            HStack {
              switch result {
              case .success:
                Image(systemName: "checkmark.circle.fill")
                  .foregroundColor(.green)
                Text("Check your inbox for the sign-in link")
                  .foregroundColor(.green)
              case .failure(let error):
                Image(systemName: "exclamationmark.circle.fill")
                  .foregroundColor(.red)
                Text(error.localizedDescription)
                  .foregroundColor(.red)
              }
            }
            .font(.subheadline)
            .padding(.horizontal)
          }
        }
        .padding(.horizontal, 40)
        
        Spacer()
      }
    }
    .onOpenURL(perform: { url in
      Task {
        do {
          try await supabase.auth.session(from: url)
        } catch {
          self.result = .failure(error)
        }
      }
    })
  }

  func signInButtonTapped() {
    Task {
      isLoading = true
      defer { isLoading = false }

      do {
        try await supabase.auth.signInWithOTP(
            email: email,
            redirectTo: URL(string: "io.supabase.user-management://login-callback")
        )
        result = .success(())
      } catch {
        result = .failure(error)
      }
    }
  }
}

// Custom text field style for modern look
struct ModernTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.gray.opacity(0.1))
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color.gray.opacity(0.2), lineWidth: 1)
          )
      )
  }
}

#Preview {
    AuthView()
}
