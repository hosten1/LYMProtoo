//
//  RTCEngineProtoo.m
//  RTCEngine
//
//  Created by 熊清 on 2018/12/26.
//  Copyright © 2018 ymluo. All rights reserved.
//
//#define KUserSocketIO

#import "RTCEngineProtoo.h"
#ifdef KUserSocketIO
#import <VPSocketIO/VPSocketIO.h>
#else
#import <Jetfire/Jetfire.h>
#import "LYMProtooMessage.h"
#endif
typedef void(^notifyInfoCB)(NSString* emit,id data);
#ifdef KUserSocketIO
@interface RTCEngineProtoo()
@property (nonatomic,strong)    VPSocketIOClient *socket;
@property (nonatomic,strong)    NSMutableDictionary *reqCallbacks;
#else



@interface RTCEngineProtoo()
@property (nonatomic,strong)    JFRWebSocket *webSocket;
@property (nonatomic,strong)    NSMutableDictionary *reqCallbacks;

#endif
@property (nonatomic,copy) notifyInfoCB notifyInfo;
@property (nonatomic,assign)BOOL isClose;
@end

@implementation RTCEngineProtoo

static RTCEngineProtoo *instance;
+ (instancetype)instance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
//        instance->reqCallbacks = [NSMutableDictionary dictionaryWithCapacity:0];
        instance.isClose = NO;
    });
    return instance;
}
-(NSMutableDictionary *)reqCallbacks{
    if (!_reqCallbacks) {
        _reqCallbacks = [NSMutableDictionary dictionary];
    }
    return _reqCallbacks;
}
-(void)listenWithCB:(void (^)(NSString * _Nonnull, id _Nonnull))notifyInfo{
    if (notifyInfo) {
        _notifyInfo = notifyInfo;
    }
}
#ifdef KUserSocketIO

