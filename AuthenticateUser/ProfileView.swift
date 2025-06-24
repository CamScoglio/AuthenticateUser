//
//  ProfileView.swift
//  AuthenticateUser
//
//  Created by Cam Scoglio on 6/22/25.
//

import Foundation
import SwiftUI
import Supabase
import PhotosUI
import Storage

struct ProfileView: View {
  // Form data
  @State private var username = ""
  @State private var name = ""
  @State private var profileImageData: Data?
  @State private var selectedImage: PhotosPickerItem?
  @State private var avatarImage: AvatarImage?
  
  // UI state
  @State private var isLoading = false
  @State private var showProgressView = false
  @State private var errorMessage: String?

  var body: some View {
    ZStack {
      if showProgressView {
        // Full screen ProgressView
        ProgressView()
          .ignoresSafeArea()
      } else {
        VStack(spacing: 0) {
          // Header with FitAI branding
          HStack {
            AppTitleView(size: 32)
            
            Spacer()
            
            Button("Sign out", role: .destructive) {
              Task {
                try? await supabase.auth.signOut()
              }
            }
            .font(FitAIDesign.Typography.subheadlineText)
            .foregroundColor(FitAIDesign.Colors.error)
          }
          .padding(.horizontal, FitAIDesign.Spacing.large)
          .padding(.top, FitAIDesign.Spacing.medium)
          .padding(.bottom, FitAIDesign.Spacing.xLarge)
          
          // Profile content
          VStack(spacing: FitAIDesign.Spacing.sectionSpacing) {
            // Profile image section
            ProfileImageView(
              avatarImage: avatarImage,
              imageSelection: $selectedImage
            )
            
            // Form section
            VStack(spacing: FitAIDesign.Spacing.formSpacing) {
              // Username field
              FormFieldView(label: "Username") {
                TextField("Enter your username", text: $username)
                  .textFieldStyle(ModernTextFieldStyle())
                  .textContentType(.username)
                  .textInputAutocapitalization(.never)
              }
              
              // Name field
              FormFieldView(label: "Full Name") {
                TextField("Enter your full name", text: $name)
                  .textFieldStyle(ModernTextFieldStyle())
                  .textContentType(.name)
              }
            }
            .padding(.horizontal, FitAIDesign.Spacing.large)
            
            // Error message
            if let errorMessage {
              StatusMessageView(
                message: errorMessage,
                isSuccess: false
              )
              .padding(.horizontal, FitAIDesign.Spacing.large)
            }
            
            Spacer()
            
            // Update Profile button
            PrimaryButton(
              title: "Update Profile",
              isLoading: isLoading,
              isDisabled: !isFormValid,
              action: updateProfile
            )
            .padding(.horizontal, FitAIDesign.Spacing.large)
            .padding(.bottom, FitAIDesign.Spacing.xLarge)
          }
        }
        .fitAIBackground()
      }
    }
    .onChange(of: selectedImage) { _, newValue in
      Task {
        await loadSelectedImage(newValue)
      }
    }
  }
  
  // MARK: - Computed Properties
  
  private var isFormValid: Bool {
    !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
  
  // MARK: - Functions
  
  @MainActor
  private func loadSelectedImage(_ item: PhotosPickerItem?) async {
    guard let item = item else { return }
    
    do {
      if let data = try await item.loadTransferable(type: Data.self) {
        profileImageData = data
        avatarImage = AvatarImage(data: data)
      }
    } catch {
      errorMessage = "Failed to load image: \(error.localizedDescription)"
    }
  }
  
  private func updateProfile() {
    Task {
      await MainActor.run {
        isLoading = true
        errorMessage = nil
      }
      
      do {
        // Get current user
        let currentUser = try await supabase.auth.session.user
        let userEmail = currentUser.email ?? ""
        
        // Upload profile image if one was selected
        var profileImageUrl: String? = nil
        if let imageData = profileImageData {
          profileImageUrl = try await uploadProfileImage(imageData)
        }
        
        // Create user profile data
        let userProfile: [String: AnyJSON] = [
          "user_id": AnyJSON.string(currentUser.id.uuidString),
          "email": AnyJSON.string(userEmail),
          "username": AnyJSON.string(username.trimmingCharacters(in: .whitespacesAndNewlines)),
          "name": AnyJSON.string(name.trimmingCharacters(in: .whitespacesAndNewlines)),
          "profile_picture_url": profileImageUrl != nil ? AnyJSON.string(profileImageUrl!) : AnyJSON.null
        ]
        
        // Save to user_profiles table (upsert to handle updates)
        try await supabase
          .from("user_profiles")
          .upsert(userProfile)
          .execute()
        
        // Success - show progress view
        await MainActor.run {
          isLoading = false
          showProgressView = true
        }
        
      } catch {
        await MainActor.run {
          isLoading = false
          errorMessage = "Failed to save profile: \(error.localizedDescription)"
        }
      }
    }
  }
  
  private func uploadProfileImage(_ imageData: Data) async throws -> String {
    // Create unique filename
    let fileName = "\(UUID().uuidString).jpg"
    
    // Upload to Supabase storage
    try await supabase.storage
      .from("profile-images")
      .upload(
        fileName,
        data: imageData,
        options: FileOptions(contentType: "image/jpeg")
      )
    
    return fileName
  }
}

#Preview {
    ProfileView()
}
