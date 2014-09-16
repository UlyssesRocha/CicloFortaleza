//
//  RequestManager.m
//  KMLViewer
//
//  Created by Allan Araújo on 4/23/14.
//
//

#import "RequestManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLSessionManager.h"
#import "Manager.h"

@implementation RequestManager

+ (RequestManager *)instance
{
    static dispatch_once_t pred;
    static RequestManager *sharedInstance = nil;
    
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    
    return sharedInstance;
}

- (void)downloadKMLWithCompletionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[[Manager kmlManager] kmlAddress]];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if(completionHandler)
        {
            completionHandler(response, filePath, error);
        }
    }];
    [downloadTask resume];
}

- (void)getDistanceFromCurrentLocationToAddress:(NSString *)address
{
//    [self getDistanceFrom:[Manager mapManager].mapView.userLocation.coordinate ToAddress:address];
}

- (void)getDistanceFrom:(CLLocationCoordinate2D)coordinateFrom ToAddress:(NSString *)address
{
    NSString *mapEnginerUrl = @"http://maps.googleapis.com/maps/api/distancematrix/json?origins=";
    mapEnginerUrl = [mapEnginerUrl stringByAppendingString:[NSString stringWithFormat:@"%f,%f", coordinateFrom.latitude, coordinateFrom.longitude]];
    mapEnginerUrl = [mapEnginerUrl stringByAppendingString:@"&destinations="];
    mapEnginerUrl = [mapEnginerUrl stringByAppendingString:address];
    mapEnginerUrl = [mapEnginerUrl stringByAppendingString:@"&mode=walking&language=pt-BR&sensor=false"];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:mapEnginerUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        
        NSArray *rows = [dic objectForKey:@"rows"];
        
        NSArray *elements = [[rows objectAtIndex:0] objectForKey:@"elements"];
        
        NSDictionary *distance = [[elements objectAtIndex:0] objectForKey:@"distance"];
        
        NSNumber *value = [distance objectForKey:@"value"];
        
        NSLog(@"DISTANCE: %@ meters", value);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
