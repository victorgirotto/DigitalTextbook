//
//  ThumbNailIconParser.m
//  eBookReader
//
//  Created by Shang Wang on 8/7/13.
//  Copyright (c) 2013 Andreea Danielescu. All rights reserved.
//

#import "ThumbNailIconParser.h"
#import "GDataXMLNode.h"
#import "ThumbNailIconWrapper.h"
#import "ThumbNailIcon.h"

@implementation ThumbNailIconParser


+ (NSString *)dataFilePath:(BOOL)forSave {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory
                               stringByAppendingPathComponent:@"ThumbNailIconList.xml"];
    if (forSave ||
        [[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        return documentsPath;
    } else {
        return [[NSBundle mainBundle] pathForResource:@"ThumbNailIconList" ofType:@"xml"];
    }
}


+ (ThumbNailIconWrapper *)loadThumbnailIcon {
    
    NSString *filePath = [self dataFilePath:FALSE];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    if (doc == nil) {
        NSLog(@"Doc Nil!\n");
        return nil;
    }
    
    // NSLog(@"%@", doc.rootElement);
    
    ThumbNailIconWrapper *thumbnailWrapper = [[ThumbNailIconWrapper alloc] init];
    NSArray *partyMembers = [doc.rootElement elementsForName:@"ThumbNailIcon"];
    for (GDataXMLElement *partyMember in partyMembers) {
        int type;
        NSString *text;
        NSString *url;
        int page;
        CGPoint showPoint;
        CGFloat px;
        CGFloat py;
        
        
        NSArray *types = [partyMember elementsForName:@"Type"];
        if (types.count > 0) {
            GDataXMLElement *firstType = (GDataXMLElement *) [types objectAtIndex:0];
            type = firstType.stringValue.intValue;
        } else continue;
        

        NSArray *names = [partyMember elementsForName:@"Text"];
        if (names.count > 0) {
            GDataXMLElement *firstName = (GDataXMLElement *) [names objectAtIndex:0];
            text = firstName.stringValue;
        } else continue;
        
        
        NSArray *urls = [partyMember elementsForName:@"URL"];
        if (urls.count > 0) {
            GDataXMLElement *firstName = (GDataXMLElement *) [urls objectAtIndex:0];
            url = firstName.stringValue;
        } else continue;
        
        NSArray *levels = [partyMember elementsForName:@"Page"];
        if (levels.count > 0) {
            GDataXMLElement *firstLevel = (GDataXMLElement *) [levels objectAtIndex:0];
            page = firstLevel.stringValue.intValue;
        } else continue;

        NSArray *showPoint_x = [partyMember elementsForName:@"PointX"];
        if (showPoint_x.count > 0) {
            GDataXMLElement *point_x = (GDataXMLElement *) [showPoint_x objectAtIndex:0];
            px=point_x.stringValue.floatValue;
            
        } else continue;
        
        NSArray *showPoint_y = [partyMember elementsForName:@"PointY"];
        if (showPoint_y.count > 0) {
            GDataXMLElement *point_y = (GDataXMLElement *) [showPoint_y objectAtIndex:0];
            py=point_y.stringValue.floatValue;
            
        } else continue;
        
        showPoint=CGPointMake(px, py);
        
        ThumbNailIcon *player = [[ThumbNailIcon alloc] initWithName: type Text:text URL:url showPoint:showPoint pageNum:page];
        [thumbnailWrapper.thumbnails addObject:player];
    }
    return thumbnailWrapper;
    
}



+ (void)saveHighlight:(ThumbNailIconWrapper *)wrapper {
    
    GDataXMLElement * partyElement = [GDataXMLNode elementWithName:@"ThumbNailIconList"];
    
    for(ThumbNailIcon *thumbNailItem in wrapper.thumbnails) {
        
        
        GDataXMLElement * typeElement =
        [GDataXMLNode elementWithName:@"Type" stringValue:
         [NSString stringWithFormat:@"%d", thumbNailItem.type]];
        
        
        GDataXMLElement * itemElement =
        [GDataXMLNode elementWithName:@"ThumbNailIcon"];
        
        GDataXMLElement * textElement =
        [GDataXMLNode elementWithName:@"Text" stringValue:thumbNailItem.text];
        
        GDataXMLElement * urlElement =
        [GDataXMLNode elementWithName:@"URL" stringValue:thumbNailItem.url];
        
        GDataXMLElement * pageElement =
        [GDataXMLNode elementWithName:@"Page" stringValue:
         [NSString stringWithFormat:@"%d", thumbNailItem.page]];
        
        GDataXMLElement * pointXElement =
        [GDataXMLNode elementWithName:@"PointX" stringValue:
         [NSString stringWithFormat:@"%f", thumbNailItem.showPoint.x]];
        
        GDataXMLElement * pointYElement =
        [GDataXMLNode elementWithName:@"PointY" stringValue:
         [NSString stringWithFormat:@"%f", thumbNailItem.showPoint.y]];

        [itemElement addChild:typeElement];
        [itemElement addChild:textElement];
        [itemElement addChild:urlElement];
        [itemElement addChild:pageElement];
        [itemElement addChild:pointXElement];
        [itemElement addChild:pointYElement];
        [partyElement addChild:itemElement];
        
    }
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc]
                                  initWithRootElement:partyElement];
    NSData *xmlData = document.XMLData;
    
    NSString *filePath = [self dataFilePath:TRUE];
    NSLog(@"Saving xml data to %@...", filePath);
    [xmlData writeToFile:filePath atomically:YES];
    
}



@end