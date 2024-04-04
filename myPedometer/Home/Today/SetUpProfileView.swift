//
//  SetUpProfileView.swift
//  myPedometer
//
//  Created by Sam Roman on 1/28/24.
//

import SwiftUI

struct SetUpProfileView: View {
    @EnvironmentObject var userSettingsManager: UserSettingsManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var newStepGoal: String = ""
    @State private var newCalGoal: String = ""
    @State private var isUpdating: Bool = false
    @State private var showingImagePicker: Bool = false
    @State private var inputImage: UIImage?
    var onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Set Daily Goals and Profile")
                .font(.largeTitle)
                .foregroundColor(.primary)
                .padding(.bottom)
            
            if let photoData = userSettingsManager.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .onTapGesture { showingImagePicker = true }
            } else {
                Image(systemName: "person.crop.circle.badge.plus")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .onTapGesture { showingImagePicker = true }
            }
            
            goalInputField(iconName: "shoe", placeholder: "Step Goal", binding: $newStepGoal)
            goalInputField(iconName: "flame", placeholder: "Calorie Goal", binding: $newCalGoal, isCalorie: true)
            
            Spacer()
            
            if isUpdating {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                confirmButton()
            }
        }
        .onAppear {
            self.newStepGoal = "\(self.userSettingsManager.dailyStepGoal)"
            self.newCalGoal = "\(self.userSettingsManager.dailyCalGoal)"
        }
        .padding()
        .background(.clear)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        userSettingsManager.photoData = inputImage.jpegData(compressionQuality: 0.8)
    }
    
    private func updateGoals() {
        isUpdating = true
        if let stepGoal = Int(newStepGoal), let calGoal = Int(newCalGoal), let photoData = userSettingsManager.photoData {
            userSettingsManager.updateUserDetails(image: UIImage(data: photoData), userName: userSettingsManager.userName, stepGoal: stepGoal, calGoal: calGoal, updateImage: true)
        }
        isUpdating = false
       onConfirm()
    }

    
    func goalInputField(iconName: String, placeholder: String, binding: Binding<String>, isCalorie: Bool = false) -> some View {
            VStack{
                HStack{
                    Image(systemName: iconName)
                        .foregroundColor(isCalorie ? .red : .blue)
                        .imageScale(.large)
                        .font(.system(size: 25))
                    Text(isCalorie ? "Calories" : "Steps")
                        .font(.title2)
                }
            TextField(placeholder, text: binding)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding([.leading, .trailing, .bottom])
            
            if isCalorie {
                Button(action: autoCalculateCalorieGoal) {
                    Text("Auto Calculate Calories")
                        .font(.caption)
                }
            }
        }
    }
    
    func confirmButton() -> some View {
        Button(action: updateGoals) {
            Text("Confirm")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.bottom)
    }
    
    func autoCalculateCalorieGoal() {
        // Show feedback that the goal was auto-calculated
        withAnimation {
            let dailyStepGoal = self.newStepGoal
            self.newStepGoal = String(Int((Double(dailyStepGoal) ?? 1) * 0.04))
            self.newCalGoal = String(self.newCalGoal)
        }
    }

}
