//
//  SharedStyles.swift
//  AuthenticateUser
//
//  Created by Cam Scoglio on 6/22/25.
//

import SwiftUI
import PhotosUI

// MARK: - Design System

struct FitAIDesign {
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.purple
        static let background = Color.white
        static let success = Color.green
        static let error = Color.red
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let grayLight = Color.gray.opacity(0.1)
        static let grayBorder = Color.gray.opacity(0.2)
    }
    
    // MARK: - Gradients
    struct Gradients {
        static let primary = LinearGradient(
            gradient: Gradient(colors: [Colors.primary, Colors.secondary]),
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let primaryVertical = LinearGradient(
            gradient: Gradient(colors: [Colors.primary, Colors.secondary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let backgroundSubtle = LinearGradient(
            gradient: Gradient(colors: [
                Colors.primary.opacity(0.1),
                Colors.secondary.opacity(0.1),
                Colors.primary.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let circleGradient = LinearGradient(
            gradient: Gradient(colors: [Colors.primary, Colors.secondary, Colors.primary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let reverseGradient = LinearGradient(
            gradient: Gradient(colors: [Colors.secondary, Colors.primary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Typography
    struct Typography {
        static let appTitle = Font.system(size: 48, weight: .bold, design: .rounded)
        static let headerTitle = Font.system(size: 32, weight: .bold, design: .rounded)
        static let welcomeText = Font.title2
        static let subtitle = Font.title3
        static let fieldLabel = Font.headline
        static let buttonText = Font.headline
        static let bodyText = Font.title2
        static let captionText = Font.caption
        static let subheadlineText = Font.subheadline
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 40
        static let sectionSpacing: CGFloat = 40
        static let formSpacing: CGFloat = 24
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let circle: CGFloat = 60
    }
    
    // MARK: - Sizes
    struct Sizes {
        static let buttonHeight: CGFloat = 56
        static let profileImageSize: CGFloat = 120
        static let loadingCircleLarge: CGFloat = 80
        static let loadingCircleSmall: CGFloat = 60
        static let dotSize: CGFloat = 8
        static let centerDotSize: CGFloat = 12
        static let editIconSize: CGFloat = 32
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let button = Shadow(
            color: Colors.primary.opacity(0.3),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Reusable Components

// MARK: - Text Field Style
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, FitAIDesign.Spacing.medium)
            .padding(.vertical, FitAIDesign.Spacing.medium - 4)
            .background(
                RoundedRectangle(cornerRadius: FitAIDesign.CornerRadius.medium)
                    .fill(FitAIDesign.Colors.grayLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: FitAIDesign.CornerRadius.medium)
                            .stroke(FitAIDesign.Colors.grayBorder, lineWidth: 1)
                    )
            )
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    let isLoading: Bool
    let isDisabled: Bool
    
    init(isLoading: Bool = false, isDisabled: Bool = false) {
        self.isLoading = isLoading
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: FitAIDesign.Sizes.buttonHeight)
            .background(FitAIDesign.Gradients.primary)
            .foregroundColor(.white)
            .cornerRadius(FitAIDesign.CornerRadius.large)
            .shadow(
                color: FitAIDesign.Shadows.button.color,
                radius: FitAIDesign.Shadows.button.radius,
                x: FitAIDesign.Shadows.button.x,
                y: FitAIDesign.Shadows.button.y
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity((isLoading || isDisabled) ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - App Title Component
struct AppTitleView: View {
    let size: CGFloat
    
    init(size: CGFloat = 48) {
        self.size = size
    }
    
    var body: some View {
        Text("FitAI")
            .font(.system(size: size, weight: .bold, design: .rounded))
            .foregroundColor(FitAIDesign.Colors.textPrimary)
    }
}

// MARK: - Welcome Title Component
struct WelcomeTitleView: View {
    var body: some View {
        VStack(spacing: FitAIDesign.Spacing.medium) {
            Text("Welcome to")
                .font(FitAIDesign.Typography.welcomeText)
                .fontWeight(.medium)
                .foregroundColor(FitAIDesign.Colors.textSecondary)
            
            AppTitleView()
            
            Text("The AI-powered fitness companion")
                .font(FitAIDesign.Typography.subtitle)
                .fontWeight(.medium)
                .foregroundColor(FitAIDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Form Field Component
struct FormFieldView<Content: View>: View {
    let label: String
    let content: Content
    
    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: FitAIDesign.Spacing.small) {
            Text(label)
                .font(FitAIDesign.Typography.fieldLabel)
                .foregroundColor(FitAIDesign.Colors.textPrimary)
            
            content
        }
    }
}

// MARK: - Primary Button Component
struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(FitAIDesign.Typography.buttonText)
                        .fontWeight(.semibold)
                }
            }
        }
        .buttonStyle(PrimaryButtonStyle(isLoading: isLoading, isDisabled: isDisabled))
        .disabled(isLoading || isDisabled)
    }
}

// MARK: - Status Message Component
struct StatusMessageView: View {
    let message: String
    let isSuccess: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundColor(isSuccess ? FitAIDesign.Colors.success : FitAIDesign.Colors.error)
            
            Text(message)
                .foregroundColor(isSuccess ? FitAIDesign.Colors.success : FitAIDesign.Colors.error)
        }
        .font(FitAIDesign.Typography.subheadlineText)
    }
}

// MARK: - Profile Image Component
struct ProfileImageView: View {
    let avatarImage: AvatarImage?
    let imageSelection: Binding<PhotosPickerItem?>
    
    var body: some View {
        VStack(spacing: FitAIDesign.Spacing.medium) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if let avatarImage {
                        avatarImage.image
                            .resizable()
                            .scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: FitAIDesign.CornerRadius.circle)
                            .fill(FitAIDesign.Colors.grayLight)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: FitAIDesign.Spacing.xxLarge))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(
                    width: FitAIDesign.Sizes.profileImageSize,
                    height: FitAIDesign.Sizes.profileImageSize
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(FitAIDesign.Colors.grayBorder, lineWidth: 2)
                )
                
                // Edit button
                PhotosPicker(selection: imageSelection, matching: .images) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: FitAIDesign.Sizes.editIconSize))
                        .foregroundColor(FitAIDesign.Colors.primary)
                        .background(FitAIDesign.Colors.background, in: Circle())
                }
                .offset(x: FitAIDesign.Spacing.small, y: -FitAIDesign.Spacing.small)
            }
            
            Text("Tap to update photo")
                .font(FitAIDesign.Typography.captionText)
                .foregroundColor(FitAIDesign.Colors.textSecondary)
        }
    }
}

// MARK: - View Extensions for easy styling
extension View {
    func fitAIBackground() -> some View {
        self.background(
            FitAIDesign.Colors.background
                .ignoresSafeArea()
        )
    }
    
    func fitAIGradientBackground() -> some View {
        self.background(
            FitAIDesign.Gradients.backgroundSubtle
                .ignoresSafeArea()
        )
    }
} 