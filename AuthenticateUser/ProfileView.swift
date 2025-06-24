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
  @State var username = ""
  @State var fullName = ""
  @State var website = ""
  @State var isLoading = false
  @State var imageSelection: PhotosPickerItem?
  @State var avatarImage: AvatarImage?
  @State var showProgressView = false

  if showProgressView {
    ProgressView()
      .ignoresSafeArea()
  } else { 
  var body: some View {
    ZStack {
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
            imageSelection: $imageSelection
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
            
            // First Name field
            FormFieldView(label: "First Name") {
              TextField("Enter your first name", text: $fullName)
                .textFieldStyle(ModernTextFieldStyle())
                .textContentType(.name)
            }
          }
          .padding(.horizontal, FitAIDesign.Spacing.large)
          
          Spacer()
          
          // Update Profile button
          PrimaryButton(
            title: "Update Profile",
            isLoading: isLoading,
            action: updateProfileButtonTapped
          )
          .padding(.horizontal, FitAIDesign.Spacing.large)
          .padding(.bottom, FitAIDesign.Spacing.xLarge)
        }
      }
      .fitAIBackground()
    }
  }
  .onChange(of: imageSelection) { _, newValue in
    guard let newValue else { return }
    loadTransferable(from: newValue)
  }
  .onAppear {
    Task {
      await getInitialProfile()
    }
  }
}

  func getInitialProfile() async {
    do {
      let currentUser = try await supabase.auth.session.user

      let profile: Profile =
      try await supabase
        .from("profiles")
        .select()
        .eq("id", value: currentUser.id)
        .single()
        .execute()
        .value

      username = profile.username ?? ""
      fullName = profile.fullName ?? ""
      website = profile.website ?? ""

      if let avatarURL = profile.avatarURL, !avatarURL.isEmpty {
        try await downloadImage(path: avatarURL)
      }

    } catch {
      debugPrint(error)
    }
  }

  func updateProfileButtonTapped() {
    Task {
      isLoading = true
      defer { isLoading = false }
      
      do {
        let imageURL = try await uploadImage()

        let currentUser = try await supabase.auth.session.user

        let updatedProfile = Profile(
          username: username,
          fullName: fullName,
          website: website,
          avatarURL: imageURL
        )

        try await supabase
          .from("profiles")
          .update(updatedProfile)
          .eq("id", value: currentUser.id)
          .execute()
        
        // Show ProgressView after successful update
        showProgressView = true
        
      } catch {
        debugPrint(error)
      }
    }
  }

  @MainActor
  private func loadTransferable(from imageSelection: PhotosPickerItem) {
    Task {
      do {
        avatarImage = try await imageSelection.loadTransferable(type: AvatarImage.self)
      } catch {
        debugPrint(error)
      }
    }
  }

  private func downloadImage(path: String) async throws {
    let data = try await supabase.storage.from("avatars").download(path: path)
    avatarImage = AvatarImage(data: data)
  }

  private func uploadImage() async throws -> String? {
    guard let data = avatarImage?.data else { return nil }

    let filePath = "\(UUID().uuidString).jpeg"

    try await supabase.storage
      .from("avatars")
      .upload(
        filePath,
        data: data,
        options: FileOptions(contentType: "image/jpeg")
      )

    return filePath
  }
}


#Preview {
    ProfileView()
}
