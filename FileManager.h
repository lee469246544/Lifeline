//
//  FileManager.h
//  Lifeline
//
//  Created by 1 on 15/9/30.
//  Copyright (c) 2015年 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
/*
 0:普通消息 例如：'这玩意能用吗？'
 1:设置值   例如：'<<silently>><<set $clockwisecrater = 1>><<endsilently>>'
 2:无用消息 例如：'//If you're reading this, you're in for spoilers but you probably don't care! Thanks for playing, and have fun.'
 3:选择跳转 例如：'<<choice [[你是谁呀？|whois]]>>'
 4:加入判断 例如：'<<if $mapsuggest is 1>>我真的不知道。<<endif>>'
 5:等待跳转 例如：'[[delay 4s|nosurvivors]]'
 6:事件跳转 例如：'[[launch]]'
 */
@property (nonatomic,assign) int type;
//普通消息、无用消息、跳转内容
@property (nonatomic,strong) NSString *content;
//设置值的key、value、加入判断、
@property (nonatomic,strong) NSString *key;
@property (nonatomic,strong) NSString *value;
@property (nonatomic,strong) NSString *key1;
@property (nonatomic,strong) NSString *value1;

@end

@interface EventModel : NSObject

@property (nonatomic,strong) NSString *eventHeader;
@property (nonatomic,copy) NSArray *eventDes;

+ (EventModel *)modelWithEvent:(NSString *)eventString;
@end



@interface FileManager : NSObject
@property (nonatomic,copy) NSArray *events;
//0：未开始解析，1:解析中，2:解析结束
@property (nonatomic,assign) int parserState;

+ (FileManager *)manager;



@end
