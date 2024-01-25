//
//  HomeView.swift
//  myPedometer
//
//  Created by Sam Roman on 1/24/24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: StepDataViewModel
    @ObservedObject var liveStepViewModel: LiveStepViewModel

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.stepDataList.sorted(by: { $0.date! > $1.date! }), id: \.self) { log in
                        NavigationLink(destination: DetailView(dayLog: log)) {
                            DayCardView(log: log, liveStepCount: liveStepViewModel.isToday() ? liveStepViewModel.liveStepCount : nil)
                        }
                    }
                }
            }
            .navigationBarTitle("mySteps")
        }
        .backgroundStyle(.white)
    }
}