- (void)connectTo:(NSString*)server withParams:(NSDictionary*)params{
    _isClose = NO;
    VPSocketLogger *logger = [VPSocketLogger new];
    socket = [[VPSocketIOClient alloc] init:[NSURL URLWithString:server]
                                 withConfig:@{@"log": @NO,
                                              @"reconnects":@YES,
                                              @"reconnectAttempts":@(3),
                                              @"forcePolling": @NO,
                                              @"secure": @YES,
                                              @"forceNew":@YES,
                                              @"forceWebsockets":@YES,
                                              @"selfSigned":@YES,
                                              @"reconnectWait":@5000,
                                              @"nsp":@"/",
                                              @"connectParams":params,
                                              @"logger":logger
                                              }];
    [socket on:kSocketEventConnect callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            self.notifyInfo(@"open",array[1]);
        }else{
            self.notifyInfo(@"open",array[0]);
        }
        [RTCEngineHandler.instance handleEvent:nil withParam:[NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:client_state_connected]]];
    }];
    [socket on:kSocketEventDisconnect callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            self.notifyInfo(@"disconnected",array[1]);
        }else{
            self.notifyInfo(@"disconnected",array[0]);
        }
        [RTCEngineHandler.instance handleEvent:nil withParam:[NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:client_state_disconnect]]];
    }];
    [socket on:kSocketEventError callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            self.notifyInfo(@"error",array[1]);
        }else{
            self.notifyInfo(@"error",array[0]);
        }
        [RTCEngineHandler.instance handleEvent:nil withParam:[NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:client_state_error]]];
    }];
    [socket on:kSocketEventReconnect callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            self.notifyInfo(@"reconnect",array[1]);
        }else{
            self.notifyInfo(@"reconnect",array[0]);
        }
    }];
    [socket on:kSocketEventReconnectAttempt callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            self.notifyInfo(@"reconnectAttempt",array[1]);
        }else{
            self.notifyInfo(@"reconnectAttempt",array[0]);
        }
    }];
    [socket on:kSocketEventStatusChange callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            //            self.notifyInfo(@"disconnected",array[1]);
        }else{
            //            self.notifyInfo(@"disconnected",array[0]);
        }
    }];
    [socket on:@"mediasoup-notification" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            self.notifyInfo(@"mediasoup-notification",array[1]);
        }else{
            self.notifyInfo(@"mediasoup-notification",array[0]);
        }
        [RTCEngineHandler.instance handleEvent:@"mediasoup-notification" withParam:array];
    }];
    [socket on:@"active-speaker" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            self.notifyInfo(@"active-speaker",array[1]);
        }else{
            self.notifyInfo(@"active-speaker",array[0]);
        }
        [RTCEngineHandler.instance handleEvent:@"active-speaker" withParam:array];
    }];
    [socket on:@"living" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            self.notifyInfo(@"living",array[1]);
        }else{
            self.notifyInfo(@"living",array[0]);
        }
        [RTCEngineHandler.instance handleEvent:@"living" withParam:array];
    }];
    [socket on:@"verify" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            self.notifyInfo(@"verify",array[1]);
        }else{
            self.notifyInfo(@"verify",array[0]);
        }
        [RTCEngineHandler.instance handleEvent:@"living" withParam:array];
    }];
    [socket on:@"display-name-changed" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        [RTCEngineHandler.instance handleEvent:@"display-name-changed" withParam:array];
    }];
    [socket on:@"profile-picture-changed" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        [RTCEngineHandler.instance handleEvent:@"profile-picture-changed" withParam:array];
    }];
    [socket on:@"auth" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        [RTCEngineHandler.instance handleEvent:@"auth" withParam:array];
    }];
    [socket on:@"raisehand-message" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        [RTCEngineHandler.instance handleEvent:@"raisehand-message" withParam:array];
    }];
    [socket on:@"chat-message-receive" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        [RTCEngineHandler.instance handleEvent:@"chat-message-receive" withParam:array];
    }];
    [socket on:@"file-receive" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        [RTCEngineHandler.instance handleEvent:@"file-receive" withParam:array];
    }];
    [socket connectWithTimeoutAfter:1 withHandler:^{
        if (instance.isClose) {
            return ;
        }
        self.notifyInfo(@"connect_timeout",@"connectWithTimeoutAfter");
    }];
    [socket on:@"request" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            self.notifyInfo(@"request",array[1]);
        }else{
            self.notifyInfo(@"request",array[0]);
        }
        [RTCEngineHandler.instance handleEvent:@"request" withParam:array];
    }];
    [socket on:@"notification" callback:^(NSArray *array, VPSocketAckEmitter *emitter) {
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            self.notifyInfo(@"notification",array[1]);
        }else{
            self.notifyInfo(@"notification",array[0]);
        }
        [RTCEngineHandler.instance handleEvent:@"notification" withParam:array];
    }];
}

