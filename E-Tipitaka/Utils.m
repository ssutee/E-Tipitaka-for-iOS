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
	NSString *result;
	result = [text stringByReplacingOccurrencesOfString:@"0" withString:@"๐"];
	result = [result stringByReplacingOccurrencesOfString:@"1" withString:@"๑"];
	result = [result stringByReplacingOccurrencesOfString:@"2" withString:@"๒"];
	result = [result stringByReplacingOccurrencesOfString:@"3" withString:@"๓"];
	result = [result stringByReplacingOccurrencesOfString:@"4" withString:@"๔"];
	result = [result stringByReplacingOccurrencesOfString:@"5" withString:@"๕"];
	result = [result stringByReplacingOccurrencesOfString:@"6" withString:@"๖"];
	result = [result stringByReplacingOccurrencesOfString:@"7" withString:@"๗"];
	result = [result stringByReplacingOccurrencesOfString:@"8" withString:@"๘"];
	result = [result stringByReplacingOccurrencesOfString:@"9" withString:@"๙"];
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
        [error release];
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


@end

