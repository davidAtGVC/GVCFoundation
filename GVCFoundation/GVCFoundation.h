/**
 * Header for GVCFoundation
 */

#ifndef GVCFoundation_h
#define GVCFoundation_h


/* 
 * Additions 
 */
#import "NSArray+GVCFoundation.h"
#import "NSBundle+GVCFoundation.h"
#import "NSCharacterSet+GVCFoundation.h"
#import "NSData+GVCFoundation.h"
#import "NSDate+GVCFoundation.h"
#import "NSDictionary+GVCFoundation.h"
#import "NSError+GVCFoundation.h"
#import "NSFileManager+GVCFoundation.h"
#import "NSMethodSignature+GVCFoundation.h"
#import "NSObject+GVCFoundation.h"
#import "NSPredicate+GVCFoundation.h"
#import "NSScanner+GVCFoundation.h"
#import "NSSet+GVCFoundation.h"
#import "NSString+GVCFoundation.h"
#import "NSURLRequest+GVCFoundation.h"

/* 
 * Cache 
 */
#import "GVCCache.h"
#import "GVCCacheNode.h"

/* 
 * 
 */
#import "GVCCallbackFilter.h"
#import "GVCConfiguration.h"
#import "GVCFoundationConstants.h"
#import "GVCFunctions.h"
#import "GVCInvocation.h"
#import "GVCKeychain.h"
#import "GVCLogger.h"
#import "GVCMacros.h"
#import "GVCPair.h"
#import "GVCReaderWriter.h"
#import "GVCStack.h"
#import "GVCStopwatch.h"
#import "GVCStringWriter.h"
#import "GVCTextGenerator.h"

/* 
 * Networking 
 */
#import "GVCNetworking.h"
#import "GVCReachability.h"
#import "GVCUDPSocket.h"

/* 
 * Networking action 
 */
#import "GVCHTTPAction.h"
#import "GVCSOAPAction.h"

/* 
 * Networking data 
 */
#import "GVCMultipartResponseData.h"
#import "GVCNetResponseData.h"

/* 
 * Networking header 
 */
#import "GVCHTTPHeader.h"
#import "GVCHTTPHeaderSet.h"

/* 
 * Networking operation 
 */
#import "GVCHTTPOperation.h"
#import "GVCNetOperation.h"

/* 
 * Networking session 
 */
#import "GVCHTTPSession.h"
#import "GVCNetworkSession.h"
#import "GVCSOAPSession.h"

/* 
 * Operations 
 */
#import "GVCDemoDelayedOperation.h"
#import "GVCFileOperation.h"
#import "GVCOperation.h"
#import "GVCRunLoopOperation.h"
#import "GVCXMLParserOperation.h"

/* 
 * Parsing 
 */
#import "GVCCSVParser.h"
#import "GVCParser.h"

/* 
 * XML 
 */
#import "GVCXMLGenericNode.h"
#import "GVCXMLParserDelegate.h"
#import "GVCXMLParsingModel.h"

/* 
 * XML config 
 */
#import "GVCConfigDocument.h"
#import "GVCConfigObject.h"
#import "GVCConfigPackage.h"
#import "GVCConfigProperty.h"
#import "GVCConfigResource.h"

/* 
 * XML digest 
 */
#import "GVCXMLDigestSetChildForAttributeKeyRule.h"
#import "GVCXMLDigester.h"
#import "GVCXMLDigesterAttributeMapRule.h"
#import "GVCXMLDigesterCreateObjectRule.h"
#import "GVCXMLDigesterElementNamePropertyRule.h"
#import "GVCXMLDigesterPairAttributeTextRule.h"
#import "GVCXMLDigesterRule.h"
#import "GVCXMLDigesterRuleManager.h"
#import "GVCXMLDigesterRuleset.h"
#import "GVCXMLDigesterSetChildRule.h"
#import "GVCXMLDigesterSetPropertyRule.h"
#import "GVCXMLDigesterSetTextPropertyFromAttributeValueRule.h"

/* 
 * XML generator 
 */
#import "GVCXMLGenerator.h"
#import "GVCXMLOutputNode.h"

/* 
 * XML node 
 */
#import "GVCXMLAttribute.h"
#import "GVCXMLComment.h"
#import "GVCXMLContainerNode.h"
#import "GVCXMLDocType.h"
#import "GVCXMLDocument.h"
#import "GVCXMLNamespace.h"
#import "GVCXMLNode.h"
#import "GVCXMLParseNodeDelegate.h"
#import "GVCXMLProcessingInstructions.h"
#import "GVCXMLText.h"
#import "GVCXMLTextNode.h"

/* 
 * XML recursive 
 */
#import "GVCXMLRecursiveNode.h"
#import "GVCXMLRecursiveParserBase.h"
#import "GVCXMLRecursiveParserDelegate.h"

/* 
 * XML recursive soap 
 */
#import "GVCSOAPBody.h"
#import "GVCSOAPDocument.h"
#import "GVCSOAPEnvelope.h"
#import "GVCSOAPFault.h"
#import "GVCSOAPFaultDetail.h"
#import "GVCSOAPFaultcode.h"
#import "GVCSOAPFaultstring.h"
#import "GVCSOAPHeader.h"

/* 
 * XML recursive xsd 
 */
#import "GVCXSDString.h"

/* 
 * XML rss 
 */
#import "GVCRSSDigester.h"
#import "GVCRSSEntry.h"
#import "GVCRSSFeed.h"
#import "GVCRSSLink.h"
#import "GVCRSSNode.h"
#import "GVCRSSText.h"

/* 
 * filesystem 
 */
#import "GVCDirectory.h"
#import "GVCFile.h"
#import "GVCFileHandleWriter.h"
#import "GVCFileWriter.h"
#import "GVCFilesystemProtocol.h"

/* 
 * formatter 
 */
#import "GVCISO8601DateFormatter.h"

/* 
 * forms 
 */
#import "GVCFormEntryProtocols.h"

/* 
 * forms model 
 */
#import "GVCXMLFormConditionalGroup.h"
#import "GVCXMLFormLabelModel.h"
#import "GVCXMLFormModel.h"
#import "GVCXMLFormModelDigester.h"
#import "GVCXMLFormNode.h"
#import "GVCXMLFormOptionModel.h"
#import "GVCXMLFormQuestionModel.h"
#import "GVCXMLFormSectionModel.h"

#endif // GVCFoundation_h
