//
//  PRHPNChartViewController.m
//  PRHHealthKitSample
//
//  Created by 清 貴幸 on 2015/04/23.
//  Copyright (c) 2015年 VOYAGE GROUP. All rights reserved.
//

#import "PRHPNChartViewController.h"
#import <PNChart.h>
#import "PRHHealthKitService.h"
#import <NSDate+Escort.h>

@interface PRHPNChartViewController ()

@end

@implementation PRHPNChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __block PNLineChart *lineChart = [[PNLineChart alloc] initWithFrame:(CGRect){0, 200, 320, 200}];
    [[PRHHealthKitService sharedService] stepCountCollectionWithCompletionHandler:^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableArray *xLabels = [NSMutableArray new];
            NSMutableArray *dataItems = [NSMutableArray new];
            [result enumerateStatisticsFromDate:[NSDate dateWithDaysBeforeNow:result.sources.count + 1]
                                         toDate:[NSDate date]
                                      withBlock:^(HKStatistics *result, BOOL *stop) {
                                          [xLabels addObject:[result.startDate.description substringToIndex:10]];
                                          [dataItems addObject:[PNLineChartDataItem dataItemWithY:[[result sumQuantity] doubleValueForUnit:nil]]];
                                      }];
            
            PNLineChartData *data = [PNLineChartData new];
            data.itemCount = result.sources.count;
            data.getData = ^(NSUInteger index) {
                return dataItems[index];
            };
            
            [lineChart setXLabels:xLabels];
            lineChart.chartData = @[data];
            [lineChart strokeChart];
        });
    }];

    [self.view addSubview:lineChart];
}

@end
