//
//  DayCardView.swift
//  myPedometer
//
//  Created by Sam Roman on 1/24/24.
//

import SwiftUI

struct DayCardView: View {
    @ObservedObject var log: DailyLog
    var isToday: Bool
    let dailyStepGoal: Int
    
    @State private var showMotion: Bool = false
    let animationDuration = 0.5
    
    var body: some View {
        VStack {
            Spacer()
            if isToday {
                todayView
            } else {
                notTodayView
            }
            Spacer()
        }
        .onDisappear {
            showMotion = false 
        }
        .frame(maxWidth: .infinity, maxHeight: 400)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 10)
    }
    
    // MARK: - Subviews
    
    private var todayView: some View {
        VStack {
        Text("Today")
        .font(.title)
        .bold()
        .foregroundColor(.primary)
            HStack {
                VStack{
                    animatedFigure
                    stepsText
                    goalStatusIndicator
                }
            }
        }
    }
    
    private var notTodayView: some View {
        VStack(alignment: .center) {
            stepsText
            GoalStatusView(status: log.totalSteps >= dailyStepGoal ? .achieved : .notAchieved)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Views
    
    private var animatedFigure: some View {
        Image(systemName: showMotion ? "figure.walk.motion" : "figure.walk")
            .font(.system(size: 60))
            .foregroundColor(.primary)
            .onAppear {
                withAnimation(Animation.linear(duration: animationDuration).repeatCount(1)) {
                    self.showMotion.toggle()
                }
            }
    }
    
    private var goalStatusIndicator: some View {
        switch (log.totalSteps) >= dailyStepGoal {
        case true:
            return AnyView(GoalStatusView(status: .achieved))
        case false:
            return AnyView(ProgressCircleView(percentage: Double(log.totalSteps) / Double(dailyStepGoal)))
        }
    }
    
    private var stepsText: some View {
        Text("\(log.totalSteps) steps")
            .font(.title)
            .foregroundColor(.primary)
            .fontWeight(.semibold)
    }

}
