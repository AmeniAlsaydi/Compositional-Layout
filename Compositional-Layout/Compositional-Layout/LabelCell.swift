//
//  LabelCell.swift
//  Compositional-Layout
//
//  Created by Amy Alsaydi on 8/17/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import UIKit

class LabelCell: UICollectionViewCell {
    
    public lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        textLabelCondtraints()
    }
    
    private func textLabelCondtraints() {
        // 1.
        addSubview(textLabel)
        
        //2. // we will handle layout using Auto Layout not autoresizing mask
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //3. set up required constraints
        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        
        ])
    }
}

