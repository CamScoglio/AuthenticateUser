import Foundation
import SwiftUI

//Create a progress view that shows a modern loading circle and a message that says "Personalizing your experience..."


struct ProgressView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var currentTextIndex = 0
    @State private var displayedText = ""
    @State private var currentCharIndex = 0
    
    // Easy to modify texts
    let texts = [
        "Personalizing your experience...",
        "Analyzing your fitness goals...",
        "Creating your custom plan..."
    ]
    
    var body: some View {
        Group {
            if showProgressView {
                // Full screen ProgressView
                ProgressView()
                    .ignoresSafeArea()
            } else {
                // Profile form view
                ZStack {
                    // White background
                    Color.white
                        .ignoresSafeArea()
                    
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
        }
        
        .onChange(of: imageSelection) { _, newValue in
            guard let newValue else { return }
            loadTransferable(from: newValue)
        }
        .task {
            await getInitialProfile()
        }
    }
    
    // Function to start the typing animation cycle
    func startTypingAnimation() {
        typeText(texts[currentTextIndex])
    }
}

#Preview {
    ProgressView()
}
