//
//  LVButton.m
//  lv5.1.4
//
//  Created by dongxicheng on 12/17/14.
//  Copyright (c) 2014 dongxicheng. All rights reserved.
//

#import "LVButton.h"
#import "LVBaseView.h"
#import "LVImageView.h"
#import "LVUtil.h"
#import "LView.h"
#import "LVAttributedString.h"

@interface  LVButton()
@end

@implementation LVButton

-(id) init:(lv_State*) l{
    self = [super init];
    if( self ){
        self.lv_lview = (__bridge LView *)(l->lView);
        [self addTarget:self action:@selector(lvButtonCallBack) forControlEvents:UIControlEventTouchUpInside];
        
        // 默认黑色字
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return self;
}

-(void) dealloc{
}

-(void) lvButtonCallBack{
    lv_State* L = self.lv_lview.l;
    if( L && self.lv_userData ){
        int num = lv_gettop(L);
        lv_pushUserdata(L, self.lv_userData);
        lv_pushUDataRef(L, USERDATA_KEY_DELEGATE );
        lv_runFunction(L);
        lv_settop(L, num);
    }
}

-(void) setImageUrl:(NSString*) url placeholder:(UIImage *)placeholder state:(UIControlState) state {
    if( [LVUtil isExternalUrl:url] ){
        // [self setImage:[LVUtil getImageFromURL:[NSURL URLWithString:url]] forState:state];
        // [self setImageWithCDNURL:[NSURL URLWithString:url] forState:state completed:complete];
    } else {
        if( url ) {
            [self setImage:[LVUtil cachesImage:url] forState:state];
        }
    }
}

static Class g_class = nil;

+ (void) setDefaultStyle:(Class) c{
    if( [c isSubclassOfClass:[LVButton class]] ) {
        g_class = c;
    }
}

#pragma -mark Button
static int lvNewButton (lv_State *L) {
    if( g_class == nil ){
        g_class = [LVButton class];
    }
    {
        LVButton* button = [[g_class alloc] init:L];
        {
            NEW_USERDATA(userData, LVUserDataView);
            userData->view = CFBridgingRetain(button);
            button.lv_userData = userData;
            
            lvL_getmetatable(L, META_TABLE_UIButton );
            lv_setmetatable(L, -2);
        }
        UIView* father = (__bridge UIView *)(L->lView);
        if( father ){
            [father addSubview:button];
        }
    }
    return 1; /* new userdatum is already on the stack */
}

static int selected (lv_State *L) {
    LVUserDataView * user = (LVUserDataView *)lv_touserdata(L, 1);
    if( user ){
        LVButton* button = (__bridge LVButton *)(user->view);
        if( button ){
            if ( lv_gettop(L)>=2 ) {
                BOOL yes = lvL_checkbool(L, 2);
                button.selected = yes;
                return 0;
            } else {
                lv_pushboolean(L, button.selected );
                return 1;
            }
        }
    }
    return 0;
}

static int enabled (lv_State *L) {
    LVUserDataView * user = (LVUserDataView *)lv_touserdata(L, 1);
    if( user ){
        LVButton* button = (__bridge LVButton *)(user->view);
        if ( lv_gettop(L)>=2 ){
            BOOL yes = lvL_checkbool(L, 2);
            button.enabled = yes;
            return 0;
        } else {
            lv_pushboolean(L, button.enabled);
            return 1;
        }
    }
    return 0;
}

static int setImage (lv_State *L) {
    LVUserDataView * user = (LVUserDataView *)lv_touserdata(L, 1);
    if( user ){
        NSString* normalImage = lv_paramString(L, 2);// 2
        NSString* hightLightImage = lv_paramString(L, 3);// 2
        NSString* disableImage = lv_paramString(L, 4);// 2
        NSString* selectedImage = lv_paramString(L, 5);// 2
        LVButton* button = (__bridge LVButton *)(user->view);
        if( [button isKindOfClass:[LVButton class]] ){
            [button setImageUrl:normalImage placeholder:nil state:UIControlStateNormal];
            [button setImageUrl:hightLightImage placeholder:nil state:UIControlStateHighlighted];
            [button setImageUrl:disableImage placeholder:nil state:UIControlStateDisabled];
            [button setImageUrl:selectedImage placeholder:nil state:UIControlStateSelected];
            
            lv_pushvalue(L, 1);
            return 1;
        }
    }
    return 0;
}

static const UIControlState g_states[] = {UIControlStateNormal,UIControlStateHighlighted,UIControlStateDisabled,UIControlStateSelected};
static int title (lv_State *L) {
    LVUserDataView * user = (LVUserDataView *)lv_touserdata(L, 1);
    if( user ){
        LVButton* button = (__bridge LVButton *)(user->view);
        if( [button isKindOfClass:[LVButton class]] ){
            int num = lv_gettop(L);
            if ( num>=2 ) {// setValue
                for (int i=2,j=0; i<=num && j<4; i++ ){
                    if ( lv_type(L, i) == LV_TSTRING ) {
                        NSString* text1 = lv_paramString(L, i);
                        if( text1 ) {
                            [button setTitle:text1 forState:g_states[j++]];
                        }
                    } else if( lv_type(L, 2)==LV_TUSERDATA ){
                        LVUserDataAttributedString * user2 = lv_touserdata(L, 2);
                        if( user2 && LVIsType(user2, LVUserDataAttributedString) ) {
                            LVAttributedString* attString = (__bridge LVAttributedString *)(user2->attributedString);
                            [button setAttributedTitle:attString.mutableAttributedString forState:g_states[j++]  ];
                            [button.titleLabel sizeToFit];
                        }
                    }
                }
                return 0;
            } else { // getValue
                for (int j=0; j<4; j++ ){
                    NSString* text1 = [button titleForState:g_states[j++] ];
                    lv_pushstring(L, text1.UTF8String);
                }
                return 4;
            }
        }
    }
    return 0;
}

static int titleColor (lv_State *L) {
    LVUserDataView * user = (LVUserDataView *)lv_touserdata(L, 1);
    if( user ){
        LVButton* button = (__bridge LVButton *)(user->view);
        if( [button isKindOfClass:[LVButton class]] ){
            int num = lv_gettop(L);
            if ( num>=2 ) {
                for (int i=2,j=0; i<=num && j<4; i++ ){
                    if( lv_type(L, i)==LV_TNUMBER ) {
                        NSInteger rgb = lv_tonumber(L, i);
                        UIColor* c = lv_UIColorFromRGBA(rgb, 1);
                        [button setTitleColor:c forState:g_states[j++]];
                    }
                }
                return 0;
            } else {
                int retvalueNum = 0;
                for (int j=0; j<4; j++ ){
                    UIColor* c = [button titleColorForState:g_states[j++] ];
                    NSUInteger color=0 ;
                    float a = 0;
                    if( lv_uicolor2int(c, &color, &a) ){
                        lv_pushnumber(L, color);
                        lv_pushnumber(L, a);
                        retvalueNum += 2;
                    }
                }
                return retvalueNum;
            }
        }
    }
    return 0;
}

static int font (lv_State *L) {
    LVUserDataView * user = (LVUserDataView *)lv_touserdata(L, 1);
    if( user ){
        LVButton* view = (__bridge LVButton *)(user->view);
        if( [view isKindOfClass:[LVButton class]] ){
            int num = lv_gettop(L);
            if( num>=2 ) {
                if( num>=3 && lv_type(L, 2)==LV_TSTRING ) {
                    NSString* fontName = lv_paramString(L, 2);
                    float fontSize = lv_tonumber(L, 3);
                    view.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
                } else {
                    float fontSize = lv_tonumber(L, 2);
                    view.titleLabel.font = [UIFont systemFontOfSize:fontSize];
                }
                return 0;
            } else {
                UIFont* font = view.titleLabel.font;
                lv_pushstring(L, font.fontName.UTF8String);
                lv_pushnumber(L, font.pointSize);
                return 2;
            }
        }
    }
    return 0;
}

static int showsTouchWhenHighlighted(lv_State *L) {
    LVUserDataView * user = (LVUserDataView *)lv_touserdata(L, 1);
    if( user ){
        LVButton* button = (__bridge LVButton *)(user->view);
        if( lv_gettop(L)<=1 ) {
            lv_pushboolean(L, button.showsTouchWhenHighlighted );
            return 1;
        } else {
            BOOL yes = lvL_checkbool(L, 2);
            button.showsTouchWhenHighlighted = yes;
            return 0;
        }
    }
    return 0;
}

+(int) classDefine:(lv_State *)L {
    {
        lv_pushcfunction(L, lvNewButton);
        lv_setglobal(L, "UIButton");
    }
    const struct lvL_reg memberFunctions [] = {
        {"setImage",    setImage},
        
        
        {"setFont",    font},
        {"font",    font},
        
        {"setTitleColor",    titleColor},
        {"titleColor",    titleColor},
        
        {"setTitle",    title},
        {"title",    title},
        
        {"setText",    title},
        {"text",    title},

        {"setSelected", selected},
        {"selected",    selected},

        {"setEnabled", enabled},
        {"enabled",    enabled},
        
        {"setShowsTouchWhenHighlighted", showsTouchWhenHighlighted},
        {"showsTouchWhenHighlighted",    showsTouchWhenHighlighted},
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L,META_TABLE_UIButton);
    
    lvL_openlib(L, NULL, [LVBaseView baseMemberFunctions], 0);
    lvL_openlib(L, NULL, memberFunctions, 0);
    return 1;
}


//----------------------------------------------------------------------------------------

@end