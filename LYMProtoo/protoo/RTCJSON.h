//
//  JSON.h
//  objcJSON
//
//  Created by Duy Pham on 31/3/15.
//  Copyright (c) 2015 Duy Pham. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

typedef enum {
    JSONtypeDictionary,
    JSONtypeArray,
    JSONtypeString,
    JSONtypeNumber,
    JSONtypeBool,
    JSONtypeNull,
    JSONtypeUnknown,
} JSONtype;

@interface RTCJSON : NSObject

@property (nonatomic, strong, readonly) id object;
@property (nonatomic, readonly) JSONtype type;
@property (nonatomic, strong) NSError * error;

- (instancetype)initWithObject:(id)object; // accept both NSData and other JSON object values
- (instancetype)initWithJSONobject:(id)object; // NSDictionary, NSArray, NSNumber, NSString, NSNull, JSON
- (instancetype)initWithParseString:(NSString *)string; // 解析json数据
- (instancetype)initWithData:(NSData *)data; // only accept NSData
- (instancetype)initWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;
/**
 * 调用方法：字典：set：a[@"dd"] = b  get：b = a[@"dd"]
 *         数组：set：a[1] = b  get：b = a[1]
**/
// subscripting:
- (RTCJSON *)objectAtIndexedSubscript:(NSUInteger)idx;
- (RTCJSON *)objectForKeyedSubscript:(id)key;

- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index;
//通过键值下标设置属性
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying > )aKey;
//- (void)changeValueForKey:(NSString *)key changeValue:(id)obj error:(NSError**)error;
/****end***/

@property (nonatomic, strong,readwrite)NSDictionary*  dictionary;
@property (nonatomic, strong,readwrite)NSArray *array;
@property (nonatomic, copy,readwrite)  NSString *string;
@property (nonatomic, strong,readwrite)NSNumber *number;
@property (nonatomic, assign,readwrite)NSNumber *boolNumber;// to check for nil, and if exists, use boolValue

@property (nonatomic, strong,readwrite)NSDictionary*  dictionaryObj;
@property (nonatomic, strong,readwrite)NSArray *arrayObj;
/**
 json string 
 */
@property (nonatomic,readonly)NSString *rawString;

@end
