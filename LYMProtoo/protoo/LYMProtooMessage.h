//
//  LYMProtooMessage.h
//  RTCEngine
//
//  Created by ymluo on 2019/7/17.
//  Copyright © 2019 ymluo. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger,LYMProtooMessageMessageType) {
    LYMProtooMessageMessageTypeRequst=0,//
    LYMProtooMessageMessageTypeResopnse=1,//
    LYMProtooMessageMessageTypeNotification=2//
    
};
NS_ASSUME_NONNULL_BEGIN
@interface LYMProtooMessageRequst : NSObject
@property(nonatomic,copy) NSString *ID;
@property(nonatomic,copy) NSString *method;
@property(nonatomic,strong) NSDictionary *data;
@property(nonatomic,copy) NSString *jsonString;
@end
@interface LYMProtooMessageMessage : NSObject
@property(nonatomic,copy) NSString *ID;
@property(nonatomic,assign)LYMProtooMessageMessageType type;
@property(nonatomic,copy)   NSString *method;
@property(nonatomic,strong) NSDictionary *data;
@property(nonatomic,strong) NSDictionary *parseData;
@property(nonatomic,assign) BOOL ok;
@property(nonatomic,copy) NSString *errorCode;
@property(nonatomic,copy) NSString *errorReason;
@end
@interface LYMProtooMessage : NSObject
+ (LYMProtooMessageMessage*)parseWithJsonString:(NSString*)jsonString;
+ (LYMProtooMessageRequst*)createRequestWithMethod:(NSString*)method data:(NSDictionary*)data;
+ (NSString*)createSuccessResponseWithRequest:(LYMProtooMessageRequst*)request data:(NSDictionary*)data;
+ (NSString*)createSuccessResponseWithRequest:(LYMProtooMessageRequst*)request errorCode:(NSString*)errorCode errorReason:(NSString*)errorReason;
+ (NSString*)createNotificationWtihMethod:(NSString*)method data:(NSDictionary*)data;
@end

NS_ASSUME_NONNULL_END
