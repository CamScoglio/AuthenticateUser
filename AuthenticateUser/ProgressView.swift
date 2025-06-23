import Foundation
import SwiftUI

//Create a progress view that shows a modern loading circle and a message that says "Personalizing your experience..."


struct ProgressView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1),
                    Color.blue.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Modern animated loading circle
                ZStack {
                    // Outer pulsing circle
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple, .blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 80, height: 80)
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
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(
                            Animation.linear(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: rotationAngle
                        )
                    
                    // Center dot
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 12, height: 12)
                        .scaleEffect(isAnimating ? 1.3 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                
                // Loading text with typing animation
                VStack(spacing: 8) {
                    Text("Personalizing your experience"
                        .prefix(typedCharacters1))
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .onAppear {
                            animateText1()
                        }
                    
                    Text("Analyzing your fitness goals"
                        .prefix(typedCharacters2))
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                animateText2()
                            }
                        }
                    
                    Text("Creating your custom plan"
                        .prefix(typedCharacters3))
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                                animateText3()
                            }
                        }
                }
                
                // Animated dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 8, height: 8)
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
            .padding(40)
        }
        .onAppear {
            isAnimating = true
            rotationAngle = 360
        }
    }
}

#Preview {
    ProgressView()
}
