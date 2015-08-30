//
//  ViewController.h
//  SwarmMe
//
//  Created by Anton lopez on 8/10/15.
//  Copyright (c) 2015 Anton lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define NUM_BOIDS 50
#define SWITCH_EXPLOSION 0
#define SWITCH_FOLLOW 1

@interface ViewController : UIViewController
{
    IBOutlet UISlider* cohision;
    IBOutlet UISlider* seperation;
    IBOutlet UISlider* alignment;
    
    IBOutlet UISwitch* explosionSwitch;
    IBOutlet UISwitch* followSwitch;
    
    AVAudioPlayer* audioPlayer;
    
    BOOL shouldSwarmFinger;
    CGPoint swarmPoint;
    
    BOOL playPauseFlag;
}


@end

