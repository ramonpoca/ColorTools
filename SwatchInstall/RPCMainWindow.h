//
//  RPCMainWindow.h
//  Ase2Clr
//
//  Created by Ramon Poca on 03/05/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RPCMainWindow : NSWindow <NSDraggingDestination>

@property (strong) IBOutlet NSTextField *messageField;

@end
