//
//  MyScene.m
//  AnimatedBear
//
//  Created by CJS on 14-5-7.
//  Copyright (c) 2014年 常家帅. All rights reserved.
//

#import "MyScene.h"
#import <AVFoundation/AVFoundation.h>

@implementation MyScene
{
    SKSpriteNode *_bear;
    NSArray *_bearWalkingFrames;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor blackColor];
        NSMutableArray *walkFrames = [NSMutableArray array];
        //加载纹理图集
        SKTextureAtlas *bearAnimatedAtlas = [SKTextureAtlas atlasNamed:@"BearImages"];
        
        //构建帧列表
        int numImages = bearAnimatedAtlas.textureNames.count;
        for (int i = 1; i <= numImages / 2; i++) {
            NSString *textureName = [NSString stringWithFormat:@"bear%d", i];
            SKTexture *temp = [bearAnimatedAtlas textureNamed:textureName];
            [walkFrames addObject:temp];
        }
        
        _bearWalkingFrames = walkFrames;
        
        SKTexture *temp = _bearWalkingFrames[0];
        _bear = [SKSpriteNode spriteNodeWithTexture:temp];
        _bear.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:_bear];
        [self walkingBear];
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //确定触摸的位置并定义一个变量代表熊的朝向
    CGPoint location = [[touches anyObject] locationInNode:self];
    CGFloat multiplierForDirection;
    
    //设置速度
    CGSize screenSize = self.frame.size;
    float bearVelocity = screenSize.width / 3.0;
    
    //计算出熊在X和Y轴中移动的量
    CGPoint moveDifference = CGPointMake(location.x - _bear.position.x, location.y - _bear.position.y);
    
    //计算出实际的移动距离
    float distanceToMove = sqrtf(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
    
    //计算出移动实际距离所需要花费的时间
    float moveDuration = distanceToMove / bearVelocity;
    
    //对动画做翻转（Flip）处理
    if (location.x <= CGRectGetMidX(self.frame)) {
        //walk left
        multiplierForDirection = 1;
    }else{
        //walk right
        multiplierForDirection = -1;
    }
    
    _bear.xScale = fabs(_bear.xScale) * multiplierForDirection;
    
    //开始action
    if ([_bear actionForKey:@"bearMoving"]) {
        [_bear removeActionForKey:@"bearMoving"];
    } //1
    
    if (![_bear actionForKey:@"walkingInPlaceBear"]) {
        //if legs are not moving go ahead and start them
        [self walkingBear];  //start the bear walking
    } //2
    
    SKAction *moveAction = [SKAction moveTo:location duration:moveDuration];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^{
        NSLog(@"Animation Completed");
        [self bearMoveEnded];
    }];
    
    SKAction *moveActionWithDone = [SKAction sequence:@[moveAction, doneAction]];
    [_bear runAction:moveActionWithDone withKey:@"bearMoving"];
}

-(void)bearMoveEnded
{
    [_bear removeAllActions];
}

-(void)walkingBear
{
    [_bear runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_bearWalkingFrames timePerFrame:0.1f resize:NO restore:YES]] withKey:@"walkingInPlaceBear"];
    return;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
