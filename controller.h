/* controller */

#import <Cocoa/Cocoa.h>
#import "dowloader.h"

@interface controller : NSObject
{
    IBOutlet NSTextField * nameField;
    IBOutlet NSTableView * table;
    IBOutlet NSTextField * urlField;
    IBOutlet NSButton * stopB;
    IBOutlet NSButton * listB;

    IBOutlet NSDrawer * help;
    IBOutlet NSWindow * mainWin;
    
    IBOutlet NSTextField * loginField;
    IBOutlet NSSecureTextField * passwordField;
    bool listShown;
    int numTasks;
    dowloader * d[100];
}

-(void)awakeFromNib;
- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
-(void) finished:(int) dd;
-(void) checkSizes;
-(BOOL) tableView:(NSTableView*) tableView shouldSelectRow:(int)row;
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (IBAction) showList:(id)sender;
-(void) growToFit;
@end
