//
//  RTCEngineProtoo.h
//  RTCEngine
//
//  Created by 熊清 on 2018/12/26.
//  Copyright © 2018 ymluo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCJSON.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTCEngineProtoo : NSObject

/**
 socket网络实体对象单例

 @return RTCEngineProtoo
 */
+ (instancetype)instance;
- (void)listenWithCB:(void(^)(NSString* emit,id data))notifyInfo;
/**
 连接服务器

 @param server 服务器地址
 @param params 传递的参数
 */
- (void)connectTo:(NSString*)server withParams:(NSDictionary*)params;

/**
 给服务器发消息

 @param message 消息内容
 @param method 指令
 */
- (void)sendMessage:(NSDictionary*)message withMethod:(NSString*)method;
- (void)sendMessage:(NSDictionary*)message withMethod:(NSString*)method dataCb:(void(^)(NSDictionary* data))dataCB;
- (void)close;
@end

NS_ASSUME_NONNULL_END
