//
//  JSON.m
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

#import "RTCJSON.h"

@interface NSNumber (Bool)

- (BOOL)isBool;

@end
/**
 *  Error
 */
#define JSONErrorDomain @"JSONErrorDomain"
typedef enum {
    JSONErrorUnsupportedType,
    JSONErrorWrongType,
    JSONErrorIndexOutOfBounds,
    JSONErrorKeyNotExist
}JSONError;

/**
 *  private interface
 */
@interface RTCJSON () {
    id _object;
    JSONtype _type;
    NSError * _error;
}
@property (nonatomic,copy)NSString *rawString;
@end

/**
 *  implementation
 */
@implementation RTCJSON
@synthesize object = _object;
@synthesize type   = _type;
@synthesize error  = _error;

@synthesize string = _string;
@synthesize number = _number;
@synthesize boolNumber = _boolNumber;
@synthesize array = _array;
@synthesize dictionary = _dictionary;

- (instancetype)init {
    return [self initWithJSONobject:[NSNull null]];
}

+ (instancetype)nullJSON {
    return [[self alloc] initWithJSONobject:[NSNull null]];
}

- (instancetype)initWithObject:(id)object {
    if ([object isKindOfClass:[NSData class]]) {
        return [self initWithData:object];
    }
    else {
        return [self initWithJSONobject:object];
    }
}
-(instancetype)initWithParseString:(NSString *)string{
    return [self initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}
- (instancetype)initWithData:(NSData *)data {
    return [self initWithData:data options:NSJSONReadingAllowFragments error:nil];
}

- (instancetype)initWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError *__autoreleasing *)error {
    id object = [NSJSONSerialization JSONObjectWithData:data options:opt error:error];
    if (object != nil) {
        return [self initWithJSONobject:object];
    }
    else {
        return [self initWithJSONobject:[NSNull null]];
    }
}

- (instancetype)initWithJSONobject:(id)objects {
    self = [super init];
    if (self != nil) {
        id object;
        if ([object isKindOfClass:[RTCJSON class]]) {
            object = ((RTCJSON*)object).object;
        }else{
            object = objects;
        }
        if (object != nil) {
            _object = object;
            if ([object isKindOfClass:[NSDictionary class]]) {
                _type = JSONtypeDictionary;
            }
            else if ([object isKindOfClass:[NSArray class]]) {
                _type = JSONtypeArray;
            }
            else if ([object isKindOfClass:[NSNumber class]]) {
                // check if is Bool
                if ([(NSNumber *)object isBool]) {
                    _type = JSONtypeBool;
                }
                else {
                    _type = JSONtypeNumber;
                }
            }
            else if ([object isKindOfClass:[NSString class]]) {
                _type = JSONtypeString;
            }
            else if ([object isKindOfClass:[NSNull class]]) {
                _type = JSONtypeNull;
            }
            else {
                _type = JSONtypeUnknown;
                _object = [NSNull null];
                _error = [NSError errorWithDomain:JSONErrorDomain code:JSONErrorUnsupportedType userInfo:@{NSLocalizedDescriptionKey: @"Unsupported type"}];
            }
        }
        else {
            _type = JSONtypeNull;
            _object = [NSNull null];
        }
    }
    return self;
}
/**
 *  subscripting
 */
/**
 *  if type is array
 *
 *  @return array[idx] as JSON, or nullJSON otherwise
 */
- (RTCJSON *)objectAtIndexedSubscript:(NSUInteger)idx {
    if (_type == JSONtypeArray) {
        NSArray * arr = _object;
        if (idx < [arr count]) {
            return [[RTCJSON alloc] initWithJSONobject:[arr objectAtIndex:idx]];
        }
        else {
            RTCJSON * ret = [RTCJSON nullJSON];
            ret.error = [NSError errorWithDomain:JSONErrorDomain code:JSONErrorIndexOutOfBounds userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Index %lu out of bounds", (unsigned long)idx]}];
            return ret;
        }
    }
    else {
        RTCJSON * ret = [RTCJSON nullJSON];
        ret.error = [NSError errorWithDomain:JSONErrorDomain code:JSONErrorWrongType userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"JSON is not an array to return object at index %lu", (unsigned long)idx]}];
        return ret;
    }
}
/**
 *  if type is dictionary
 *
 *  @return dictionary[key] as JSON, or nullJSON otherwise
 */
- (RTCJSON *)objectForKeyedSubscript:(id)key {
    if (_type == JSONtypeDictionary) {
        NSDictionary * dict = self.object;
        id object = [dict objectForKey:key];
        if (object != nil) {
            return [[RTCJSON alloc] initWithJSONobject:object];
        }
        else {
            RTCJSON * ret = [RTCJSON nullJSON];
            ret.error = [NSError errorWithDomain:JSONErrorDomain code:JSONErrorKeyNotExist userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Dictionary does not contains key %@", key]}];
            return ret;
        }
    }
    else {
        RTCJSON * ret = [RTCJSON nullJSON];
        ret.error = [NSError errorWithDomain:JSONErrorDomain code:JSONErrorWrongType userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"JSON is not an dictionary to return object for key %@", key]}];
        return ret;
    }
}
//通过下标设置属性值

- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index{
    if (_type == JSONtypeNull) {//如果只是初始化了对象，在向数组赋值时候，先创建一个空数组
        _object = [NSArray arrayWithObject:anObject];
        _type = JSONtypeArray;
    }else if (_type == JSONtypeArray) {
        NSMutableArray * ret = [NSMutableArray arrayWithArray:_object];
        if (index < [ret count]) {
            if ([anObject isKindOfClass:[RTCJSON class]]){
                ret[index] = ((RTCJSON*)anObject).object;
            }else{
               ret[index] = anObject;
            }
            _object = [NSArray arrayWithArray:ret];
        }else if(index == [ret count]){
            if ([anObject isKindOfClass:[RTCJSON class]]){
                [ret addObject:((RTCJSON*)anObject).object];
            }else{
                [ret addObject:anObject];
            }
        }else{
            self.error = [NSError errorWithDomain:JSONErrorDomain code:JSONErrorIndexOutOfBounds userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Index %lu out of bounds", (unsigned long)index]}];
        }
    }
    
//    [self setValue:anObject forKey:[NSString stringWithFormat:@"_index%lu",index]];
    
}
//通过键值下标设置属性
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying > )aKey{
    if (_type == JSONtypeNull) {//如果只是初始化了对象，在向数组赋值时候，先创建一个空数组
        _object = [NSDictionary dictionaryWithObjectsAndKeys:object,aKey, nil];
        _type = JSONtypeDictionary;
    }else if (_type == JSONtypeDictionary) {
        NSMutableDictionary *ret = [[NSMutableDictionary alloc]initWithDictionary:_object];
        if ([ret.allKeys containsObject:aKey]) {
            if ([object isKindOfClass:[RTCJSON class]]){
                ret[aKey] = ((RTCJSON*)object).object;
            }else{
                ret[aKey] = object;
            }
            _object = [NSDictionary dictionaryWithDictionary:ret];
        }else{
            NSError *erro = [NSError errorWithDomain:JSONErrorDomain code:JSONErrorWrongType userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"key or value is nil"]}];
            self.error = erro;
        }
    }
}
-(void)changeValueForKey:(NSString *)key changeValue:(id)obj error:(NSError *__autoreleasing *)error{
    if (key && obj) {
        if (_type == JSONtypeDictionary) {
            NSMutableDictionary *ret = [[NSMutableDictionary alloc]initWithDictionary:_object];
            [ret setObject:obj forKey:key];
            _object = [NSDictionary dictionaryWithDictionary:ret];
        }else{
            RTCJSON * ret = [RTCJSON nullJSON];
            NSError *erro = [NSError errorWithDomain:JSONErrorDomain code:JSONErrorWrongType userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"key or value is nil"]}];
            ret.error = erro;
            *error = erro;
        }
    }else{
        RTCJSON * ret = [RTCJSON nullJSON];
        NSError *erro = [NSError errorWithDomain:JSONErrorDomain code:JSONErrorWrongType userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"key or value is nil"]}];
        ret.error = erro;
        *error = erro;
    }
    
    
}

/**
 *  @return dictionary of original key and JSON object value, or nil
 */
- (NSDictionary *)dictionary {
    if (_type == JSONtypeDictionary) {
        NSDictionary * dict = _object;
        NSMutableDictionary * ret = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [ret setObject:[[RTCJSON alloc] initWithJSONobject:obj] forKey:key];
        }];
        return ret;
    }
    return nil;
}
-(void)setDictionary:(NSDictionary *)dictionary{
    if (dictionary && _type == JSONtypeDictionary) {
        NSMutableDictionary * ret = [[NSMutableDictionary alloc] initWithDictionary:_object];
        [[NSDictionary dictionaryWithDictionary:dictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[RTCJSON class]]) {
                [ret setObject:((RTCJSON*)obj).object forKey:key];
            }else{
                [ret setObject:obj forKey:key];
            }
        }];
        _object = [NSDictionary dictionaryWithDictionary:ret];
    }else{
        _object =  [RTCJSON nullJSON];
    }
}
/**
 *  @return array of JSON object or nil
 */
