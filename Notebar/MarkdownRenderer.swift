//
//  MarkdownRenderer.swift
//  Notebar
//
//  Created for markdown preview functionality
//

import Foundation
import Markdown
import AppKit

class MarkdownRenderer {
    static func render(markdownText: String, textColor: NSColor, backgroundColor: NSColor) -> NSAttributedString {
        // Pre-process: Convert single line breaks to double line breaks to preserve them
        // But we want to preserve single line breaks, so let's use a different strategy:
        // Replace single \n with a temporary marker, parse, then restore
        let processedText = markdownText.replacingOccurrences(of: "\n\n", with: "\u{0000}\u{0000}") // Mark double breaks
            .replacingOccurrences(of: "\n", with: "\u{0001}") // Mark single breaks
            .replacingOccurrences(of: "\u{0000}\u{0000}", with: "\n\n") // Restore double breaks
        
        let document = Document(parsing: processedText)
        var renderer = NSAttributedStringRenderer(textColor: textColor, backgroundColor: backgroundColor)
        let result = renderer.render(document: document)
        
        // Replace the marker back with line breaks
        let finalResult = NSMutableAttributedString(attributedString: result)
        let markerString = "\u{0001}"
        let fullRange = NSRange(location: 0, length: finalResult.length)
        finalResult.mutableString.replaceOccurrences(of: markerString, with: "\n", options: [], range: fullRange)
        
        return finalResult
    }
}

// Custom renderer to convert Markdown to NSAttributedString
struct NSAttributedStringRenderer {
    private var result = NSMutableAttributedString()
    private let textColor: NSColor
    private let backgroundColor: NSColor
    private let baseFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    
    init(textColor: NSColor, backgroundColor: NSColor) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
    
    mutating func render(document: Document) -> NSAttributedString {
        for child in document.children {
            result.append(visit(child))
        }
        return result
    }
    
    mutating func visit(_ markup: Markup) -> NSAttributedString {
        switch markup {
        case let text as Markdown.Text:
            return visitText(text)
        case let emphasis as Emphasis:
            return visitEmphasis(emphasis)
        case let strong as Strong:
            return visitStrong(strong)
        case let inlineCode as InlineCode:
            return visitInlineCode(inlineCode)
        case let softBreak as SoftBreak:
            return visitSoftBreak(softBreak)
        case let lineBreak as LineBreak:
            return visitLineBreak(lineBreak)
        case let paragraph as Paragraph:
            return visitParagraph(paragraph)
        case let heading as Heading:
            return visitHeading(heading)
        case let codeBlock as CodeBlock:
            return visitCodeBlock(codeBlock)
        case let blockQuote as BlockQuote:
            return visitBlockQuote(blockQuote)
        case let listItem as ListItem:
            return visitListItem(listItem)
        case let unorderedList as UnorderedList:
            return visitUnorderedList(unorderedList)
        case let orderedList as OrderedList:
            return visitOrderedList(orderedList)
        case let link as Link:
            return visitLink(link)
        default:
            var defaultText = NSMutableAttributedString()
            for child in markup.children {
                defaultText.append(visit(child))
            }
            return defaultText
        }
    }
    
    mutating func visitText(_ text: Markdown.Text) -> NSAttributedString {
        return NSAttributedString(
            string: text.string,
            attributes: [
                .foregroundColor: textColor,
                .font: baseFont
            ]
        )
    }
    
    mutating func visitEmphasis(_ emphasis: Emphasis) -> NSAttributedString {
        let italicFont = NSFontManager.shared.convert(baseFont, toHaveTrait: .italicFontMask) ?? baseFont
        var emphasisText = NSMutableAttributedString()
        for child in emphasis.children {
            let childText = visit(child)
            let mutableChild = NSMutableAttributedString(attributedString: childText)
            mutableChild.addAttribute(.font, value: italicFont, range: NSRange(location: 0, length: mutableChild.length))
            emphasisText.append(mutableChild)
        }
        return emphasisText
    }
    
