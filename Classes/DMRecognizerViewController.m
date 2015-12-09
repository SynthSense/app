//
//  DMRecognizerViewController.m
//  DMRecognizer
//
// Copyright 2010, Nuance Communications Inc. All rights reserved.
//
// Nuance Communications, Inc. provides this document without representation 
// or warranty of any kind. The information in this document is subject to 
// change without notice and does not represent a commitment by Nuance 
// Communications, Inc. The software and/or databases described in this 
// document are furnished under a license agreement and may be used or 
// copied only in accordance with the terms of such license agreement.  
// Without limiting the rights under copyright reserved herein, and except 
// as permitted by such license agreement, no part of this document may be 
// reproduced or transmitted in any form or by any means, including, without 
// limitation, electronic, mechanical, photocopying, recording, or otherwise, 
// or transferred to information storage and retrieval systems, without the 
// prior written permission of Nuance Communications, Inc.
// 
// Nuance, the Nuance logo, Nuance Recognizer, and Nuance Vocalizer are 
// trademarks or registered trademarks of Nuance Communications, Inc. or its 
// affiliates in the United States and/or other countries. All other 
// trademarks referenced herein are the property of their respective owners.
//

#import "DMRecognizerViewController.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKMapItem.h>
#import <CoreLocation/CoreLocation.h>
#import <math.h>

/**
 * The login parameters should be specified in the following manner:
 * 
 * const unsigned char SpeechKitApplicationKey[] =
 * {
 *     0x38, 0x32, 0x0e, 0x46, 0x4e, 0x46, 0x12, 0x5c, 0x50, 0x1d,
 *     0x4a, 0x39, 0x4f, 0x12, 0x48, 0x53, 0x3e, 0x5b, 0x31, 0x22,
 *     0x5d, 0x4b, 0x22, 0x09, 0x13, 0x46, 0x61, 0x19, 0x1f, 0x2d,
 *     0x13, 0x47, 0x3d, 0x58, 0x30, 0x29, 0x56, 0x04, 0x20, 0x33,
 *     0x27, 0x0f, 0x57, 0x45, 0x61, 0x5f, 0x25, 0x0d, 0x48, 0x21,
 *     0x2a, 0x62, 0x46, 0x64, 0x54, 0x4a, 0x10, 0x36, 0x4f, 0x64
 * };
 * 
 * Please note that all the specified values are non-functional
 * and are provided solely as an illustrative example.
 * 
 */
const unsigned char SpeechKitApplicationKey[] = {0xad, 0xe3, 0x39, 0xe9, 0xa8, 0x1d, 0x9f, 0xc8, 0xc8, 0xeb, 0xb0, 0xec, 0xb9, 0x1f, 0x26, 0x38, 0x4b, 0x5b, 0xc8, 0xfc, 0x09, 0x82, 0xc9, 0xe4, 0x42, 0xd4, 0x87, 0x44, 0xa8, 0x39, 0x18, 0x56, 0x1c, 0x51, 0x3f, 0xc4, 0x6e, 0xde, 0x8c, 0x36, 0xc9, 0x3c, 0x22, 0x82, 0x5b, 0x48, 0xba, 0xa7, 0xa4, 0x83, 0xa3, 0xad, 0x05, 0x6c, 0x91, 0x47, 0x41, 0x19, 0x8b, 0xe9, 0x52, 0xa3, 0x3f, 0x6f};

@implementation DMRecognizerViewController
@synthesize recordButton,searchBox,serverBox,portBox,alternativesDisplay,vuMeter,voiceSearch,curLocBox;
@synthesize synthesizer, geocoder, currentAddress, currentLocation, directions, curLocLat, curLocLon, rfduino, placemark, timerDirectionsCount, mapView, prevPolyline, angles, curPointIndex, currentRoute;
@synthesize locationManager = _locationManager;

