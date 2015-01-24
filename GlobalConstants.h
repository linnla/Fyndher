//
//  GlobalConstants.h
//  Fyndher
//
//  Created by Laure Linn on 07/11/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#define BASEURL                                             @"http://fyndher.appspot.com"

#define APISIGNUPUSER                                       @"/rest/1/loginDetails/createLoginDetails"
#define APILOGINUSER                                        @"/rest/1/loginDetails/login"
#define APILOGOUT                                           @"/rest/1/loginDetails/logout"
#define APIRESETPASSWORD                                    @"/rest/1/loginDetails/resetPassword"


#define APIGETMOREFAVORITEUSERDETAILS                       @"/rest/1/relationship/getNextFavouriteUsers"

#define APINEXTNEARESTUSERS                                 @"/rest/1/search/nextNearestUsers"

#define APIONLINEUSERS                                      @"/rest/1/search/nearestOnlineUsers"

#define APIUPDATEPROFILE                                    @"/rest/1/user/updateProfile"
#define APIVIEWPROFILE                                      @"/rest/1/user/view"
#define APIREPORTUSER                                       @"/rest/1/user/reportUser"
#define APINEARESTNEIGHBOR                                  @"/rest/1/search/nearestUsers"
#define APIUPDATEUSERLOCATION                               @"/rest/1/user/updateLocation"
#define APIFAVORITEUSERDETAILS                              @"/rest/1/relationship/getFavouriteUsers"

#define APISEARCHNEXTNEARESTONLINEUSERS                     @"/rest/1/search/nextNearestOnlineUsers"

#define APIVIEWRELATIONSHIP                                 @"/rest/1/relationship/viewRelationship"
#define APIUPDATERELATIONSHIP                               @"/rest/1/relationship/updateRelationship"
#define APIDELETERELATIONSHIP                               @"/rest/1/relationship/deleteRelationship"
#define APISENDMESSAGE                                      @"/rest/1/chat/sendMessage"
#define APIGETUNREADMESSAGES                                @"/rest/1/chat/getUnreadMessages"
#define APIGETALLREADMESSAGESFROMUSER                       @"/rest/1/chat/getParticularUserMessages"
#define APIGETUNREADMESSAGESANDCHATTINGUSERDETAILS          @"/rest/1/chat/getUnreadMessagesAndChattingUserDetails"
#define APIGETPARTICULARUSERCHATHISTORY                     @"/rest/1/chat/getParticularUserChatHistory"
#define APIDELETECHATHISTORY                                @"/rest/1/chat/deleteChatHistory"
#define APIDELETEPARTICULARUSERCHATHISTORY                  @"/rest/1/chat/deleteParticularUserChatHistory"

#define APISEARCHNEARESTUSERSBYUSERPROFILEATTRIBUTE         @"/rest/1/search/profileAttributeUsers"
#define APISEARCHNEXTNEARESTUSERSBYUSERPROFILEATTRIBUTE     @"/rest/1/search/nextProfileAttributeUsers"         //?offset=30"

#define APIGETLISTOFUSERDETAILS                             @"/rest/1/user/getListOfUserDetails"
#define APICHANGEMESSAGESTATUSASREAD                        @"/rest/1/chat/changeMessageStatus"
#define APIGETFAVOURITEUSERDETAILS                          @"/rest/1/relationship/getFavouriteUsers"

#define APIGETRECENTCHATTINGUSER                            @"/rest/1/chat/getRecentChattingUsers"




#define KEYFAVORITEUSERS           @"favoriteusers"
#define KEYBLOCKEDUSERS            @"blockedusers"
#define KEYEMAIL                   @"email"
#define KEYPROFILEATTRIBUTE        @"profileattribute"
#define KEYLOGINEDUSERSCREENNAME   @"screenname"
