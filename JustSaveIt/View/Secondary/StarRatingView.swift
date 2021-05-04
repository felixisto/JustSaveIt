//
//  StarRatingView.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 27.04.21.
//

import SwiftUI

struct StarRatingView: View {
    @ObservedObject var model: StarRatingViewModel
    var isMutable: Bool
    
    var body: some View {
        HStack {
            ForEach(StarRatingViewModel.STARS_COUNT) { stars in
                Image(systemName: imageKey(for: stars))
                    .renderingMode(.template)
                    .foregroundColor(.yellow)
                    .frame(width: starWidth, height: starHeight, alignment: .center)
                    .onTapGesture {
                        onTapStar(stars)
                    }
                    .allowsHitTesting(isMutable)
            }
        }
    }
    
    var starWidth: CGFloat {
        return isMutable ? 32 : 18
    }
    
    var starHeight: CGFloat {
        return isMutable ? 32 : 18
    }
    
    func onTapStar(_ value: Int) {
        model.setStars(value: Int32(value))
    }
    
    func imageKey(for stars: Int) -> String {
        if stars <= model.starsValue {
            return "star.fill"
        } else {
            return "star"
        }
    }
}
