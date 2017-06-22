//
//  ReceiptTableViewCell.h
//  Receipts++
//
//  Created by Alex Lee on 2017-06-22.
//  Copyright © 2017 Alex Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiptTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@property (weak, nonatomic) IBOutlet UILabel *noteLabel;

@end
