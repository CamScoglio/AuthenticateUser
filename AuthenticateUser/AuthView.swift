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
    VStack(spacing: FitAIDesign.Spacing.sectionSpacing) {
      Spacer()
      
      // Modern centered title using design system
      WelcomeTitleView()
        .padding(.horizontal, FitAIDesign.Spacing.xxLarge)
      
      // Email input and sign in section
      VStack(spacing: FitAIDesign.Spacing.formSpacing) {
        // Email input field
        FormFieldView(label: "Email Address") {
          TextField("Enter your email", text: $email)
            .textFieldStyle(ModernTextFieldStyle())
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        
        // Modern sign in button
        PrimaryButton(
          title: "Sign In",
          isLoading: isLoading,
          isDisabled: email.isEmpty,
          action: signInButtonTapped
        )
        
        // Result message
        if let result {
          switch result {
          case .success:
            StatusMessageView(
              message: "Check your inbox for the sign-in link",
              isSuccess: true
            )
          case .failure(let error):
            StatusMessageView(
              message: error.localizedDescription,
              isSuccess: false
            )
          }
        }
      }
      .padding(.horizontal, FitAIDesign.Spacing.xxLarge)
      
      Spacer()
    }
    .fitAIBackground()
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

#Preview {
    AuthView()
}