- (void)sendMessage:(NSDictionary*)message withMethod:(NSString*)method{
    VPSocketOnAckCallback *callback = [socket emitWithAck:method items:@[message]];
    //    __weak typeof(self) weakSelf = self;
    [callback timingOutAfter:3 callback:^(NSArray *array) {
        //        __strong typeof(weakSelf) blockSelf = weakSelf;
        if (instance.isClose) {
            return ;
        }
        if (array.count > 1) {
            [RTCEngineHandler.instance handleResponse:array[1]];
        }else{
            if ([array[0] isKindOfClass:[NSNull class]]) {
                //通知上层已退出房间
                [RTCEngineHandler.instance handleEvent:nil withParam:[NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:client_state_exited]]];
                //断开socket连接
                //                [blockSelf->socket disconnect];
            }else{
                NSLog(@"Error:%@",array);
                [RTCEngineHandler.instance handleError:array[0]];
            }
        }
    }];
}
-(void)sendMessage:(NSDictionary *)message withMethod:(NSString *)method dataCb:(nonnull void (^)(NSDictionary * _Nonnull))dataCB{
    VPSocketOnAckCallback *callback = [socket emitWithAck:method items:@[message]];
    //    NSString *key = [NSString stringWithFormat:@"%0x",callback];
    NSString *key = [NSString stringWithFormat:@"%d",callback.ackNum];
    [self.reqCallbacks setObject:dataCB forKey:key];
    __weak typeof(self) weakSelf = self;
    [callback timingOutAfter:5 callback:^(NSArray *array) {
        __strong typeof(weakSelf) blockSelf = weakSelf;
        if (array.count > 1) {
            //             NSString *key = [NSString stringWithFormat:@"%0x",callback];
            NSString *key = [NSString stringWithFormat:@"%d",callback.ackNum];
            void (^block) (NSDictionary*) = [blockSelf->reqCallbacks objectForKey:key];
            if (block) {
                block(array[1]);
            }
            [blockSelf->reqCallbacks removeObjectForKey:key];
        }else{
            NSLog(@"error:%@ %s",array,__FILE__);
            if ([array[0] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = array[0];
                if ([dic.allKeys containsObject:@"result"]) {
                    NSString *key = [NSString stringWithFormat:@"%d",callback.ackNum];
                    void (^block) (NSDictionary*) = [blockSelf->reqCallbacks objectForKey:key];
                    if (block) {
                        block(array[0]);
                    }
                    [blockSelf->reqCallbacks removeObjectForKey:key];
                }else{
                    
                    [RTCEngineHandler.instance handleError:dic];
                }
            }
            
        }
        
    }];
}
-(void)close{
    _isClose = YES;
    if (_notifyInfo) {
        _notifyInfo = nil;
    }
    [reqCallbacks removeAllObjects];
    [socket disconnect];
    [socket removeAllHandlers];
    socket = nil;
    //    if (instance) {
    //        instance = nil;
    //    }
}
#else
- (void)connectTo:(NSString*)server withParams:(NSDictionary*)params{
    _webSocket.delegate = nil;
    [_webSocket disconnect];
//    https://192.168.1.222:3443/?peerName=luoyongmeng&roomId=12345
    NSMutableString *serVerString = [NSMutableString string];
    if ([server hasPrefix:@"https://"]) {
        [serVerString appendString:[server stringByReplacingOccurrencesOfString:@"https://" withString:@"wss://"]];
    }else if ([server hasPrefix:@"wss://"]) {
        [serVerString appendString:server];
    }
    [serVerString appendString:@"/?"];
    __block NSInteger idx = params.count - 1;
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (idx > 0) {
             [serVerString appendFormat:@"%@=%@&",key,obj];
        }else{
            [serVerString appendFormat:@"%@=%@",key,obj];
        }
        idx--;
    }];
    NSURL *url = [NSURL URLWithString:serVerString];
    _webSocket = [[JFRWebSocket alloc] initWithURL:url protocols:@[@"protoo"]];
    _webSocket.selfSignedSSL = YES;
//    [_webSocket addHeader:@"Sec-WebSocket-Protocol" forKey:@"protoo"];
//    [_webSocket addHeader:@"Sec-WebSocket-Version" forKey:@"14"];
//    [_webSocket addHeader:@"My-Awesome-Header" forKey:@"Everything is Awesome!"];
    //websocketDidConnect
    __weak typeof(self) weakSelf = self;
    _webSocket.onConnect = ^{
        NSLog(@"websocket is connected");
        if (instance.isClose) {
                    return ;
                }
            //    if (array.count > 1) {
            //        self.notifyInfo(@"open",array[1]);
            //    }else{
                    weakSelf.notifyInfo(@"open",nil);
            //    }
    };
    _webSocket.onDisconnect = ^(NSError *error) {
        NSLog(@"websocket is disconnected: %@",[error localizedDescription]);
        if (weakSelf.isClose) {
            return ;
        }
        weakSelf.notifyInfo(@"disconnected",error);
    };
    _webSocket.onText = ^(NSString *text) {
        NSLog(@"got some text: %@",text);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.isClose) {
            return;
        }
        LYMProtooMessageMessage *message = [LYMProtooMessage parseWithJsonString:text];
        switch (message.type) {
            case LYMProtooMessageMessageTypeRequst:{
                NSMutableDictionary *respdata = [NSMutableDictionary dictionaryWithDictionary:message.data];
                respdata[@"method"] = message.method;
                strongSelf.notifyInfo(@"request",respdata);
                //                [RTCEngineHandler.instance handleEvent:@"request" withParam:message.data];
               
            }
                
                break;
            case LYMProtooMessageMessageTypeResopnse:{
                if (![strongSelf.reqCallbacks.allKeys containsObject:message.ID]) {
                    NSLog(@"ERROR");
                }
                void(^resp)(NSDictionary* data) = strongSelf.reqCallbacks[message.ID];
                if (resp) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        resp(message.data);
                        [strongSelf.reqCallbacks removeObjectForKey:message.ID];
                    });
                    
                }
                
            }
                
                break;
            case LYMProtooMessageMessageTypeNotification:{
                NSMutableDictionary *respdata = [NSMutableDictionary dictionaryWithDictionary:message.data];
                respdata[@"method"] = message.method;
                strongSelf.notifyInfo(@"notification",respdata);
//                [RTCEngineHandler.instance handleEvent:@"notification" withParam:message.data];
            }
                
                break;
        }
    };
    //websocketDidReceiveData
    _webSocket.onData = ^( NSData *data) {
        NSLog(@"got some binary data: %lu",(unsigned long)data.length);
    };
    //you could do onPong as well.
    [_webSocket connect];
}

