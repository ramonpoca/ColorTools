//
//  RPCMainWindow.m
//  Ase2Clr
//
//  Created by Ramon Poca on 03/05/14.
//  Copyright (c) 2014 Ramon Poca. All rights reserved.
//

#import "RPCMainWindow.h"
#import "RPCAdobeSwatchExchange.h"

@implementation RPCMainWindow


-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType,NSFileContentsPboardType,NSURLPboardType]];
    }
    return self;
    
    
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (BOOL) tryToImportAseFile: (NSString *) file{
    NSString *baseName = [file lastPathComponent];
    baseName = [baseName stringByDeletingPathExtension];
    RPCAdobeSwatchExchange *ase = [RPCAdobeSwatchExchange new];
    if (![ase readFromFile:file toColorListNamed:baseName]) {
        NSLog(@"Could not read ASE file %@",file);
        return NO;
    }
    return [ase.colors writeToFile:nil];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    [self.messageField setStringValue:@""];

    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        for (NSString *file in files) {
            if ([self tryToImportAseFile:file]) {
                NSString *baseName = [file lastPathComponent];
                [self.messageField setStringValue:[NSString stringWithFormat:@"Imported %@", baseName]];
            } else {
                NSString *baseName = [file lastPathComponent];
                [self.messageField setStringValue:[NSString stringWithFormat:@"Could not import %@", baseName]];
            }
        }
        
    }
    return YES;
}
@end


