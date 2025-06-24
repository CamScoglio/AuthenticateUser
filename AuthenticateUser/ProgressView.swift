import Foundation
import SwiftUI

//Create a progress view that shows a modern loading circle and a message that says "Personalizing your experience..."


struct CustomProgressView: View {
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
        ZStack {
            // Background gradient using design system
            FitAIDesign.Gradients.backgroundSubtle
                .ignoresSafeArea()
            
            VStack(spacing: FitAIDesign.Spacing.sectionSpacing - 10) {
                // Modern animated loading circle
                ZStack {
                    // Outer pulsing circle
                    Circle()
                        .stroke(
                            FitAIDesign.Gradients.circleGradient,
                            lineWidth: 3
                        )
                        .frame(width: FitAIDesign.Sizes.loadingCircleLarge, height: FitAIDesign.Sizes.loadingCircleLarge)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0.5 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    // Inner rotating circle
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            FitAIDesign.Gradients.reverseGradient,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: FitAIDesign.Sizes.loadingCircleSmall, height: FitAIDesign.Sizes.loadingCircleSmall)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(
                            Animation.linear(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: rotationAngle
                        )
                    
                    // Center dot
                    Circle()
                        .fill(FitAIDesign.Gradients.primaryVertical)
                        .frame(width: FitAIDesign.Sizes.centerDotSize, height: FitAIDesign.Sizes.centerDotSize)
                        .scaleEffect(isAnimating ? 1.3 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                
                // Typing animation text
                Text(displayedText)
                    .font(FitAIDesign.Typography.bodyText)
                    .fontWeight(.medium)
                    .foregroundColor(FitAIDesign.Colors.textPrimary)
                    .frame(height: 60)
                    .animation(.easeInOut(duration: 0.1), value: displayedText)
                
                // Animated dots
                HStack(spacing: FitAIDesign.Spacing.small) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(FitAIDesign.Gradients.primaryVertical)
                            .frame(width: FitAIDesign.Sizes.dotSize, height: FitAIDesign.Sizes.dotSize)
                            .scaleEffect(isAnimating ? 1.5 : 1.0)
                            .opacity(isAnimating ? 0.5 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
            }
            .padding(FitAIDesign.Spacing.xxLarge)
        }
        .onAppear {
            isAnimating = true
            rotationAngle = 360
            startTypingAnimation()
        }
    }
    
    // Function to type out text character by character
    func typeText(_ text: String) {
        displayedText = ""
        currentCharIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if currentCharIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentCharIndex)
                displayedText += String(text[index])
                currentCharIndex += 1
            } else {
                timer.invalidate()
                // Wait 2 seconds before starting the next text
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    nextText()
                }
            }
        }
    }
    
    // Function to move to the next text
    func nextText() {
        currentTextIndex = (currentTextIndex + 1) % texts.count
        typeText(texts[currentTextIndex])
    }
    
    // Function to start the typing animation cycle
    func startTypingAnimation() {
        typeText(texts[currentTextIndex])
    }
}

// Convenience wrapper to avoid naming conflicts
struct ProgressView: View {
    var body: some View {
        CustomProgressView()
    }
}

#Preview {
    CustomProgressView()
}
