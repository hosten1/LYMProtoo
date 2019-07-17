//
//  LYMProtooMessage.m
//  RTCEngine
//
//  Created by ymluo on 2019/7/17.
//  Copyright © 2019 ymluo. All rights reserved.
//

#import "LYMProtooMessage.h"
#import "RTCJSON.h"



@implementation LYMProtooMessageRequst



@end
@implementation LYMProtooMessageMessage



@end

@implementation LYMProtooMessage
+ (LYMProtooMessageMessage*)parseWithJsonString:(NSString*)jsonString{
    RTCJSON *jsonObj = [[RTCJSON alloc]initWithParseString:jsonString];
    if (jsonObj.type == JSONtypeArray) {
        return nil;
    }
    NSDictionary *object = jsonObj.dictionaryObj;
    LYMProtooMessageMessage *message = [[LYMProtooMessageMessage alloc]init];
    if ([object.allKeys containsObject:@"request"]) {
        message.type = LYMProtooMessageMessageTypeRequst;
        message.ID =  [NSString stringWithFormat:@"%@",object[@"id"]];
        message.method = object[@"method"];
        message.data = object[@"data"];
        message.parseData = object;
    }else if ([object.allKeys containsObject:@"response"]){
        message.type = LYMProtooMessageMessageTypeResopnse;
        message.ID = [NSString stringWithFormat:@"%@",object[@"id"]];
        // Success
        if ([object[@"ok"] boolValue]) {
            message.ok = YES;
            message.data = object[@"data"];
        }else{
            message.ok = NO;
            message.errorCode = object[@"errorCode"];
            message.errorReason = object[@"errorReason"];
        }
        message.parseData = object;
    }else if ([object.allKeys containsObject:@"notification"]){
        message.type = LYMProtooMessageMessageTypeNotification;
        message.ID = [NSString stringWithFormat:@"%@",object[@"id"]];
        message.method = object[@"method"];
        message.data = object[@"data"];
        message.parseData = object;
    }else{
    
    }
    return message;
}
+(LYMProtooMessageRequst *)createRequestWithMethod:(NSString *)method data:(NSDictionary *)data{
    int64_t ID = arc4random_uniform(9999999);
    NSMutableDictionary *dataMut = [NSMutableDictionary dictionaryWithDictionary:data];
    LYMProtooMessageRequst *pmr = [[LYMProtooMessageRequst alloc]init];
    pmr.ID = [NSString stringWithFormat:@"%lld",ID];
    if ([method isEqualToString:@"request"] || [method isEqualToString:@"notification"]) {
        pmr.method = data[@"method"];
    }else{
        pmr.method = method;
    }
    if ([dataMut.allKeys containsObject:@"method"]) {
        [dataMut removeObjectForKey:@"method"];
    }
    pmr.data = dataMut;
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    mut[@"request"] = [NSNumber numberWithBool:true];
    mut[@"id"] = @(pmr.ID.longLongValue);
    mut[@"method"] = pmr.method;
    mut[@"data"] = pmr.data;
    RTCJSON *json = [[RTCJSON alloc]initWithObject:mut];
    pmr.jsonString = json.rawString;
    return pmr;
}
+ (NSString*)createSuccessResponseWithRequest:(LYMProtooMessageRequst*)request data:(NSDictionary*)data{
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    mut[@"resopnse"] = [NSNumber numberWithBool:true];
    mut[@"id"] = @([request.ID longLongValue]);
    mut[@"ok"] = [NSNumber numberWithBool:false];
    mut[@"data"] = data;
    RTCJSON *json = [[RTCJSON alloc]initWithObject:mut];
    return json.rawString;
}
+(NSString *)createSuccessResponseWithRequest:(LYMProtooMessageRequst *)request errorCode:(NSString *)errorCode errorReason:(NSString *)errorReason{
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    mut[@"resopnse"] = [NSNumber numberWithBool:true];
    mut[@"id"] = @([request.ID longLongValue]);
    mut[@"ok"] = [NSNumber numberWithBool:false];
    mut[@"errorCode"] = errorCode;
    mut[@"errorReason"] = errorReason;
    RTCJSON *json = [[RTCJSON alloc]initWithObject:mut];
    
    return json.rawString;
}

+ (NSString*)createNotificationWtihMethod:(NSString*)method data:(NSDictionary*)data{
    NSMutableDictionary *dataMut = [NSMutableDictionary dictionaryWithDictionary:data];
    NSString *methodNotify;
    if ([method isEqualToString:@"request"] || [method isEqualToString:@"notification"]) {
        methodNotify = data[@"method"];
    }else{
        methodNotify = method;
    }
    if ([dataMut.allKeys containsObject:@"method"]) {
        [dataMut removeObjectForKey:@"method"];
    }
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    mut[@"notification"] = [NSNumber numberWithBool:true];
    mut[@"method"] = methodNotify;
    mut[@"data"] = dataMut;
    RTCJSON *json = [[RTCJSON alloc]initWithObject:mut];
    return json.rawString;
}
@end
