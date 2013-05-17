//
//  Utils.m
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"


@implementation Utils

+ (NSString *)arabic2thai:(NSString *)text {
	NSMutableString *result = [text mutableCopy];

    [result replaceOccurrencesOfString:@"0" withString:@"๐" 
                               options:NSLiteralSearch range:NSMakeRange(0, [text length])];
    [result replaceOccurrencesOfString:@"1" withString:@"๑" 
                               options:NSLiteralSearch range:NSMakeRange(0, [text length])];
    [result replaceOccurrencesOfString:@"2" withString:@"๒" 
                               options:NSLiteralSearch range:NSMakeRange(0, [text length])];
    [result replaceOccurrencesOfString:@"3" withString:@"๓" 
                               options:NSLiteralSearch range:NSMakeRange(0, [text length])];
    [result replaceOccurrencesOfString:@"4" withString:@"๔" 
                               options:NSLiteralSearch range:NSMakeRange(0, [text length])];
    [result replaceOccurrencesOfString:@"5" withString:@"๕" 
                               options:NSLiteralSearch range:NSMakeRange(0, [text length])];
    [result replaceOccurrencesOfString:@"6" withString:@"๖" 
                               options:NSLiteralSearch range:NSMakeRange(0, [text length])];
    [result replaceOccurrencesOfString:@"7" withString:@"๗" 
                               options:NSLiteralSearch range:NSMakeRange(0, [text length])];
    [result replaceOccurrencesOfString:@"8" withString:@"๘" 
                               options:NSLiteralSearch range:NSMakeRange(0, [text length])];
    [result replaceOccurrencesOfString:@"9" withString:@"๙" 
                               options:NSLiteralSearch range:NSMakeRange(0, [text length])];
    
	return result;	  
}

+ (NSDictionary *)readData {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
															  NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
	}
	
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
										  propertyListFromData:plistXML
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  format:&format
										  errorDescription:&errorDesc];
	if (!temp) {
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
		return nil;
	}	
	return temp;
}

+ (void)writeData:(NSDictionary *)plistDict {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
																   format:NSPropertyListXMLFormat_v1_0
														 errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
    else {
        NSLog(@"%@",error);
    }	
}

+ (NSDictionary *)readPages {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
															  NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingPathComponent:@"Pages.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"Pages" ofType:@"plist"];
	}
	
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
										  propertyListFromData:plistXML
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  format:&format
										  errorDescription:&errorDesc];
	if (!temp) {
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
		return nil;
	}	
	return temp;
}

+ (NSDictionary *)readItems {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
															  NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingPathComponent:@"Items.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"Items" ofType:@"plist"];
	}
	
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
										  propertyListFromData:plistXML
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  format:&format
										  errorDescription:&errorDesc];
	if (!temp) {
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
		return nil;
	}	
	return temp;
}

+ (NSDictionary *)readNames {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
															  NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingPathComponent:@"Names.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"Names" ofType:@"plist"];
	}
	
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
										  propertyListFromData:plistXML
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  format:&format
										  errorDescription:&errorDesc];
	if (!temp) {
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
		return nil;
	}	
	return temp;
}

+ (NSDictionary *)readPlist:(NSString *)name {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
															  NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
	}
	
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
										  propertyListFromData:plistXML
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  format:&format
										  errorDescription:&errorDesc];
	if (!temp) {
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
		return nil;
	}	
	return temp;
}

+ (char *) replace:(const char *)original pattern:(const char *)pattern 
       replacement:(const char*)replacement {
    
    size_t const replen = strlen(replacement);
    size_t const patlen = strlen(pattern);
    size_t const orilen = strlen(original);
    
    size_t patcnt = 0;
    const char * oriptr;
    const char * patloc;
    
    // find how many times the pattern occurs in the original string
    for (oriptr = original; patloc = strstr(oriptr, pattern); oriptr = patloc + patlen)
    {
        patcnt++;
    }
    
    // allocate memory for the new string
    size_t const retlen = orilen + patcnt * (replen - patlen);
    char * const returned = (char *) malloc( sizeof(char) * (retlen + 1) );
    
    if (returned != NULL)
    {
        // copy the original string, 
        // replacing all the instances of the pattern
        char * retptr = returned;
        for (oriptr = original; patloc = strstr(oriptr, pattern); oriptr = patloc + patlen)
        {
            size_t const skplen = patloc - oriptr;
            // copy the section until the occurence of the pattern
            strncpy(retptr, oriptr, skplen);
            retptr += skplen;
            // copy the replacement 
            strncpy(retptr, replacement, replen);
            retptr += replen;
        }
        // copy the rest of the string.
        strcpy(retptr, oriptr);
    }
    return returned;

}


+(NSString *) createHeaderTitle:(NSNumber *)volume {
	NSString *newTitle = [NSString alloc];
	if([volume intValue] <= 8) {
		newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระวินัยปิฎก", [volume intValue]];
	} else if([volume intValue] <= 33) {
		newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระสุตตันตปิฎก", [volume intValue] - 8];
	} else {
		newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระอภิธรรมปิฎก", [volume intValue] - 33];		
	}
    return  newTitle;
}


@end


