//
//  ApptentiveConversationMetadataItem.m
//  Apptentive
//
//  Created by Frank Schmitt on 2/20/17.
//  Copyright © 2017 Apptentive, Inc. All rights reserved.
//

#import "ApptentiveConversationMetadataItem.h"
#import "ApptentiveDefines.h"

#define VERSION 1

static NSString *const StateKey = @"state";
static NSString *const ConversationIdentifierKey = @"conversationIdentifier";
static NSString *const FileNameKey = @"fileName";
static NSString *const EncryptionKeyKey = @"encryptionKey";
static NSString *const VersionKey = @"version";
static NSString *const UserIdKey = @"userId";
static NSString *const JWTKey = @"JWT";


@implementation ApptentiveConversationMetadataItem

- (instancetype)initWithConversationIdentifier:(NSString *)conversationIdentifier directoryName:(NSString *)filename {
	self = [super init];

	if (self) {
		APPTENTIVE_CHECK_INIT_NOT_EMPTY_ARG(conversationIdentifier);
		APPTENTIVE_CHECK_INIT_NOT_EMPTY_ARG(filename);

		_conversationIdentifier = conversationIdentifier;
		_directoryName = filename;
	}

	return self;
}

+ (BOOL)supportsSecureCoding {
	return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super init];

	if (self) {
		_state = [coder decodeIntegerForKey:StateKey];
		_conversationIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:ConversationIdentifierKey];
		_directoryName = [coder decodeObjectOfClass:[NSString class] forKey:FileNameKey];
		_encryptionKey = [coder decodeObjectOfClass:[NSData class] forKey:EncryptionKeyKey];
		_userId = [coder decodeObjectOfClass:[NSString class] forKey:UserIdKey];
		_JWT = [coder decodeObjectOfClass:[NSString class] forKey:JWTKey];
	}

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInteger:self.state forKey:StateKey];
	[coder encodeObject:self.conversationIdentifier forKey:ConversationIdentifierKey];
	[coder encodeObject:self.directoryName forKey:FileNameKey];
	[coder encodeObject:self.encryptionKey forKey:EncryptionKeyKey];
	[coder encodeObject:self.userId forKey:UserIdKey];
	[coder encodeObject:self.JWT forKey:JWTKey];
	[coder encodeInteger:VERSION forKey:VersionKey];
}

- (BOOL)isConsistent {
	if (self.state == ApptentiveConversationStateUndefined) {
		ApptentiveLogError(@"Conversation metadata item state is undefined");
		return NO;
	}

	if (self.directoryName.length == 0) {
		ApptentiveLogError(@"Conversation metadata directory name is empty");
		return NO;
	}

	if (self.state == ApptentiveConversationStateAnonymous || self.state == ApptentiveConversationStateLoggedIn) {
		if (self.conversationIdentifier.length == 0) {
			ApptentiveLogError(@"Conversation metadata conversation identifier is empty for anonymous for state %@", NSStringFromApptentiveConversationState(self.state));

			return NO;
		}
	}

	if (self.state == ApptentiveConversationStateLoggedIn) {
		if (self.userId.length == 0) {
			ApptentiveLogError(@"Conversation metadata userId is empty for logged-in conversation.");
			return NO;
		}

		if (self.JWT.length == 0) {
			ApptentiveLogError(@"Conversation metadata JWT is empty for logged-in conversation.");
			return NO;
		}

		if (self.encryptionKey.length == 0) {
			ApptentiveLogError(@"Conversation metadata encryption key is empty for logged-in conversation.");
			return NO;
		}
	}

	return YES;
}

@end
