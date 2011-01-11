//
//  TextView.m
//  CoreTextExtensions
//
//  Created by Oliver Drobnik on 1/9/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import "TextView.h"
#import "NSAttributedString+HTML.h"
#import "NSString+HTML.h"
#import "UIColor+HTML.h"


@implementation TextView


// TO DO: this should be configured as a Unit Test, but I don't know how
- (void)testParagraphs
{
	NSString *html = @"Prefix<p>One\ntwo\n<br>three</p><p>New Paragraph</p>Suffix";
	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	NSAttributedString *string = [[NSAttributedString alloc] initWithHTML:data documentAttributes:NULL];
	NSData *dump = [[string string] dataUsingEncoding:NSUTF8StringEncoding];
	NSString *resultOnIOS = [dump description];
	
	NSString *resultOnMac = @"<50726566 69780a4f 6e652074 776f20e2 80a87468 7265650a 4e657720 50617261 67726170 680a5375 66666978>";
	
	NSAssert([resultOnIOS isEqualToString:resultOnMac], @"Output on Paragraph Test differs");
}


- (void)testHeaderParagraphs
{
	NSString *html = @"Prefix<h1>One</h1><h2>One</h2><h3>One</h3><h4>One</h4><h5>One</h5><p>New Paragraph</p>Suffix";
	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	NSAttributedString *string = [[NSAttributedString alloc] initWithHTML:data documentAttributes:NULL];
	NSData *dump = [[string string] dataUsingEncoding:NSUTF8StringEncoding];
	NSString *resultOnIOS = [dump description];
	
	NSString *resultOnMac = @"<50726566 69780a4f 6e650a4f 6e650a4f 6e650a4f 6e650a4f 6e650a4e 65772050 61726167 72617068 0a537566 666978>";
	
	NSAssert([resultOnIOS isEqualToString:resultOnMac], @"Output on Paragraph Test differs");
	
	
}


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)awakeFromNib
{
	//self.backgroundColor = [UIColor colorWithHTMLName:@"purple"];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	
	[self testParagraphs];
	[self testHeaderParagraphs];
	
	
	NSString *readmePath = [[NSBundle mainBundle] pathForResource:@"README" ofType:@"html"];
	NSString *html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];

    // Drawing code.
	
	//NSString *html = @"<h1>A header</h2><p>Some <b>bold</b> and some <i>italic</i> Text. <FONT COLOR=\"#cc6600\">Possibly</FONT> a <a href=\"http://www.cocoanetics.com\"link</a> too?</p>";
	
	//NSString *html = @"<b>bold</b>,<i>italic</i>,<em>emphasized</em>,<strong>strong</strong> string.\n\tand a tab \t and a tab";
	
	//NSString *html = @"<font face=\"Helvetica\" color=\"red\">red <b>bold</b></font><br>Standard<br/><font face=\"Courier\" color=\"blue\">blue<em> italic</font></em><br/></font>Standard";
	//NSString *html = @"Prefix<h1>One</h1><h2>One</h2><h3>One</h3><h4>One</h4><h5>One</h5><p>New Paragraph</p>Suffix";

	//NSString *html = @"<h3>Header</h3>\n<p>Paragraph</p>";	
	
	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	NSAttributedString *string = [[NSAttributedString alloc] initWithHTML:data documentAttributes:NULL];
	/*
	
	NSLog(@"%@", [string string]);
	
	
	NSData *dump = [[string string] dataUsingEncoding:NSUTF8StringEncoding];
	
	for (int i=0; i<[dump length]; i++)
	{
		char *bytes = (char *)[dump bytes];
		
		char b = bytes[i];
		
		NSLog(@"%x %c", b, b);
	}
	
	
	NSLog(@"%@", dump);
	
	
	NSDictionary *attributes;
	
	NSRange effectiveRange = NSMakeRange(0, 0);
	
	while (attributes = [string attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange])
	{
		NSLog(@"Range: (%d, %d), %@", effectiveRange.location, effectiveRange.length, attributes);
		effectiveRange.location += effectiveRange.length;
		
		if (effectiveRange.location >= [string length])
		{
			break;
		}
	}
	 */
	
	// now for the actual drawing
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// flip the coordinate system
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	

	// layout master
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(
																		   (CFAttributedStringRef)string);
	
	// left column form
	CGMutablePathRef leftColumnPath = CGPathCreateMutable();
	CGPathAddRect(leftColumnPath, NULL, 
				  CGRectMake(0, 0, 
							 self.bounds.size.width,
							 self.bounds.size.height));
	
	// left column frame
	CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter, 
													CFRangeMake(0, 0),
													leftColumnPath, NULL);
	
	// draw
	CTFrameDraw(leftFrame, context);
	
	// cleanup
	CFRelease(leftFrame);
	CGPathRelease(leftColumnPath);
	CFRelease(framesetter);
	
	[string release];
}


- (void)dealloc {
    [super dealloc];
}


@end