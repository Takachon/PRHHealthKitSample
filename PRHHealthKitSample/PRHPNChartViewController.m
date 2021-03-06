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

    [[PRHHealthKitService sharedService] stepCountCollectionWithUnitType:PRHHealthKitStatisticsCollectionUniteTypeDate
                                                 quantitySamplePredicate:[HKQuery predicateForSamplesWithStartDate:[[NSDate date] dateBySubtractingDays:10]
                                                                                                           endDate:nil
                                                                                                           options:HKQueryOptionStrictStartDate] //サンプルの取得開始日時が10日前以降
                                                       completionHandler:^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *result, NSError *error) {
                                                           [self editLineChartWithLineChart:lineChart
                                                                                      query:query
                                                                                    resulet:result
                                                                                      error:error];
                                                       }];

    [self.view addSubview:lineChart];
}

- (void)editLineChartWithLineChart:(PNLineChart *)lineChart query:(HKStatisticsCollectionQuery *)query resulet:(HKStatisticsCollection *)result error:(NSError *)error {
    NSInteger itemCount = 7;

    NSMutableArray *xLabels = [NSMutableArray new];
    NSMutableArray *dataItems = [NSMutableArray new];
    [result enumerateStatisticsFromDate:[NSDate dateWithDaysBeforeNow:itemCount - 1] // 今日を含んだ過去1週間
                                 toDate:[NSDate date]
                              withBlock:^(HKStatistics *result, BOOL *stop) {
                                  NSString *dateString = [result.startDate.description substringToIndex:10];
                                  double stepValue = [[result sumQuantity] doubleValueForUnit:nil];
                                  [xLabels addObject:dateString];
                                  [dataItems addObject:[PNLineChartDataItem dataItemWithY:stepValue]];
                                  NSLog(@"%@|%@ %f", result.startDate.description, result.endDate.description, stepValue);
                              }];

    PNLineChartData *data = [PNLineChartData new];
    data.itemCount = itemCount;
    data.getData = ^(NSUInteger index) {
        return dataItems[index];
    };

    dispatch_async(dispatch_get_main_queue(), ^{
        [lineChart setXLabels:xLabels];
        lineChart.chartData = @[ data ];
        [lineChart strokeChart];
    });
}

@end
