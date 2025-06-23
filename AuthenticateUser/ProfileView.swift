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

  var body: some View {
    ZStack {
      // White background
      Color.white
        .ignoresSafeArea()
      
      if showProgressView {
        ProgressView()
      } else {
        VStack(spacing: 0) {
          // Header with FitAI branding
          HStack {
            Text("FitAI")
              .font(.system(size: 32, weight: .bold, design: .rounded))
              .foregroundColor(.primary)
            
            Spacer()
            
            Button("Sign out", role: .destructive) {
              Task {
                try? await supabase.auth.signOut()
              }
            }
            .font(.subheadline)
            .foregroundColor(.red)
          }
          .padding(.horizontal, 24)
          .padding(.top, 16)
          .padding(.bottom, 32)
          
          // Profile content
          VStack(spacing: 40) {
            // Profile image section
            VStack(spacing: 16) {
              // Circular profile image with edit button
              ZStack(alignment: .topTrailing) {
                Group {
                  if let avatarImage {
                    avatarImage.image
                      .resizable()
                      .scaledToFill()
                  } else {
                    RoundedRectangle(cornerRadius: 60)
                      .fill(Color.gray.opacity(0.1))
                      .overlay(
                        Image(systemName: "person.fill")
                          .font(.system(size: 40))
                          .foregroundColor(.gray)
                      )
                  }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                  Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                )
                
                // Edit button
                PhotosPicker(selection: $imageSelection, matching: .images) {
                  Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                    .background(Color.white, in: Circle())
                }
                .offset(x: 8, y: -8)
              }
              
              Text("Tap to update photo")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            // Form section
            VStack(spacing: 24) {
              // Username field
              VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                  .font(.headline)
                  .foregroundColor(.primary)
                
                TextField("Enter your username", text: $username)
                  .textFieldStyle(ModernTextFieldStyle())
                  .textContentType(.username)
                  .textInputAutocapitalization(.never)
              }
              
              // First Name field
              VStack(alignment: .leading, spacing: 8) {
                Text("First Name")
                  .font(.headline)
                  .foregroundColor(.primary)
                
                TextField("Enter your first name", text: $fullName)
                  .textFieldStyle(ModernTextFieldStyle())
                  .textContentType(.name)
              }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Update Profile button
            Button(action: updateProfileButtonTapped) {
              HStack {
                if isLoading {
                  ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
                } else {
                  Text("Update Profile")
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
            .disabled(isLoading)
            .opacity(isLoading ? 0.6 : 1.0)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
          }
        }
      }
    }
    .onChange(of: imageSelection) { _, newValue in
      guard let newValue else { return }
      loadTransferable(from: newValue)
    }
    .task {
      await getInitialProfile()
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