- (NSArray *)array {
    if (_type == JSONtypeArray) {
        NSArray * arr = _object;
        NSMutableArray * ret = [[NSMutableArray alloc] initWithCapacity:[arr count]];
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [ret addObject:[[RTCJSON alloc] initWithJSONobject:obj]];
        }];
        return ret;
    }
    return nil;
}
-(void)setArray:(NSArray *)array{
    if (array && _type == JSONtypeArray) {
        NSMutableArray * ret = [[NSMutableArray alloc] initWithArray:array];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[RTCJSON class]]) {
                [ret addObject:((RTCJSON*)obj).object];
            }else{
                [ret addObject:obj];
            }
        }];
        _object = [NSArray arrayWithArray:ret];
    }else{
        _object =  [RTCJSON nullJSON];
    }
}
- (NSString *)string {
    if (_type == JSONtypeString) {
        return _object;
    }
    return nil;
}
-(void)setString:(NSString *)string{
    if (string) {
        _object = string;
    }else{
        _object =  [RTCJSON nullJSON];
    }
}
- (NSNumber *)number {
    if (_type == JSONtypeNumber) {
        return _object;
    }
    return nil;
}
-(void)setNumber:(NSNumber *)number{
    if (number) {
        _object = number;
    }else{
        _object =  [RTCJSON nullJSON];
    }
}
- (NSNumber *)boolNumber {
    if (_type == JSONtypeBool) {
        return _object;
    }
    return false;
}
-(void)setBoolNumber:(NSNumber *)boolNumber{
    if (boolNumber) {
        _object = boolNumber;
    }else{
        _object =  [RTCJSON nullJSON];
    }
}
/**
 *  @return dictionary of original key and JSON object value, or nil
 */
- (NSDictionary *)dictionaryObj {
    if (_type == JSONtypeDictionary) {
        return [NSMutableDictionary dictionaryWithDictionary:_object];
    }
    return nil;
}
-(void)setDictionaryObj:(NSDictionary *)dictionaryObj{
    if (dictionaryObj) {
        NSMutableDictionary * ret = [[NSMutableDictionary alloc] initWithDictionary:_object];
        [ret addEntriesFromDictionary:dictionaryObj];
        _object = [NSDictionary dictionaryWithDictionary:ret];
    }else{
        _object =  [RTCJSON nullJSON];
    }
}
/**
 *  @return array of JSON object or nil
 */
- (NSArray *)arrayObj {
    if (_type == JSONtypeArray) {
        return [NSMutableArray arrayWithArray:_object];
    }
    return nil;
}
-(void)setArrayObj:(NSArray *)arrayObj{
    if (arrayObj) {
        NSMutableArray * ret = [[NSMutableArray alloc] initWithArray:_object];
        [ret addObjectsFromArray:arrayObj];
        _object = [NSArray arrayWithArray:ret];
    }else{
        _object =  [RTCJSON nullJSON];
    }
}
-(NSString *)rawString{
    NSString * description = @"Unknown";
    switch (_type) {
        case JSONtypeDictionary:
        case JSONtypeArray:
        {
            NSData * data = [NSJSONSerialization dataWithJSONObject:_object options:NSJSONWritingPrettyPrinted error:nil];
            description = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
            break;
        case JSONtypeString:
            description = _object;
            break;
        case JSONtypeNumber:
            description = [(NSNumber *)_object stringValue];
            break;
        case JSONtypeBool:
        {
            description = (BOOL)_object ? @"true" : @"false";
        }
            break;
        case JSONtypeNull:
            description = @"Null";
            break;
        default:
            break;
    }
    return description;
}
/**
 *  Description
 */
- (NSString *)description {
    NSString * description = @"Unknown";
    switch (_type) {
        case JSONtypeDictionary:
        case JSONtypeArray:
        {
            NSData * data = [NSJSONSerialization dataWithJSONObject:_object options:NSJSONWritingPrettyPrinted error:nil];
            description = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
            break;
        case JSONtypeString:
            description = _object;
            break;
        case JSONtypeNumber:
            description = [(NSNumber *)_object stringValue];
            break;
        case JSONtypeBool:
        {
            description = (BOOL)_object ? @"true" : @"false";
        }
            break;
        case JSONtypeNull:
            description = @"Null";
            break;
        default:
            break;
    }
    return description;
}

- (NSString *)debugDescription {
    return [self description];
}
@end

/**
 *  NSNumber Bool
 */
@implementation NSNumber (Bool)

- (BOOL)isBool {
    static NSNumber * trueNumber = nil;
    static NSNumber * falseNumber = nil;
    static NSString * trueObjCType = nil;
    static NSString * falseObjCType = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        trueNumber = [NSNumber numberWithBool:true];
        falseNumber = [NSNumber numberWithBool:false];
        trueObjCType = [NSString stringWithCString:trueNumber.objCType encoding:NSUTF8StringEncoding];
        falseObjCType = [NSString stringWithCString:falseNumber.objCType encoding:NSUTF8StringEncoding];
    });
    
    NSString * objCType = [NSString stringWithCString:self.objCType encoding:NSUTF8StringEncoding];
    if (([self compare:trueNumber] == NSOrderedSame &&  [objCType isEqualToString:trueObjCType]) ||
        ([self compare:falseNumber] == NSOrderedSame &&  [objCType isEqualToString:falseObjCType])) {
        return true;
    }
    else {
        return false;
    }
}
@end
