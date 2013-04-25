/*
 * GVCRSSDigester.m
 * 
 * Created by David Aspinall on 12-03-14. 
 * Copyright (c) 2012 Global Village Consulting. All rights reserved.
 *
 */

#import "GVCRSSDigester.h"

#import "GVCMacros.h"
#import "GVCFunctions.h"

#import "GVCXMLGenerator.h"
#import "GVCXMLDigesterRule.h"
#import "GVCXMLDigesterRuleManager.h"
#import "GVCXMLDigesterRuleset.h"
#import "GVCXMLDigesterAttributeMapRule.h"
#import "GVCXMLDigesterPairAttributeTextRule.h"
#import "GVCXMLDigesterCreateObjectRule.h"
#import "GVCXMLDigesterSetChildRule.h"
#import "GVCXMLDigesterElementNamePropertyRule.h"

@implementation GVCRSSDigester

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
        GVCXMLDigesterCreateObjectRule *create_feed = [[GVCXMLDigesterCreateObjectRule alloc] initForClassname:@"GVCRSSFeed"];
        [self addRule:create_feed forPattern:@"^feed"];
        [self addRule:create_feed forPattern:@"^rss"];

        GVCXMLDigesterCreateObjectRule *createEntry = [[GVCXMLDigesterCreateObjectRule alloc] initForClassname:@"GVCRSSEntry"];
        [self addRule:createEntry forNodeName:@"entry"];
        [self addRule:createEntry forNodeName:@"item"];

        GVCXMLDigesterCreateObjectRule *create_link = [[GVCXMLDigesterCreateObjectRule alloc] initForClassname:@"GVCRSSLink"];
        [self addRule:create_link forNodeName:@"link"];
		[self addRule:create_link forNodeName:@"guid"];
		[self addRule:create_link forNodeName:@"source"];

        GVCXMLDigesterCreateObjectRule *create_text = [[GVCXMLDigesterCreateObjectRule alloc] initForClassname:@"GVCRSSText"];
		[self addRule:create_text forNodeName:@"title"];
		[self addRule:create_text forNodeName:@"subtitle"];
		[self addRule:create_text forNodeName:@"content"];
		[self addRule:create_text forNodeName:@"summary"];
		[self addRule:create_text forNodeName:@"description"];
        
		GVCXMLDigesterAttributeMapRule *feedNamespace = [[GVCXMLDigesterAttributeMapRule alloc] initWithKeysAndValues:@"xmlns", @"feedNamespaceURI", nil];
		[self addRule:feedNamespace forPattern:@"^feed"];

		GVCXMLDigesterAttributeMapRule *rssAttributes = [[GVCXMLDigesterAttributeMapRule alloc] initWithKeysAndValues:@"version", @"rssVersion", nil];
		[self addRule:rssAttributes forPattern:@"^rss"];

        GVCXMLDigesterAttributeMapRule *text_attributes = [[GVCXMLDigesterAttributeMapRule alloc] initWithKeysAndValues:@"type", @"textType", nil];
		[self addRule:text_attributes forNodeName:@"title"];
		[self addRule:text_attributes forNodeName:@"subtitle"];
		[self addRule:text_attributes forNodeName:@"content"];
		[self addRule:text_attributes forNodeName:@"summary"];
		[self addRule:text_attributes forNodeName:@"link"];
		[self addRule:text_attributes forNodeName:@"guid"];
		[self addRule:text_attributes forNodeName:@"description"];

        GVCXMLDigesterAttributeMapRule *linkAttributes = [[GVCXMLDigesterAttributeMapRule alloc] initWithKeysAndValues:
                                                          @"href", @"linkHref", 
                                                          @"rel", @"linkRel", 
                                                          @"hreflang", @"linkHreflang", 
                                                          @"title", @"linkTitle", 
                                                          @"length", @"linkLength",
                                                          @"isPermaLink", @"linkIsPermaLink", nil];
		[self addRule:linkAttributes forNodeName:@"link"];
		[self addRule:linkAttributes forNodeName:@"guid"];
		[self addRule:linkAttributes forNodeName:@"source"];

        
		[self addRule:[GVCXMLDigesterRule ruleForSetPropertyText:@"feedId"] forPattern:@"^feed/id"];
		[self addRule:[GVCXMLDigesterRule ruleForSetPropertyText:@"feedUpdatedFromString"] forPattern:@"^feed/updated"];
		[self addRule:[GVCXMLDigesterRule ruleForSetPropertyText:@"rssPubDateFromString"] forPattern:@"^rss/channel/pubDate"];
		[self addRule:[GVCXMLDigesterRule ruleForSetPropertyText:@"entryId"] forPattern:@"^feed/entry/id"];
		[self addRule:[GVCXMLDigesterRule ruleForSetPropertyText:@"entryUpdatedFromString"] forPattern:@"^feed/entry/updated"];
		[self addRule:[GVCXMLDigesterRule ruleForSetPropertyText:@"entryPubDateFromString"] forPattern:@"^rss/channel/item/pubDate"];

        
        GVCXMLDigesterSetChildRule *set_child_entry = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"feedEntry"];
		[self addRule:set_child_entry forPattern:@"^feed/entry"];
		[self addRule:set_child_entry forPattern:@"^rss/channel/item"];

        GVCXMLDigesterSetChildRule *set_child_feed_link = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"feedLink"];
		[self addRule:set_child_feed_link forPattern:@"^feed/link"];
		[self addRule:set_child_feed_link forPattern:@"^rss/channel/link"];
        
        GVCXMLDigesterSetChildRule *set_child_entry_link = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"entryLink"];
		[self addRule:set_child_entry_link forPattern:@"^feed/entry/link"];
		[self addRule:set_child_entry_link forPattern:@"^rss/channel/item/link"];
		[self addRule:set_child_entry_link forPattern:@"^rss/channel/item/guid"];
        
        GVCXMLDigesterSetChildRule *set_child_feed_title = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"feedTitle"];
		[self addRule:set_child_feed_title forPattern:@"^feed/title"];
		[self addRule:set_child_feed_title forPattern:@"^rss/channel/title"];
        
        GVCXMLDigesterSetChildRule *set_child_feed_subtitle = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"feedSubTitle"];
		[self addRule:set_child_feed_subtitle forPattern:@"^feed/subtitle"];
		[self addRule:set_child_feed_subtitle forPattern:@"^rss/channel/description"];
        
        GVCXMLDigesterSetChildRule *set_child_entry_title = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"entryTitle"];
		[self addRule:set_child_entry_title forPattern:@"^feed/entry/title"];
		[self addRule:set_child_entry_title forPattern:@"^rss/channel/item/title"];
        
        GVCXMLDigesterSetChildRule *set_child_entry_content = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"entryContent"];
		[self addRule:set_child_entry_content forPattern:@"^feed/entry/content"];
        
        GVCXMLDigesterSetChildRule *set_child_entry_summary = [[GVCXMLDigesterSetChildRule alloc] initWithPropertyName:@"entrySummary"];
		[self addRule:set_child_entry_summary forPattern:@"^feed/entry/summary"];
		[self addRule:set_child_entry_summary forPattern:@"^rss/channel/item/description"];
		
		// node name rule
		GVCXMLDigesterElementNamePropertyRule *nodeName = [[GVCXMLDigesterElementNamePropertyRule alloc] initWithPropertyName:@"nodeName"];
		[self addRule:nodeName forNodeName:@"feed"];
		[self addRule:nodeName forNodeName:@"title"];
		[self addRule:nodeName forNodeName:@"subtitle"];
		[self addRule:nodeName forNodeName:@"content"];
		[self addRule:nodeName forNodeName:@"summary"];
		[self addRule:nodeName forNodeName:@"link"];

		[self addRule:nodeName forNodeName:@"rss"];
		[self addRule:nodeName forNodeName:@"guid"];
		[self addRule:nodeName forNodeName:@"description"];

		GVCXMLDigesterSetPropertyRule *set_prop_text = [[GVCXMLDigesterSetPropertyRule alloc] initWithPropertyName:@"textContent"];
		[self addRule:set_prop_text forNodeName:@"title"];
		[self addRule:set_prop_text forNodeName:@"subtitle"];
		[self addRule:set_prop_text forNodeName:@"content"];
		[self addRule:set_prop_text forNodeName:@"summary"];
		[self addRule:set_prop_text forNodeName:@"description"];
		[self addRule:set_prop_text forNodeName:@"guid"];
		[self addRule:set_prop_text forNodeName:@"link"];
		[self addRule:set_prop_text forNodeName:@"source"];
        
        GVCXMLDigesterSetCDATARule *set_prop_cdata = [[GVCXMLDigesterSetCDATARule alloc] initWithPropertyName:@"textCDATA"];
		[self addRule:set_prop_cdata forNodeName:@"title"];
		[self addRule:set_prop_cdata forNodeName:@"subtitle"];
		[self addRule:set_prop_cdata forNodeName:@"content"];
		[self addRule:set_prop_cdata forNodeName:@"summary"];
		[self addRule:set_prop_cdata forNodeName:@"description"];
		[self addRule:set_prop_cdata forNodeName:@"guid"];
		[self addRule:set_prop_cdata forNodeName:@"link"];
		[self addRule:set_prop_cdata forNodeName:@"source"];

	}
	
    return self;
}

@end
