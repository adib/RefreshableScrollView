//
//  BSRefreshableScrollView_Private.h
//  RefreshableScrollView
//
//  Created by Sasmito Adibowo on 19-11-12.
//  Copyright (c) 2012 Basil Salad Software. All rights reserved.
//

#import "BSRefreshableScrollView.h"

@interface BSRefreshableScrollView ()

@property (nonatomic,strong) NSProgressIndicator* topProgressIndicator;
@property (nonatomic,strong) NSProgressIndicator* bottomProgressIndicator;
@property (nonatomic,readonly,strong) NSView* headerView;

@property (nonatomic,readonly,strong) NSView* footerView;

@property (nonatomic,readwrite) BSRefreshableScrollViewSide refreshingSides;
@property (nonatomic,readwrite) BSRefreshableScrollViewSide triggeredRefreshingSides;


@end
