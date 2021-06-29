//
//  Copyright © 2020 Rosberry. All rights reserved.
//

final class ContentProvider {
    var contents: [Content] = [ImageContent(id: 0,
                                            image: #imageLiteral(resourceName: "nightlife-1"),
                                            description: "First image description. First image description. First image description.\n First image description. First image description. First image description. First image description."),
                               TextContent(id: 5,
                                           text: "Fist topic",
                                           description: "First topic description"),
                               TextContent(id: 6,
                                           text: "Second topic",
                                           description: "Second topic description"),
                               ImageContent(id: 1,
                                            image: #imageLiteral(resourceName: "nightlife-2"),
                                            description: "Second image description"),
                               TextContent(id: 7,
                                           text: "Third topic",
                                           description: "Third topic description"),
                               ImageContent(id: 2,
                                            image: #imageLiteral(resourceName: "nightlife-3"),
                                            description: "Third image description"),
                               ImageContent(id: 3,
                                            image: #imageLiteral(resourceName: "nightlife-4"),
                                            description: "Fourth image description"),
                               TextContent(id: 8,
                                           text: "Fourth topic",
                                           description: "Fourth topic description"),
                               TextContent(id: 9,
                                           text: "Fifth topic",
                                           description: "Fifth topic description"),
                               ImageContent(id: 4,
                                            image: #imageLiteral(resourceName: "nightlife-5"),
                                            description: "Fifth image description")]
}