static BOOL confirmed;
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    confirmed = false;
    /**    
     * The login parameters should be specified in the following manner:
     *
     *  [SpeechKit setupWithID:@"ExampleSpeechKitSampleID"
     *                    host:@"ndev.server.name"
     *                    port:1000
     *                  useSSL:NO
     *                delegate:self];
     *
     * Please note that all the specified values are non-functional
     * and are provided solely as an illustrative example.
     */ 

    [SpeechKit setupWithID:@"NMDPTRIAL_chiller_berkeley_edu20151025205244"
                      host:@"sandbox.nmdp.nuancemobility.net"
                      port:443
                    useSSL:NO
                  delegate:nil];
    
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    
        geocoder = [[CLGeocoder alloc] init];

    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        ) {
        // Will open an confirm dialog to get user's approval
        [_locationManager requestWhenInUseAuthorization];
    } else {
        [_locationManager startUpdatingLocation]; //Will update location immediately
    }
    [rfduino setDelegate:self];

    UIButton *but1= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [but1 addTarget:self action:@selector(leftButton:) forControlEvents:UIControlEventTouchUpInside];
    [but1 setFrame:CGRectMake(20, 510, 60, 40)];
    [but1 setTitle:@"Left turn" forState:UIControlStateNormal];
    [but1 setExclusiveTouch:YES];
    
    // if you like to add backgroundImage else no need
    
    [self.view addSubview:but1];
    
    UIButton *but2= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [but2 addTarget:self action:@selector(rightButton:) forControlEvents:UIControlEventTouchUpInside];
    [but2 setFrame:CGRectMake(200, 510, 90, 40)];
    [but2 setTitle:@"Right turn" forState:UIControlStateNormal];
    [but2 setExclusiveTouch:YES];
    
    // if you like to add backgroundImage else no need
    
    [self.view addSubview:but2];
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height-210, [[UIScreen mainScreen] bounds].size.width-20, 200)];
    [mapView setScrollEnabled:YES];
    [mapView setMapType:MKMapTypeStandard];
    [mapView setShowsBuildings:YES];
    [mapView setShowsUserLocation:YES];
    [mapView setDelegate:self];
    [mapView.layer setCornerRadius:10];
    [mapView.layer setMasksToBounds:YES];
    [self.view addSubview:mapView];
}

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"User still thinking..");
        } break;
        case kCLAuthorizationStatusDenied: {
            NSLog(@"User hates you");
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [_locationManager startUpdatingLocation]; //Will update location immediately
        } break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    currentLocation = newLocation;
    curLocLat = newLocation.coordinate.latitude;
    curLocLon = newLocation.coordinate.longitude;
    NSLog(@"new location lat:%f lon:%f", curLocLat, curLocLon);
    if(!placemark){
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if(error){
                NSLog(@"%@", [error localizedDescription]);
            }
            
            CLPlacemark *placemark = [placemarks lastObject];
            
            currentAddress = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                  placemark.subThoroughfare, placemark.thoroughfare,
                                  placemark.postalCode, placemark.locality,
                                  placemark.administrativeArea,
                                  placemark.country];
            //NSLog(@"%@", currentAddress);
            [curLocBox setText:currentAddress];

        }];
    }
    [self trackPosition];
}
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Actions

- (IBAction)recordButtonAction: (id)sender {
    [searchBox resignFirstResponder];
    [serverBox resignFirstResponder];
    [portBox resignFirstResponder];
    
    if (transactionState == TS_RECORDING) {
        [voiceSearch stopRecording];
    }
    else if (transactionState == TS_IDLE) {
        SKEndOfSpeechDetection detectionType;
        NSString* recoType;
        NSString* langType;
        
        transactionState = TS_INITIAL;

		alternativesDisplay.text = @"";
        
        /* 'Search' is selected */
        detectionType = SKShortEndOfSpeechDetection; /* Searches tend to be short utterances free of pauses. */
        recoType = SKSearchRecognizerType; /* Optimize recognition performance for search text. */
        langType = @"en_US";

        /* Nuance can also create a custom recognition type optimized for your application if neither search nor dictation are appropriate. */
        
        NSLog(@"Recognizing type:'%@' Language Code: '%@' using end-of-speech detection:%d.", recoType, langType, detectionType);

       // if (voiceSearch) [voiceSearch release];
		
        voiceSearch = [[SKRecognizer alloc] initWithType:recoType
                                               detection:detectionType
                                                language:langType 
                                                delegate:self];
    }
}

