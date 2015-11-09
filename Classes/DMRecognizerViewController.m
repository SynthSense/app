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
@synthesize synthesizer, geocoder, currentAddress, currentLocation, directions, curLocLat, curLocLon, rfduino;
@synthesize locationManager = _locationManager;

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
    
	// Set earcons to play
	SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
	SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
	SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_cancel.wav"];
	
	[SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
	[SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
	[SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    
    
    //[curLocBox setText:@"TEXT"];
    geocoder = [[CLGeocoder alloc] init];

    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        //[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways
        ) {
        // Will open an confirm dialog to get user's approval
        [_locationManager requestWhenInUseAuthorization];
        //[_locationManager requestAlwaysAuthorization];
    } else {
        [_locationManager startUpdatingLocation]; //Will update location immediately
    }
    [rfduino setDelegate:self];

    //if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    //[_locationManager requestWhenInUseAuthorization];
    //[_locationManager startUpdatingLocation];
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
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
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
    //NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    //NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    currentLocation = newLocation;
    curLocLat = newLocation.coordinate.latitude;
    curLocLon = newLocation.coordinate.longitude;
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
        NSLog(@"%@", currentAddress);
        [curLocBox setText:currentAddress];

    }];
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


//- (void)dealloc {
//    [recordButton release];
//    [searchBox release];
//    [serverBox release];
//    [portBox release];
//    [alternativesDisplay release];
//    [vuMeter release];
//    [recognitionType release];
//	[languageType release];
//    
//    [voiceSearch release];
//	
//    [super dealloc];
//}

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
    // Debug - Uncomment this code and fill in your app ID below, and set
    // the Main Window nib to MainWindow_Debug (in DMRecognizer-Info.plist)
    // if you need the ability to change servers in DMRecognizer
    //
    //[SpeechKit setupWithID:INSERT_YOUR_APPLICATION_ID_HERE
    //                  host:INSERT_YOUR_HOST_ADDRESS_HERE
    //                  port:INSERT_YOUR_HOST_PORT_HERE[[portBox text] intValue]
    //                useSSL:NO
    //              delegate:self];
    //
	// Set earcons to play
	//SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
	//SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
	//SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_cancel.wav"];
	//
	//[SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
	//[SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
	//[SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];    
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
    
    if (numOfResults > 0) {
        searchBox.text = [results firstResult];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:searchBox.text];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-us"];
        [self.synthesizer speakUtterance:utterance];
        
        [geocoder geocodeAddressString:searchBox.text completionHandler:^(NSArray *placemarks, NSError *error) {
            if(error){
                NSLog(@"%@", [error localizedDescription]);
            }
            
            CLPlacemark *placemark = [placemarks lastObject];

            //NSLog(@"%@", currentAddress);
            //[directions setText:currentAddress];
            
            MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
            if (currentLocation) {
                //CLLocation *tmp = [currentLocation copy];
                //NSLog(@"%f", tmp.coordinate.latitude);
                MKPlacemark *placemarkSrc = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(curLocLat, curLocLon) addressDictionary:nil];
                MKMapItem *mapItemSrc = [[MKMapItem alloc] initWithPlacemark:placemarkSrc];
                
                MKPlacemark *placemarkDest = [[MKPlacemark alloc] initWithCoordinate:placemark.location.coordinate addressDictionary:nil];
                MKMapItem *mapItemDest = [[MKMapItem alloc] initWithPlacemark:placemarkDest];
                
                [request setSource:mapItemSrc];
                [request setDestination:mapItemDest];
                [request setTransportType:MKDirectionsTransportTypeAutomobile];
                request.requestsAlternateRoutes = NO;
                
                MKDirections *dirs = [[MKDirections alloc] initWithRequest:request];
                [dirs calculateDirectionsWithCompletionHandler:
                 ^(MKDirectionsResponse *response, NSError *error) {
                     if (error) {
                         [directions setText:@"ERROR!"];

                         // Handle Error
                     } else {
                         //[_mapView removeOverlays:_mapView.overlays];
                         //NSLog(@"%@", response.)
                         MKRoute *route = (MKRoute *)[[response routes] objectAtIndex:0];
                         NSMutableString *outStr = [[NSMutableString alloc] initWithString:@""];
                         for (NSUInteger i = 0; i < route.steps.count; i++) {
                             NSLog(@"%@", [(MKRouteStep *)[route.steps objectAtIndex:i] instructions]);
                             [outStr appendString:[NSString stringWithFormat:@"%@\n",[(MKRouteStep *)[route.steps objectAtIndex:i] instructions]] ];
                         }
                         [directions setText:outStr];
                         //[self showRoute:response];
                     }
                 }];

            }
           

        }];


        

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
@end
