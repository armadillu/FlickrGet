#import "controller.h"
#import "dowloader.h"
#import "constants.h"

@implementation controller

-(void)awakeFromNib{
    numTasks = 0;    
   //NSLog(@"Main thread  is: %d", [NSThread currentThread]);

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(applicationWillTerminate:)
        name:@"NSApplicationWillTerminateNotification" object:NSApp];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"password"] != nil){//if defaults exist
	[passwordField setStringValue: [[NSUserDefaults standardUserDefaults] stringForKey:@"password"]];
	[loginField setStringValue: [[NSUserDefaults standardUserDefaults] stringForKey:@"login"]];
    }else
	NSLog(@"First time user! :)");

    NSRect rect = [mainWin frame];
    listShown=FALSE;
    rect.origin.y += (rect.size.height - WINDOW_HEIGHT )  - 44 ;
    rect.size.height = WINDOW_HEIGHT;
    
    [mainWin setFrame: rect display:YES animate:NO];

 }

-(void) checkSizes{

   if ((int)[mainWin frame].size.height <= WINDOW_HEIGHT )
	listShown=FALSE;
    else
	listShown=TRUE;
    [listB setIntValue: listShown];

}


- (IBAction)start:(id)sender{
    
    if ([[urlField stringValue] length] != 0 && [[nameField stringValue]length]!= 0){
	d[numTasks] = [dowloader alloc];
	[d[numTasks] initWithURL:[urlField stringValue] 
			name:[nameField stringValue] 
			number:numTasks 
			ptr:self
			login:[loginField stringValue]
			password:[passwordField stringValue]
			];
	
	[NSThread detachNewThreadSelector:@selector(start)
				toTarget: d[numTasks]
				withObject:nil];
	numTasks++;
	[table reloadData];
	[table selectRow:numTasks-1 byExtendingSelection:NO];
	//[nameField setStringValue: @" "];
	//[urlField setStringValue: @" "];
	[stopB setEnabled:YES];
	
	[self growToFit];
	//if (!listShown)
	//    [self showList:nil];

    }else{
	//NSRunInformationalAlertPanel(@"Can't Start the Download", @"First add a Flickr Set URL and a donwload name.", @"OK", nil, nil);
	NSBeginAlertSheet(
		@"Can't Start the Download" ,
		@"OK",
		nil,
		nil,  // other button
		mainWin, 
		self, // modal delegate
		nil,// didEnd selector, 
		nil,//@selector(quitSheetDidDiss:returnCode:context:), 
		nil,  // context info
		@"Please add the URL for the Flickr Set you want to download and a Donwload Name before starting the download"); // message string

	if ([[urlField stringValue] length] == 0)
	    [mainWin makeFirstResponder:urlField ];

	if ([[nameField stringValue] length] == 0)
	    [mainWin makeFirstResponder:nameField ];

    }
}

- (IBAction)stop:(id)sender{

    int selected=[table selectedRow];
    if (selected >=0 && selected< numTasks){
	NSLog(@"killing task %d !", selected);
	[ d[selected] stop];
    }
}

-(void) finished{

   // NSLog(@"task %d finished!", dd);
    int row=[table selectedRow];

    if (d[row]->status == DOWNLOADING)
    	[stopB setEnabled:YES];
    else
	[stopB setEnabled:NO];

    [table reloadData];
}

-(BOOL) tableView:(NSTableView*) tableView shouldSelectRow:(int)row{
    return YES;
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView{
    return numTasks;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{

    int selected=[table selectedRow];
    
    if (selected >=0 && selected < numTasks){
	[nameField setStringValue: d[selected]->name ];
	[urlField setStringValue: d[selected]->url ];
	if (d[selected]->status == DOWNLOADING)
	    [stopB setEnabled:YES];
	else
	    [stopB setEnabled:NO];
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row{

    if ([[tableColumn identifier] isEqualTo: @"name"]){
	return d[row]->name ;
    }else{
	//status
	switch(d[row]->status ){
	
	    case NOT_STARTED:
		return @"Not Started"; break;
	    case DOWNLOADING:
		return @"Downloading..."; break;
	    case FINISHED:
		return @"Finshed"; break;
	    case ERROR:
		return @"Error? Check Console.log!"; break;
	    case CANCELLED:
		return @"User Cancelled"; break;
	    default:
		return @"wtf?!?";
	}
    }
    
}

- (void)applicationWillTerminate:(NSNotification *)notification{

    if ([[loginField stringValue] length] > 0)
	[[NSUserDefaults standardUserDefaults] setObject:[loginField stringValue] forKey:@"login"];
    if ([[loginField stringValue] length] > 0)
	[[NSUserDefaults standardUserDefaults] setObject:[passwordField stringValue] forKey:@"password"];

    int i;
    //stop all tasks; just in case
    for (i=0; i<numTasks; i++)
	[d[i] stop];	
}

- (void)windowDidResize:(NSNotification *)aNotification{

    NSSize frameSize = [[aNotification object] frame].size;
    
    [help setLeadingOffset:15];
    [help setTrailingOffset:frameSize.height - 194 - 15 ];
    [self checkSizes];
}

-(void) growToFit{

    NSRect rect = [mainWin frame];

    	rect.origin.y += (rect.size.height - (WINDOW_HEIGHT+ LIST_SPACING + 17*numTasks) )  ;
	rect.size.height = WINDOW_HEIGHT + LIST_SPACING + 17*numTasks;

    [mainWin setFrame: rect display:YES animate:YES];
    
}

- (IBAction) showList:(id)sender{

    NSRect rect = [mainWin frame];

    if (listShown){ // lets hide it!
	rect.origin.y += (rect.size.height - WINDOW_HEIGHT )  - 44 ;
	rect.size.height = WINDOW_HEIGHT;
    }else{
	rect.size.height += LIST_SPACING + 17*numTasks;
	rect.origin.y -= LIST_SPACING + 17*numTasks;
    }
    
    [mainWin setFrame: rect display:YES animate:YES];
    
}

- (IBAction) openHelpDrawer:(id)sender{

    if ( [help state]==NSDrawerOpenState)
	[help close];
    else
	[help openOnEdge:NSMaxXEdge];
}

- (IBAction) showReadMe:(id)sender{
    [[NSWorkspace sharedWorkspace] openFile:[[NSBundle mainBundle] pathForResource:@"ReadMe" ofType:@"rtf" inDirectory:@""]  withApplication:@"TextEdit"];
}

- (IBAction) showWebsite:(id)sender{
    if ([sender tag]==0)
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://oriol.mine.nu/Software/FlickrGet/"]];
    else
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.paypal.com/xclick/business=tm05788%40salleurl.edu&item_name=FlickrGet&no_note=1&tax=0&currency_code=EUR"]];
}


@end