- (void)recordButtonActionFn {
    [searchBox resignFirstResponder];
    [serverBox resignFirstResponder];
    [portBox resignFirstResponder];
    
    if (transactionState == TS_RECORDING) {
        [voiceSearch stopRecording];
    }
    else if (transactionState == TS_IDLE) {
        SKEndOfSpeechDetection detectionType;
        NSString* recoType;
        NSString* langType;
        
        transactionState = TS_INITIAL;
        
        alternativesDisplay.text = @"";
        
        /* 'Search' is selected */
        detectionType = SKShortEndOfSpeechDetection; /* Searches tend to be short utterances free of pauses. */
        recoType = SKSearchRecognizerType; /* Optimize recognition performance for search text. */
        langType = @"en_US";
        
        /* Nuance can also create a custom recognition type optimized for your application if neither search nor dictation are appropriate. */
        
        NSLog(@"Recognizing type:'%@' Language Code: '%@' using end-of-speech detection:%d.", recoType, langType, detectionType);
        
        // if (voiceSearch) [voiceSearch release];
        
        voiceSearch = [[SKRecognizer alloc] initWithType:recoType
                                               detection:detectionType
                                                language:langType
                                                delegate:self];
    }
}

- (IBAction)serverUpdateButtonAction: (id)sender {
    [searchBox resignFirstResponder];
    [serverBox resignFirstResponder];
    [portBox resignFirstResponder];
    
    if (voiceSearch) [voiceSearch cancel];
    
    [SpeechKit destroy];
}

#pragma mark -
#pragma mark VU Meter

- (void)setVUMeterWidth:(float)width {
    if (width < 0)
        width = 0;
    
    CGRect frame = vuMeter.frame;
    frame.size.width = width+10;
    vuMeter.frame = frame;
}

- (void)updateVUMeter {
    float width = (90+voiceSearch.audioLevel)*5/2;
    
    [self setVUMeterWidth:width];    
    [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
}

#pragma mark -
#pragma mark SpeechKitDelegate methods

- (void) audioSessionReleased {
    NSLog(@"audio session released");
}

- (void) destroyed {
}

#pragma mark -
#pragma mark SKRecognizerDelegate methods

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording started.");
    
    transactionState = TS_RECORDING;
    [recordButton setTitle:@"Recording..." forState:UIControlStateNormal];
    [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording finished.");

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVUMeter) object:nil];
    [self setVUMeterWidth:0.];
    transactionState = TS_PROCESSING;
    [recordButton setTitle:@"Processing..." forState:UIControlStateNormal];
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    NSLog(@"Got results.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id 

    long numOfResults = [results.results count];
    
    transactionState = TS_IDLE;
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    if (numOfResults > -10) {
        if (0){//!confirmed) {
            searchBox.text = [results firstResult];
            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:[NSString stringWithFormat:@"Did you mean %@?",[results firstResult]]];
            
            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-us"];
            [self.synthesizer speakUtterance:utterance];
            
            confirmed = true;

            [self performSelector:@selector(recordButtonActionFn) withObject:nil afterDelay:2.0 ];
            /*voiceSearch = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType
             detection:SKShortEndOfSpeechDetection
             language:@"en_US"
             delegate:self];*/
        } else {
            if (1==1) {
                searchBox.text = @"2521 Hearst Ave Berkeley, CA  94709-1114 United States";

            // if yes, get directions to whatever place
            //if ([[results firstResult] isEqualToString:@"Yes"]) {
                NSLog(@"YAY");
                AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:[NSString stringWithFormat:@"OK, getting directions to %@",searchBox.text]];
                
                utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-us"];
                [self.synthesizer speakUtterance:utterance];

                confirmed = false;
               // [geocoder geocodeAddressString:searchBox.text completionHandler:^(NSArray *placemarks, NSError *error) {

                [geocoder geocodeAddressString:searchBox.text completionHandler:^(NSArray *placemarks, NSError *error) {
                    if(error){
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    
                    placemark = [placemarks lastObject];
                    [self setupRoutes];
                }];
                 

            }
            //if no, start this over again
            if ([[results firstResult] isEqualToString:@"No"]) {
                confirmed = false;
                AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Sorry about that, please say it again"];
                
                utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-us"];
                [self.synthesizer speakUtterance:utterance];
                [self performSelector:@selector(recordButtonActionFn) withObject:nil afterDelay:2.0 ];

            }

        }
 

        
        

    }
	//if (numOfResults > 1)
	//	alternativesDisplay.text = [[results.results subarrayWithRange:NSMakeRange(1, numOfResults-1)] componentsJoinedByString:@"\n"];
    
    if (results.suggestion){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Suggestion"
                                                                       message:results.suggestion
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }

	//[voiceSearch release];
	voiceSearch = nil;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"Got error.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id 
    
    transactionState = TS_IDLE;
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:[error localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    if (suggestion) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Suggestion"
                                                                       message:suggestion
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
	//[voiceSearch release];
	voiceSearch = nil;
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == searchBox)
    {
        [searchBox resignFirstResponder];
    }
    else if (textField == serverBox)
    {
        [serverBox resignFirstResponder];
    }
    else if (textField == portBox)
    {
        [portBox resignFirstResponder];
    }
    return YES;
}