    mutating func visitStrong(_ strong: Strong) -> NSAttributedString {
        let boldFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        var strongText = NSMutableAttributedString()
        for child in strong.children {
            let childText = visit(child)
            let mutableChild = NSMutableAttributedString(attributedString: childText)
            mutableChild.addAttribute(.font, value: boldFont, range: NSRange(location: 0, length: mutableChild.length))
            strongText.append(mutableChild)
        }
        return strongText
    }
    
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> NSAttributedString {
        let codeFont = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        return NSAttributedString(
            string: inlineCode.code,
            attributes: [
                .foregroundColor: textColor,
                .font: codeFont
            ]
        )
    }
    
    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> NSAttributedString {
        // Render soft breaks as line breaks to preserve line breaks in source
        return NSAttributedString(
            string: "\n",
            attributes: [
                .foregroundColor: textColor,
                .font: baseFont
            ]
        )
    }
    
    mutating func visitLineBreak(_ lineBreak: LineBreak) -> NSAttributedString {
        // Line breaks are hard breaks (two spaces + newline in markdown)
        return NSAttributedString(
            string: "\n",
            attributes: [
                .foregroundColor: textColor,
                .font: baseFont
            ]
        )
    }
    
    mutating func visitParagraph(_ paragraph: Paragraph) -> NSAttributedString {
        var paragraphText = NSMutableAttributedString()
        for child in paragraph.children {
            paragraphText.append(visit(child))
        }
        paragraphText.append(NSAttributedString(string: "\n"))
        return paragraphText
    }
    
    mutating func visitHeading(_ heading: Heading) -> NSAttributedString {
        let fontSize: CGFloat
        let weight: NSFont.Weight
        switch heading.level {
        case 1:
            fontSize = NSFont.systemFontSize * 1.8
            weight = .bold
        case 2:
            fontSize = NSFont.systemFontSize * 1.5
            weight = .bold
        case 3:
            fontSize = NSFont.systemFontSize * 1.3
            weight = .semibold
        case 4:
            fontSize = NSFont.systemFontSize * 1.1
            weight = .semibold
        case 5:
            fontSize = NSFont.systemFontSize
            weight = .medium
        default:
            fontSize = NSFont.systemFontSize
            weight = .medium
        }
        
        let headingFont = NSFont.systemFont(ofSize: fontSize, weight: weight)
        var headingText = NSMutableAttributedString()
        
        for child in heading.children {
            let childText = visit(child)
            let mutableChild = NSMutableAttributedString(attributedString: childText)
            mutableChild.addAttribute(.font, value: headingFont, range: NSRange(location: 0, length: mutableChild.length))
            headingText.append(mutableChild)
        }
        headingText.append(NSAttributedString(string: "\n"))
        return headingText
    }
    
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> NSAttributedString {
        let codeFont = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        let attributedText = NSMutableAttributedString(
            string: codeBlock.code,
            attributes: [
                .foregroundColor: textColor,
                .font: codeFont
            ]
        )
        attributedText.append(NSAttributedString(string: "\n\n"))
        return attributedText
    }
    
    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> NSAttributedString {
        var quoteText = NSMutableAttributedString()
        for child in blockQuote.children {
            quoteText.append(visit(child))
        }
        return quoteText
    }
    
    mutating func visitListItem(_ listItem: ListItem) -> NSAttributedString {
        var itemText = NSMutableAttributedString(string: "• ")
        for child in listItem.children {
            itemText.append(visit(child))
        }
        itemText.append(NSAttributedString(string: "\n"))
        return itemText
    }
    
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> NSAttributedString {
        var listText = NSMutableAttributedString()
        for child in unorderedList.children {
            listText.append(visit(child))
        }
        listText.append(NSAttributedString(string: "\n"))
        return listText
    }
    
    mutating func visitOrderedList(_ orderedList: OrderedList) -> NSAttributedString {
        var listText = NSMutableAttributedString()
        var index = 1
        for child in orderedList.children {
            if let listItem = child as? ListItem {
                listText.append(NSAttributedString(string: "\(index). "))
                // Visit children directly to avoid adding bullet point
                for itemChild in listItem.children {
                    listText.append(visit(itemChild))
                }
                listText.append(NSAttributedString(string: "\n"))
                index += 1
            }
        }
        listText.append(NSAttributedString(string: "\n"))
        return listText
    }
    
    mutating func visitLink(_ link: Link) -> NSAttributedString {
        var linkText = NSMutableAttributedString()
        for child in link.children {
            linkText.append(visit(child))
        }
        
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.systemBlue,
            .font: baseFont
        ]
        
        if let destination = link.destination, let url = URL(string: destination) {
            attributes[.link] = url
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        let fullRange = NSRange(location: 0, length: linkText.length)
        linkText.addAttributes(attributes, range: fullRange)
        return linkText
    }
}
