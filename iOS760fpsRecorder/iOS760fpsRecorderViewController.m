//
//  iOS760fpsRecorderViewController.m
//  iOS760fpsRecorder
//
//  Created by Ruotsalainen Werner on 6/24/13.
//  Copyright (c) 2013 Ruotsalainen Werner. All rights reserved.
//

#import "iOS760fpsRecorderViewController.h"

@interface iOS760fpsRecorderViewController ()

@end

@implementation iOS760fpsRecorderViewController
@synthesize captureSession;
@synthesize previewLayer, fo, videoDevice, startStopButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.startStopButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 40, 80, 60)];
    [startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    [startStopButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // 1. session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // 2. in
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (!error) {
        if ([self.captureSession canAddInput:videoIn])
            [self.captureSession addInput:videoIn];
        else
            NSLog(@"Video input add-to-session failed");
    }
	else
        NSLog(@"Video input creation failed");
    
//    int idx=0;
//    for (AVCaptureDeviceFormat* currdf in videoDevice.formats)
//        NSLog(@"%@ - %i", currdf, idx++);
    
    // 3. out
    self.fo = [[AVCaptureMovieFileOutput alloc] init];
    [self.captureSession addOutput:self.fo];

    
    // 4. display preview
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    previewLayer.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
    previewLayer.contentsGravity = kCAGravityResizeAspectFill;
	[self.view.layer addSublayer:self.previewLayer];
    [self.view addSubview:self.startStopButton];
    [self.captureSession startRunning];
}

//-(void)enableIS
//{
//    
//    AVCaptureConnection         *videoConnection = [self.fo connectionWithMediaType:AVMediaTypeVideo];
//    if ([videoConnection isVideoStabilizationSupported])
//    {
//        NSLog(@"VideoStabilizationSupported! Curr val: %i", [videoConnection isVideoStabilizationEnabled]);
//        if (![videoConnection isVideoStabilizationEnabled])
//        {
//            NSLog(@"enabling Video Stabilization!");
//            
//            videoConnection.enablesVideoStabilizationWhenAvailable= YES;
//            NSLog(@"after: %i", [videoConnection isVideoStabilizationEnabled]);
//        }
//    }
//    
//}
-(NSUInteger)supportedInterfaceOrientations{
    NSLog(@"supportedInterfaceOrientations");
    return UIInterfaceOrientationMaskPortrait; 
}

-(void)startVideoRecording
{
    int    selectedAVCaptureDeviceFormatIdx = 15;
    
    
    [videoDevice lockForConfiguration:nil];
    
    AVCaptureDeviceFormat* currdf = [videoDevice.formats objectAtIndex:selectedAVCaptureDeviceFormatIdx];
    videoDevice.activeFormat = currdf;
    if (selectedAVCaptureDeviceFormatIdx==12 || selectedAVCaptureDeviceFormatIdx==13)
        videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1,60);
    
    NSLog(@"%f", videoDevice.activeFormat.videoMaxZoomFactor);
    
    NSLog(@"videoZoomFactorUpscaleThreshold: %f", videoDevice.activeFormat.videoZoomFactorUpscaleThreshold);
    
    self.videoDevice.videoZoomFactor = videoDevice.activeFormat.videoZoomFactorUpscaleThreshold;
//        self.videoDevice.videoZoomFactor = 3;

    
    [videoDevice unlockForConfiguration];
    
    int fileNamePostfix = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = nil;
    do
        filePath =[NSString stringWithFormat:@"/%@/%i.mp4", documentsDirectory, fileNamePostfix++];
    while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    
    NSURL* fileURL = [NSURL URLWithString:[@"file://" stringByAppendingString:filePath]];
    [self.fo startRecordingToOutputFileURL:fileURL recordingDelegate:self];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{}

- (void)buttonPressed
{
//    NSLog(@"buttonPressed");
    if ([self.startStopButton.titleLabel.text isEqualToString:@"Start"])
    {
        [startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self startVideoRecording];
    }
    else
    {
        [startStopButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.fo stopRecording];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
