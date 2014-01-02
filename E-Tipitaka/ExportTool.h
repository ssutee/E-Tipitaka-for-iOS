//
//  ExportTool.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/25/55 BE.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ExportTool : NSObject

+ (void)exportData;
+ (NSString *)encodeData;
+ (NSString *)saveDataToFile;

@end
