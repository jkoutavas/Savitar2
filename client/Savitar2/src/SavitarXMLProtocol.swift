//
//  SavitarXMLProtocol.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/10/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation

/*
 * You may ask, "Why XML in this modern age? Why not do a PLIST or codable thing? Or use JSON?"
 * Answer: We stay away from Apple specific formats like PLIST and codable because we want the
 * world document to be easily readable from anywhere, any platform. True, in this modern age,
 * JSON would fit that requirement, but, there's something to be said about having some semblence
 * still with the v1 document's format, and it's not that hard to read and write XML. So: XML it is
 */
 
protocol SavitarXMLProtocol: XMLParserDelegate {
    /*
     * Parse XML from Savitar v1 or v2 data
     */
    func parseXML(from data: Data) throws

    /*
     * Produce Savitar v2 XML representation
     */
    func toXMLElement() throws -> XMLElement
}