- (void)sendMessage:(NSDictionary*)message withMethod:(NSString*)method{
    if (self.isClose) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *request =  [LYMProtooMessage createNotificationWtihMethod:method data:message];
        [self.webSocket writeString:request];
    });
    
}
- (void)sendMessage:(NSDictionary*)message withMethod:(NSString*)method dataCb:(void(^)(NSDictionary* data))dataCB{
    if (self.isClose) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LYMProtooMessageRequst *request =  [LYMProtooMessage createRequestWithMethod:method data:message];
        [self.reqCallbacks setObject:dataCB forKey:request.ID];
        [self.webSocket writeString:request.jsonString];
    });
    
}
- (void)close{
    _isClose = YES;
    if (_notifyInfo) {
        _notifyInfo = nil;
    }
    [self.reqCallbacks removeAllObjects];
    [_webSocket disconnect];
    self.webSocket = nil;
//    instance = nil;
}
///--------------------------------------
#pragma mark - SRWebSocketDelegate
///--------------------------------------

//- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
//    NSLog(@"Websocket Connected");
//    if (instance.isClose) {
//        return ;
//    }
////    if (array.count > 1) {
////        self.notifyInfo(@"open",array[1]);
////    }else{
//        self.notifyInfo(@"open",nil);
////    }
//    [RTCEngineHandler.instance handleEvent:nil withParam:[NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:client_state_connected]]];
//}

//- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;{
//    NSLog(@":( Websocket Failed With Error %@", error);
//    if (instance.isClose) {
//        return ;
//    }
////    if (array.count > 1) {
//        self.notifyInfo(@"error",error.description);
////    }else{
////        self.notifyInfo(@"error",array[0]);
////    }
//    [RTCEngineHandler.instance handleEvent:nil withParam:[NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:client_state_error]]];
//    _webSocket = nil;
//}
//
//- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(nonnull NSString *)string{
//    NSLog(@"Received \"%@\"", string);
//}
//
//- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
//    NSLog(@"WebSocket closed");
//    _webSocket = nil;
//}
//
//- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
//    NSLog(@"WebSocket received pong");
//}
//-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
//    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//    __block NSURLCredential *credential = nil;
//    // 判断服务器返回的证书是否是服务器信任的
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
//    {
//        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//        if (credential)
//        {
//            disposition = NSURLSessionAuthChallengeUseCredential; // 使用证书
//        }
//        else
//        {
//            disposition = NSURLSessionAuthChallengePerformDefaultHandling; // 忽略证书 默认的做法
//        }
//    }
//    else
//    {
//        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge; // 取消请求,忽略证书
//    }
//    if (completionHandler)// 安装证书
//    {
//        completionHandler(disposition, credential);
//    }
//}
#endif
-(void)dealloc{
    NSLog(@"RTCEnginProtoo dealloc()");
}
@end
