//
//  dowloader.m
//  FlickrGet
//
//  Created by Oriol Ferrer Mesià on 06/04/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "dowloader.h"
#import "constants.h"

@implementation dowloader


-(void)initWithURL:(NSString *) _url name:(NSString *) _name number:(int) _num ptr:(id) _ptr login:(NSString*)_login password:(NSString*) _password {

//    outPipe = [NSPipe pipe];
//    errPipe = [NSPipe pipe];
//    
//    taskOutput = [outPipe fileHandleForReading];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self 
//	selector:@selector(taskDataAvailable:) 
//	name:NSFileHandleReadCompletionNotification 
//	object:taskOutput
//	];

    login=_login;
    password=_password;
    name=_name;
    url=_url;
    num=[NSNumber numberWithInt:_num];
    ptr=_ptr;
    status=NOT_STARTED;
    timeSpent=0;
}

-(void)start{

    NSAutoreleasePool* p = [[NSAutoreleasePool alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
    selector:@selector(taskDidFinish:) 
    name:NSTaskDidTerminateNotification 
    object:nil];
	
    myThread = (int)[NSThread currentThread];

    NSString * shPath = [[NSString alloc] initWithFormat: @"%@/Contents/Resources/flickget.sh",[[NSBundle mainBundle] bundlePath]] ;
    task = [[NSTask alloc] init];
    status=DOWNLOADING;

    //[task setStandardOutput: [NSPipe pipe]];
    //[task setStandardError: [task standardOutput]];

    [task setLaunchPath: shPath];
    if (login== nil || password==nil)
	[task setArguments: [NSArray arrayWithObjects: url, name, [[NSBundle mainBundle] bundlePath], nil ]];
    else
	[task setArguments: [NSArray arrayWithObjects: url, name, [[NSBundle mainBundle] bundlePath], login, password, nil ]];

//    [task setStandardOutput:outPipe];
//    [task setStandardError:errPipe];

    [task launch];    
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(countTime) userInfo:nil repeats:YES];
    [p release];
    [[NSRunLoop currentRunLoop] run];
}

-(void) stop{
    status=CANCELLED;
    [task terminate];
    if (timer!=nil){
	[timer invalidate];
	timer=nil;
    }
    //[NSThread exit];
}

-(void) countTime{
    timeSpent++;
}

- (void)taskDidFinish:(NSNotification *)aNotification {

    if (myThread == (int)[NSThread currentThread] ){
	if (timeSpent <= 1) //if only took less than 10seconds to finish
	    status=ERROR; //probably error
	else
	    status=FINISHED; //finshed ok
	
	//NSLog(@"Task @ thread %d finished!", [NSThread currentThread]);
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[ptr finished];
	if (timer!=nil){
	    [timer invalidate];
	    timer=nil;
	}
	[task terminate];
    }
}





//- (void)taskDataAvailable:(NSNotification *)notif
//{
//    NSData *incomingData = [[notif userInfo] objectForKey:NSFileHandleNotificationDataItem];
//    if (incomingData && [incomingData length])
//    {
//        NSString *incomingText = [[NSString alloc] initWithData:incomingData encoding:NSASCIIStringEncoding];
//        // Do whatever with incomingText, the string that has some text in it
//        [taskOutput readInBackgroundAndNotify];
//        [incomingText release];
//        return;
//    }
//}

@end
