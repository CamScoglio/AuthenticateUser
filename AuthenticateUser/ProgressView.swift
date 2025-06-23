import Foundation
import SwiftUI

//Create a progress view that shows a modern loding gif and a message that says "Personalizing your experience..."
struct ProgressView: View {
  var body: some View {
    VStack {
      Image(systemName: "person.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)