#pragma mark -
#pragma mark RFDuino methods
-(void) leftButton:(UIButton*)sender
{
    [self sendByte:0];
}
-(void) rightButton:(UIButton*)sender
{
    [self sendByte:1];
}
- (void)sendByte:(uint8_t)byte
{
    uint8_t tx[1] = { byte };
    NSData *data = [NSData dataWithBytes:(void*)&tx length:1];
    [rfduino send:data];
}



- (void)didReceive:(NSData *)data
{
    NSLog(@"RecievedData");
    
    const uint8_t *value = [data bytes];
    // int len = [data length];
    
    NSLog(@"value = %x", value[0]);

}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 5.0;
    return polylineView;
}
// https://software.intel.com/en-us/blogs/2012/11/30/calculating-a-bearing-between-points-in-location-aware-apps
-(double)getBearingForLocation1:(CLLocationCoordinate2D)loc1 location2:(CLLocationCoordinate2D)loc2{
    double degToRad = M_PI;
    
    double lat1 = loc1.latitude;
    double lat2 = loc2.latitude;
    double long1 = loc1.longitude;
    double long2 = loc2.longitude;
    
    double phi1 = lat1 * degToRad;
    double phi2 = lat2 * degToRad;
    double lam1 = long1 * degToRad;
    double lam2 = long2 * degToRad;
    
    
    double beta = atan2(sin(lam2-lam1)*cos(phi2),
                        cos(phi1)*sin(phi2) - sin(phi1)*cos(phi2)*cos(lam2-lam1)) * 180/M_PI;
    
    return beta;
    
}
// http://stackoverflow.com/a/16180724
// http://stackoverflow.com/a/30887154
-(double) getDifferenceBetweenAngle1:(double)a1 angle2:(double)a2 {
    
    double r =  MIN((a1-a2)<0?a1-a2+360:a1-a2, (a2-a1)<0?a2-a1+360:a2-a1);
    int sign = (a1 - a2 >= 0 && a1 - a2 <= 180) || (a1 - a2 <=-180 && a1- a2>= -360) ? 1 : -1;
    return r*sign;
}
-(void) trackPosition{
    NSUInteger pointCount = currentRoute.polyline.pointCount;
    //http://stackoverflow.com/a/21865454
    //allocate a C array to hold this many points/coordinates...
    CLLocationCoordinate2D *rc = malloc(pointCount * sizeof(CLLocationCoordinate2D));
    //get the coordinates (all of them)...
    [currentRoute.polyline getCoordinates:rc range:NSMakeRange(0, pointCount)];
    BOOL lastStep = NO;
    CLLocation *testLocation = [[CLLocation alloc] initWithLatitude:rc[curPointIndex].latitude longitude:rc[curPointIndex].longitude];
    double dist =[testLocation distanceFromLocation:currentLocation];
    double ang = 0;
    if (curPointIndex < angles.count) {
        ang =[(NSNumber *)[angles objectAtIndex:curPointIndex] doubleValue];
    } else {
        lastStep = YES;
        NSString *instr = [[[currentRoute.steps lastObject] instructions] lowercaseString];
        if ([instr containsString:@"left"]) {
            ang = 90;
        } else {
            ang = -90;
        }
    }

    searchBox.text = [NSString stringWithFormat:@"Distance from next point: %.2f ang: %.2f", dist, ang];
    if (dist < 10) { // change if less than 10 meters away
        // alert the user
        NSString *alertStr;
        if ( fabs(ang) > 65) {
            if (ang < 0) {
                alertStr = @"TURN RIGHT";
                if (lastStep) {
                    alertStr = @"ARRIVE RIGHT";

                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertStr
                                                                message:[NSString stringWithFormat:@"Angle: %f", ang]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                searchBox.text = alertStr;
                [alert show];
            } else {
                alertStr = @"TURN LEFT";
                if (lastStep) {
                    alertStr = @"ARRIVE LEFT";
                    
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertStr
                                                                message:[NSString stringWithFormat:@"Angle: %f", ang]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                searchBox.text = alertStr;
                [alert show];
            }
        }
        curPointIndex++;
    }
}
-(void) setupRoutes {
    if (placemark) {
        MKPlacemark *placemarkSrc = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(curLocLat, curLocLon) addressDictionary:nil];
        MKMapItem *mapItemSrc = [[MKMapItem alloc] initWithPlacemark:placemarkSrc];
        
        MKPlacemark *placemarkDest = [[MKPlacemark alloc] initWithCoordinate:placemark.location.coordinate addressDictionary:nil];
            
        MKMapItem *mapItemDest = [[MKMapItem alloc] initWithPlacemark:placemarkDest];
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
            NSLog(@"MapItemFor current loc lat:%f lon:%f",mapItemSrc.placemark.coordinate.latitude, mapItemSrc.placemark.coordinate.longitude );
        [request setSource:mapItemSrc];
        [request setDestination:mapItemDest];
        [request setTransportType:MKDirectionsTransportTypeWalking];
        request.requestsAlternateRoutes = NO;
        
        MKDirections *dirs = [[MKDirections alloc] initWithRequest:request];
        [dirs calculateDirectionsWithCompletionHandler:
         ^(MKDirectionsResponse *response, NSError *error) {
             if (error) {
                 [directions setText:[NSString stringWithFormat:@"ERROR: %@!", error.description]];
                 
             } else {
                 MKRoute *route = (MKRoute *)[[response routes] objectAtIndex:0];
                 if (prevPolyline) {
                     [mapView removeOverlay:prevPolyline];
                 }
                 [mapView addOverlay:route.polyline];
                 prevPolyline = route.polyline;
                 
                 [mapView setVisibleMapRect:route.polyline.boundingMapRect edgePadding:UIEdgeInsetsMake(5, 5, 5, 5) animated:YES];

                 //searchBox.text = [NSString stringWithFormat:@"Distance left of first step: %f",[(MKRouteStep *)[route.steps objectAtIndex:0] distance]];
                 NSUInteger pointCount = route.polyline.pointCount;
                 //http://stackoverflow.com/a/21865454
                 //allocate a C array to hold this many points/coordinates...
                 CLLocationCoordinate2D *rc = malloc(pointCount * sizeof(CLLocationCoordinate2D));
                 
                 
                 //get the coordinates (all of them)...
                 [route.polyline getCoordinates:rc
                                          range:NSMakeRange(0, pointCount)];
                 
                 angles = [[NSMutableArray alloc] initWithCapacity:pointCount];
                 [angles addObject:[NSNumber numberWithDouble:0]];
                 
                 //this part just shows how to use the results...
                 NSLog(@"route pointCount = %lu", (unsigned long)pointCount);
                 for (int c = 1; c < pointCount - 1; c++)
                 {
                     [angles addObject:[NSNumber numberWithDouble:[self getDifferenceBetweenAngle1:[self getBearingForLocation1:rc[c-1] location2:rc[c]] angle2:[self getBearingForLocation1:rc[c] location2:rc[c+1]]]]];
                     NSLog(@"routeCoordinates[%d] = %f, %f",
                           c, rc[c].latitude, rc[c].longitude);
                     NSLog(@"Angle: %f",[self getDifferenceBetweenAngle1:[self getBearingForLocation1:rc[c-1] location2:rc[c]] angle2:[self getBearingForLocation1:rc[c] location2:rc[c+1]]]);
                     NSLog(@"Distance from cur to point: %f", [currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:rc[c].latitude longitude:rc[c].longitude]] );
                 }
                 
                 //free the memory used by the C array when done with it...
                 free(rc);
                 currentRoute = route;
             }
         }];
    }
}
@end
