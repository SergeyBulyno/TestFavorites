//
//  SBQuestionCell.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/24/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBQuestionCell.h"

#import "SBQuestionCellItem.h"
#import "Masonry.h"

@interface SBQuestionCell ()

@property (strong, nonatomic) UILabel *ownerLabel;
@property (strong, nonatomic) UILabel *viewCountLabel;
@property (strong, nonatomic) UILabel *scoreLabel;
@property (strong, nonatomic) UILabel *lastDateLabel;

@property (strong, nonatomic) UISwitch *switchButton;

@end

@implementation SBQuestionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
			  reuseIdentifier:(NSString *)reuseIdentifier {

	self = [super initWithStyle:style
				reuseIdentifier:reuseIdentifier];
	if (self) {
		[self setupSubviews];
		[self setupConstraints];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
}

- (void)setupSubviews {
	self.layer.borderColor = [UIColor whiteColor].CGColor;
	self.layer.borderWidth = 1.0;
	self.ownerLabel = [self setupAndReturnLabel];
	self.viewCountLabel = [self setupAndReturnLabel];
	self.viewCountLabel.textAlignment = NSTextAlignmentRight;
	self.scoreLabel = [self setupAndReturnLabel];
	self.scoreLabel.textAlignment = NSTextAlignmentRight;
	self.lastDateLabel = [self setupAndReturnLabel];
	self.switchButton = [UISwitch new];
	[self.switchButton setOnTintColor:[UIColor grayColor]];
	[self.contentView addSubview:self.switchButton];
}

- (void)setupConstraints {
	CGFloat sideOffset = 8;
	[self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(self.contentView).with.offset(-sideOffset);
		make.centerY.equalTo(self.contentView);
	}];

	[self.ownerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.contentView).with.offset(sideOffset);
		make.top.equalTo(self.contentView);
		make.height.equalTo(self.contentView.mas_height).multipliedBy(0.5);
	}];

	[self.lastDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.contentView).with.offset(sideOffset);
		make.top.equalTo(self.ownerLabel.mas_bottom);
		make.height.equalTo(self.ownerLabel);
	}];

	[self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(self.switchButton.mas_left).with.offset(-sideOffset);
		make.left.equalTo(self.ownerLabel.mas_right).with.offset(sideOffset);
		make.top.equalTo(self.ownerLabel);
		make.height.equalTo(self.ownerLabel);
	}];

	[self.viewCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(self.switchButton.mas_left).with.offset(-sideOffset);
		make.left.equalTo(self.lastDateLabel.mas_right).with.offset(sideOffset);
		make.top.equalTo(self.lastDateLabel);
		make.height.equalTo(self.lastDateLabel);
	}];
}

- (void)setItem:(SBQuestionCellItem *)item {
	self.ownerLabel.text = item.ownerName;
	self.viewCountLabel.text = item.viewCount;
	self.scoreLabel.text = item.score;
	self.lastDateLabel.text = item.lastDate;
}

- (UILabel *)setupAndReturnLabel {
	UILabel *label = [UILabel new];
	label.textColor = [UIColor blackColor];
	label.font = [UIFont systemFontOfSize:14];
	[self.contentView addSubview:label];
	return label;
}

@end
