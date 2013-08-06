//
//  dowloader.h
//  FlickrGet
//
//  Created by Oriol Ferrer Mesià on 06/04/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface dowloader : NSObject {

    @public
    NSString * name;
    NSString * url;
    NSString * login;
    NSString * password;
    int status;
    NSNumber * num;
    NSTask * task;
    
    NSTimer * timer;
    int timeSpent;
    
//    NSFileHandle * taskOutput;
//    NSPipe * outPipe;
//    NSPipe * errPipe;
    id  ptr;
    int myThread;
    
}

-(void)initWithURL:(NSString *) _url name:(NSString *) _name number:(int) _num ptr:(id) _ptr login:(NSString*)_login password:(NSString*) _password ;
-(void)start;
-(void)stop;
-(void)taskDidFinish:(NSNotification *)aNotification ;

@end
