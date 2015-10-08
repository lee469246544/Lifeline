//
//  FileManager.m
//  Lifeline
//
//  Created by 1 on 15/9/30.
//  Copyright (c) 2015年 Lee. All rights reserved.
//

#import "FileManager.h"

@implementation Event



@end



@implementation EventModel

+ (EventModel *)modelWithEvent:(NSString *)eventString
{
    EventModel *eventModel = [EventModel new];
    
    
    NSArray *separatArr = [eventString componentsSeparatedByString:@"\n"];

    
    
    NSMutableArray *events = [NSMutableArray array];
    for (int i = 0 ; i < separatArr.count ; i++)
    {
        NSString *context = separatArr[i];
        if (i == 0) {
            eventModel.eventHeader = context;
        }else{
            /*
             <<silently>>
             <<set $toldname = 0>>
             <<endsilently>>
             <<choice [[你是谁呀？|whois]]>> | <<choice [[我能看到你。|message received]]>>
             <<if $mapsuggest is 1>>我真的不知道。<<endif>>
             <<elseif $triedgalley is 1>>
             [[delay 4s|nosurvivors]]
             [[launch]]
             [[describehere]]
             */
            Event *event = [Event new];
            [events addObject:event];

            if ([context hasPrefix:@"<<"]) {
                //特殊处理
                NSRange range = NSMakeRange(0, context.length-1);
                [context enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                    if (substringRange.location == 2)
                    {
                        if ([substring isEqualToString:@"silently"]) {
                            event.type = 1;
                        }else  if ([substring isEqualToString:@"choice"]) {
                            event.type = 3;
                            *stop = YES;
                        }else  if ([substring isEqualToString:@"if"]) {
                            event.type = 4;
                        }
                    }else{
                        if (event.type == 1) {
                            NSLog(@"%@",substring);
                            if ([substring isEqualToString:@"endsilently"])
                            {
                                *stop = YES;
                            }else if(![substring isEqualToString:@"set"]){
                                if (substring.length > 1) {
                                    if (!event.key) {
                                        event.key = substring;
                                    }else{
                                        event.key1 = substring;
                                    }
                                }else{
                                    if (!event.value) {
                                        event.value = substring;
                                    }else{
                                        event.value1 = substring;
                                    }
                                }
                            }
                        }else if (event.type == 4){
                            if (substringRange.location == 6) {
                                event.key = substring;
                            }else if (![substring isEqualToString:@"is"]){
                                event.value = substring;
                            }
                        }
                    
                    }
                }];
                
                
                if (event.type == 3)
                {
                    NSRange range = [context rangeOfString:@"<<choice [["];
                    NSRange range2 = [context rangeOfString:@"|"];
                    NSRange range3 = [context rangeOfString:@"]]"];
                    NSRange rangeValue = NSMakeRange(range.length+range.location, range2.location-range.location-range.length);
                    NSString *value = [context substringWithRange:rangeValue];
                    NSRange rangeKey = NSMakeRange(range2.location+1, range3.location-range2.location-1);

                    NSString *key = [context substringWithRange:rangeKey];
                    event.key = key;
                    event.value = value;
                    
                    range = [context rangeOfString:@"<<choice [[" options:NSBackwardsSearch];
                    range2 = [context rangeOfString:@"|" options:NSBackwardsSearch];
                    range3 = [context rangeOfString:@"]]" options:NSBackwardsSearch];
                    
                    rangeValue = NSMakeRange(range.length+range.location, range2.location-range.location-range.length);
                    value = [context substringWithRange:rangeValue];
                    rangeKey = NSMakeRange(range2.location+1, range3.location-range2.location-1);
                    
                    key = [context substringWithRange:rangeKey];

                    event.key1 = key;
                    event.value1 = value;
                
                }
                
                
            }else if([context hasPrefix:@"[["]){
                //
                NSRange range = [context rangeOfString:@"[[delay"];
                if (range.location != NSNotFound) {
                    
                    
                    NSRange range1 = [context rangeOfString:@"|"];
                    event.key = [context substringWithRange:NSMakeRange(range.length+range.location+1, range1.location+range1.length-range.length-range.location-2)];

                    NSRange range2 = [context rangeOfString:@"]]"];
                    
                    event.value =[context substringWithRange:NSMakeRange(range1.length+range1.location, range2.location+range2.length-2-range1.length-range1.location)];
                    event.type = 6;
                    event.content = context;
                }else{
                    event.type = 5;
                    
                    event.content = [context substringWithRange:NSMakeRange(2, context.length-4)];
                    
                }
                
                
            }else{
                event.type = 0;
                event.content = context;

            }
            
            
//            NSLog(@"%@",context);
            
            
            
        }

    }
    eventModel.eventDes = events;
    return eventModel;

}


@end


@implementation FileManager
static FileManager *fileManager = nil;
+ (FileManager *)manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileManager = [[FileManager alloc] init];
    });

    return fileManager;
    
}

- (id)init{
    self = [super init];
    if (self) {
        self.parserState = 0;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self startParser];
        });
    
    }
    return self;
}

- (void)startParser
{
    self.parserState = 1;
    NSString *path = [self filePath];
    NSString *context = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    NSArray * components = [context componentsSeparatedByString:@":: "];
    
    NSMutableArray *events = [NSMutableArray array];
    
    for (NSString *eventString in components) {


        EventModel *eventModel = [EventModel modelWithEvent:eventString];
        [events addObject:eventModel];
    }
    self.events = events;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.parserState = 2;
    });
    
}



- (NSString *)filePath{
    return [[NSBundle mainBundle] pathForResource:@"StoryData" ofType:@"txt"];


}

@end
