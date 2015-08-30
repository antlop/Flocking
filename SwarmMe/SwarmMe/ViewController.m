//
//  ViewController.m
//  SwarmMe
//
//  Created by Anton lopez on 8/10/15.
//  Copyright (c) 2015 Anton lopez. All rights reserved.
//

#import "ViewController.h"
#import <math.h>
#import "Boid.h"

@interface ViewController ()
{
    UIImage* boidsImage;
    NSMutableArray* listOfBoids;
    NSMutableArray* listOfImagesForEachBoid;
    CADisplayLink *dpLink;
    
    CGPoint explodeLocation;
    BOOL shouldExplode;
    
    UILongPressGestureRecognizer* longFingerHold;
    UITapGestureRecognizer *singleFingerTap;
    
    BOOL wasShownAlready;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    listOfBoids = [[NSMutableArray alloc] init];
    listOfImagesForEachBoid = [[NSMutableArray alloc]init];
    boidsImage = [UIImage imageNamed:@"particleTexture.png"];
    for( int i = 0; i < NUM_BOIDS; ++i)
    {
        Boid* boidObj = [[Boid alloc]init];
        [listOfBoids addObject:boidObj];
        UIImageView* img = [[UIImageView alloc]initWithImage:boidsImage];
        [listOfImagesForEachBoid addObject:img];
        [self.view addSubview:img];
    }
    
    dpLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(Updater)];
    [dpLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    
    longFingerHold = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleFingerHold:)];
    
    
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    

    NSURL *audioFileURL = [[NSBundle mainBundle] URLForResource:@"Caked Up Wrecking Ball" withExtension:@"mp3"];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [audioPlayer setNumberOfLoops:-1];
    [audioPlayer setMeteringEnabled:YES];
    [audioPlayer play];
    
    playPauseFlag = NO;
    
    wasShownAlready = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(wasShownAlready)
    {
        dpLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(Updater)];
        [dpLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [dpLink invalidate];
    wasShownAlready = YES;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if(explosionSwitch.isOn)
        [self explosion:recognizer];
}

-(void)handleFingerHold:(UILongPressGestureRecognizer*)recognizer
{
    if(followSwitch.isOn)
        [self follow:recognizer];
}

-(void)follow:(UILongPressGestureRecognizer*)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        swarmPoint = [recognizer locationInView:self.view];
        shouldSwarmFinger = YES;
        NSLog(@"start: %f, %f", swarmPoint.x, swarmPoint.y);
    }
    else if( recognizer.state == UIGestureRecognizerStateChanged)
    {
        swarmPoint = [recognizer locationInView:self.view];
        NSLog(@"changed: %f, %f", swarmPoint.x, swarmPoint.y);
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        shouldSwarmFinger = NO;
    }
}

-(void)explosion:(UITapGestureRecognizer*)recognizer
{
    explodeLocation = [recognizer locationInView:self.view];
    
    shouldExplode = true;
    
    
    for (Boid* b in listOfBoids)
    {
        CGPoint vTB;
        vTB.x = b.position.x - explodeLocation.x;
        vTB.y = b.position.y - explodeLocation.y;
        
        float distance = sqrt((vTB.x * vTB.x) + (vTB.y * vTB.y));
        if( distance == 0)
            continue;
        
        float invDistance = 1 / distance;
        float impulseMag = 200000 * invDistance * invDistance;
        
        vTB.x *= impulseMag;
        vTB.y *= impulseMag;
        
        b.adjustmentVector = CGPointMake(vTB.x, vTB.y);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)playPauseButtonPreased:(id)sender
{
    playPauseFlag = !playPauseFlag;
    
    if(playPauseFlag)
    {
        UIButton* but = sender;
        [but setTitle:@"l>" forState:UIControlStateNormal];
        [audioPlayer pause];
    }
    else
    {
        UIButton* but = sender;
        [but setTitle:@"l l" forState:UIControlStateNormal];
        [audioPlayer play];
    }
}

- (IBAction)SwitchInGrpOneChanged:(id)sender
{
    UISwitch* s = sender;
    
    switch (s.tag) {
        case SWITCH_EXPLOSION:
            if( explosionSwitch.isOn)
            {
                [followSwitch setOn:NO animated:YES];
                [self.view removeGestureRecognizer:longFingerHold];
                [self.view addGestureRecognizer:singleFingerTap];
            }
            else
            {
                [followSwitch setOn:YES animated:YES];
                [self.view removeGestureRecognizer:singleFingerTap];
                [self.view addGestureRecognizer:longFingerHold];
            }
            break;
            
        case SWITCH_FOLLOW:
            if(followSwitch.isOn)
            {
                [explosionSwitch setOn:NO animated:YES];
                [self.view addGestureRecognizer:longFingerHold];
                [self.view removeGestureRecognizer:singleFingerTap];
            }
            else
            {
                [explosionSwitch setOn:YES animated:YES];
                [self.view addGestureRecognizer:singleFingerTap];
                [self.view removeGestureRecognizer:longFingerHold];
            }
            break;
            
        default:
            break;
    }
}

- (IBAction)WeightChange:(id)sender
{
    UISlider* slider = sender;
    
    for (Boid* b in listOfBoids)
    {
        switch ([sender tag]) {
            case 0:
                b.seperationAmount = slider.value;
                break;
            case 1:
                b.cohisionAmount = slider.value;
                break;
            case 2:
                b.alignmentAmount = slider.value;
                break;
        }
    }
}


-(void)Updater
{
    float power = 0.0f;
    static float p = 0.0;
    if (audioPlayer.playing )
    {
        // 2
        [audioPlayer updateMeters];
        
        // 3
        for (int i = 0; i < [audioPlayer numberOfChannels]; i++)
        {
            power += [audioPlayer averagePowerForChannel:i] + 60;
        }
        power /= [audioPlayer numberOfChannels];
    }
    if( power > p )
        p = power;
    
    
    int itter = 0;
    for (Boid* b in listOfBoids)
    {
        if( shouldSwarmFinger )
            b.fingerPoint = swarmPoint;
        else
            b.fingerPoint = CGPointMake(-1, -1);
        
        [b UpdateWithTimeStep:dpLink.duration withFrame:self.view.frame andFlock:listOfBoids];
        if( itter < listOfImagesForEachBoid.count)
        {
            UIImageView* img = [listOfImagesForEachBoid objectAtIndex:itter++];
            
            if( img != nil && b != nil)
            {
                CGRect r = img.frame;
                if( power > 50.0f)
                {
                    r.size.height = 75;
                    r.size.width = 75;
                }
                else
                {
                    r.size.height = 50;
                    r.size.width = 50;
                }
                
                if( b.position.x < 0)
                    r.origin.x = 0.0f;
                else if( !isnan(b.position.x))
                    r.origin.x = b.position.x;
                
                if( b.position.y < 0)
                    r.origin.y = 0.0f;
                else if( !isnan(b.position.y))
                    r.origin.y = b.position.y;

                img.frame = r;
            }
        }
    }
}

@end
