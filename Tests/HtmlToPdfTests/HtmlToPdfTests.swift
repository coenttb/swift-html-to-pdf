//
//  HtmlToPdfTests.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2024.
//

import Foundation
import HtmlToPdf
import Testing

let htmlString2 = """
<html>
    <body>
        <h1>Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World!</h1>
    </body>
</html>
"""

let htmlString = """
<html>
    <body>
        <h1>Hello, World!</h1>
        <h2>Hello, World! subheader</h2>
        <p>Sed euismod, nunc vel mollis interdum, mi nulla vehicula urna, a gravida tellus ante nec velit. Nunc sed lectus vehicula, pulvinar ante a, hendrerit arcu. Nulla turpis urna, luctus at sagittis non, dignissim vitae ligula. Nam nec venenatis enim. Aenean ut nibh id erat faucibus tincidunt. Etiam eu magna ac purus consequat dignissim vel ac ipsum. Maecenas at luctus odio. Maecenas facilisis eleifend tempor. Quisque mi lorem, aliquam vitae vulputate faucibus, pharetra id mauris. Proin molestie lacus sit amet faucibus dapibus. Sed nibh dui, vehicula sed leo ut, blandit tempus ipsum. Nullam bibendum molestie dapibus. In hac habitasse platea dictumst.</p>
        <p>Aenean vulputate nulla dolor, vitae tempor felis egestas ut. Praesent faucibus sagittis dictum. Nam scelerisque lacinia accumsan. Nam ultricies urna sit amet vulputate faucibus. Proin iaculis magna et augue sagittis, a posuere lacus rutrum. Sed faucibus nulla a libero ultricies fermentum. Pellentesque malesuada sem pulvinar rutrum efficitur. Vivamus mattis condimentum nulla, id consequat arcu tincidunt at. Nunc pharetra molestie purus, ut blandit velit semper a. Integer scelerisque, ipsum et accumsan condimentum, nibh nulla viverra elit, at suscipit quam mauris et massa. Maecenas tempor urna efficitur diam molestie, vitae eleifend tellus aliquam. Phasellus eros ex, rutrum quis felis vel, egestas condimentum ligula. Donec a arcu eget lacus laoreet pharetra.</p>
        <p>Praesent id lorem eleifend risus vestibulum tristique. Donec tristique pretium arcu et finibus. Fusce eget tellus pretium, pellentesque neque facilisis, fringilla augue. Praesent bibendum, purus dictum posuere interdum, enim sapien elementum augue, consectetur porta tellus nulla at dui. Etiam nec elit a ligula iaculis ultrices. Phasellus vulputate varius turpis, quis interdum tortor posuere id. Proin eu lorem sagittis, aliquet nisi ut, blandit ligula. Vestibulum vel ultrices magna. In est sapien, ultricies in mauris et, egestas laoreet orci. Praesent ornare ante sollicitudin pretium consectetur. Sed nec nisi enim. Vestibulum sodales est eu vestibulum venenatis.</p>
        <p>Nulla sagittis augue vel purus posuere egestas. Donec lacinia metus sit amet nulla tincidunt, eu consequat mi facilisis. Suspendisse mollis magna ut mauris interdum tincidunt. Vivamus non justo nec elit hendrerit maximus. Maecenas sollicitudin tincidunt mauris. Praesent quis velit quis justo pharetra rhoncus a et metus. Donec nec luctus libero. Cras sapien ipsum, pharetra id massa sed, rhoncus sagittis erat. Nam eu urna eget massa commodo tempor tincidunt nec velit. Duis bibendum cursus magna, nec iaculis turpis dapibus fringilla. Pellentesque et suscipit dolor. Praesent ac lectus quis dolor vestibulum lobortis vitae vestibulum leo. In at risus ut urna convallis dignissim. Proin vel magna vulputate, posuere augue at, ornare sapien.</p>
        <p>Sed euismod, nunc vel mollis interdum, mi nulla vehicula urna, a gravida tellus ante nec velit. Nunc sed lectus vehicula, pulvinar ante a, hendrerit arcu. Nulla turpis urna, luctus at sagittis non, dignissim vitae ligula. Nam nec venenatis enim. Aenean ut nibh id erat faucibus tincidunt. Etiam eu magna ac purus consequat dignissim vel ac ipsum. Maecenas at luctus odio. Maecenas facilisis eleifend tempor. Quisque mi lorem, aliquam vitae vulputate faucibus, pharetra id mauris. Proin molestie lacus sit amet faucibus dapibus. Sed nibh dui, vehicula sed leo ut, blandit tempus ipsum. Nullam bibendum molestie dapibus. In hac habitasse platea dictumst.</p>
        <p>Aenean vulputate nulla dolor, vitae tempor felis egestas ut. Praesent faucibus sagittis dictum. Nam scelerisque lacinia accumsan. Nam ultricies urna sit amet vulputate faucibus. Proin iaculis magna et augue sagittis, a posuere lacus rutrum. Sed faucibus nulla a libero ultricies fermentum. Pellentesque malesuada sem pulvinar rutrum efficitur. Vivamus mattis condimentum nulla, id consequat arcu tincidunt at. Nunc pharetra molestie purus, ut blandit velit semper a. Integer scelerisque, ipsum et accumsan condimentum, nibh nulla viverra elit, at suscipit quam mauris et massa. Maecenas tempor urna efficitur diam molestie, vitae eleifend tellus aliquam. Phasellus eros ex, rutrum quis felis vel, egestas condimentum ligula. Donec a arcu eget lacus laoreet pharetra.</p>
        <p>Praesent id lorem eleifend risus vestibulum tristique. Donec tristique pretium arcu et finibus. Fusce eget tellus pretium, pellentesque neque facilisis, fringilla augue. Praesent bibendum, purus dictum posuere interdum, enim sapien elementum augue, consectetur porta tellus nulla at dui. Etiam nec elit a ligula iaculis ultrices. Phasellus vulputate varius turpis, quis interdum tortor posuere id. Proin eu lorem sagittis, aliquet nisi ut, blandit ligula. Vestibulum vel ultrices magna. In est sapien, ultricies in mauris et, egestas laoreet orci. Praesent ornare ante sollicitudin pretium consectetur. Sed nec nisi enim. Vestibulum sodales est eu vestibulum venenatis.</p>
        <p>Nulla sagittis augue vel purus posuere egestas. Donec lacinia metus sit amet nulla tincidunt, eu consequat mi facilisis. Suspendisse mollis magna ut mauris interdum tincidunt. Vivamus non justo nec elit hendrerit maximus. Maecenas sollicitudin tincidunt mauris. Praesent quis velit quis justo pharetra rhoncus a et metus. Donec nec luctus libero. Cras sapien ipsum, pharetra id massa sed, rhoncus sagittis erat. Nam eu urna eget massa commodo tempor tincidunt nec velit. Duis bibendum cursus magna, nec iaculis turpis dapibus fringilla. Pellentesque et suscipit dolor. Praesent ac lectus quis dolor vestibulum lobortis vitae vestibulum leo. In at risus ut urna convallis dignissim. Proin vel magna vulputate, posuere augue at, ornare sapien.</p>
        <p>Sed euismod, nunc vel mollis interdum, mi nulla vehicula urna, a gravida tellus ante nec velit. Nunc sed lectus vehicula, pulvinar ante a, hendrerit arcu. Nulla turpis urna, luctus at sagittis non, dignissim vitae ligula. Nam nec venenatis enim. Aenean ut nibh id erat faucibus tincidunt. Etiam eu magna ac purus consequat dignissim vel ac ipsum. Maecenas at luctus odio. Maecenas facilisis eleifend tempor. Quisque mi lorem, aliquam vitae vulputate faucibus, pharetra id mauris. Proin molestie lacus sit amet faucibus dapibus. Sed nibh dui, vehicula sed leo ut, blandit tempus ipsum. Nullam bibendum molestie dapibus. In hac habitasse platea dictumst.</p>
        <p>Aenean vulputate nulla dolor, vitae tempor felis egestas ut. Praesent faucibus sagittis dictum. Nam scelerisque lacinia accumsan. Nam ultricies urna sit amet vulputate faucibus. Proin iaculis magna et augue sagittis, a posuere lacus rutrum. Sed faucibus nulla a libero ultricies fermentum. Pellentesque malesuada sem pulvinar rutrum efficitur. Vivamus mattis condimentum nulla, id consequat arcu tincidunt at. Nunc pharetra molestie purus, ut blandit velit semper a. Integer scelerisque, ipsum et accumsan condimentum, nibh nulla viverra elit, at suscipit quam mauris et massa. Maecenas tempor urna efficitur diam molestie, vitae eleifend tellus aliquam. Phasellus eros ex, rutrum quis felis vel, egestas condimentum ligula. Donec a arcu eget lacus laoreet pharetra.</p>
        <p>Praesent id lorem eleifend risus vestibulum tristique. Donec tristique pretium arcu et finibus. Fusce eget tellus pretium, pellentesque neque facilisis, fringilla augue. Praesent bibendum, purus dictum posuere interdum, enim sapien elementum augue, consectetur porta tellus nulla at dui. Etiam nec elit a ligula iaculis ultrices. Phasellus vulputate varius turpis, quis interdum tortor posuere id. Proin eu lorem sagittis, aliquet nisi ut, blandit ligula. Vestibulum vel ultrices magna. In est sapien, ultricies in mauris et, egestas laoreet orci. Praesent ornare ante sollicitudin pretium consectetur. Sed nec nisi enim. Vestibulum sodales est eu vestibulum venenatis.</p>
        <p>Nulla sagittis augue vel purus posuere egestas. Donec lacinia metus sit amet nulla tincidunt, eu consequat mi facilisis. Suspendisse mollis magna ut mauris interdum tincidunt. Vivamus non justo nec elit hendrerit maximus. Maecenas sollicitudin tincidunt mauris. Praesent quis velit quis justo pharetra rhoncus a et metus. Donec nec luctus libero. Cras sapien ipsum, pharetra id massa sed, rhoncus sagittis erat. Nam eu urna eget massa commodo tempor tincidunt nec velit. Duis bibendum cursus magna, nec iaculis turpis dapibus fringilla. Pellentesque et suscipit dolor. Praesent ac lectus quis dolor vestibulum lobortis vitae vestibulum leo. In at risus ut urna convallis dignissim. Proin vel magna vulputate, posuere augue at, ornare sapien.</p>
        <p>Sed euismod, nunc vel mollis interdum, mi nulla vehicula urna, a gravida tellus ante nec velit. Nunc sed lectus vehicula, pulvinar ante a, hendrerit arcu. Nulla turpis urna, luctus at sagittis non, dignissim vitae ligula. Nam nec venenatis enim. Aenean ut nibh id erat faucibus tincidunt. Etiam eu magna ac purus consequat dignissim vel ac ipsum. Maecenas at luctus odio. Maecenas facilisis eleifend tempor. Quisque mi lorem, aliquam vitae vulputate faucibus, pharetra id mauris. Proin molestie lacus sit amet faucibus dapibus. Sed nibh dui, vehicula sed leo ut, blandit tempus ipsum. Nullam bibendum molestie dapibus. In hac habitasse platea dictumst.</p>
        <p>Aenean vulputate nulla dolor, vitae tempor felis egestas ut. Praesent faucibus sagittis dictum. Nam scelerisque lacinia accumsan. Nam ultricies urna sit amet vulputate faucibus. Proin iaculis magna et augue sagittis, a posuere lacus rutrum. Sed faucibus nulla a libero ultricies fermentum. Pellentesque malesuada sem pulvinar rutrum efficitur. Vivamus mattis condimentum nulla, id consequat arcu tincidunt at. Nunc pharetra molestie purus, ut blandit velit semper a. Integer scelerisque, ipsum et accumsan condimentum, nibh nulla viverra elit, at suscipit quam mauris et massa. Maecenas tempor urna efficitur diam molestie, vitae eleifend tellus aliquam. Phasellus eros ex, rutrum quis felis vel, egestas condimentum ligula. Donec a arcu eget lacus laoreet pharetra.</p>
        <p>Praesent id lorem eleifend risus vestibulum tristique. Donec tristique pretium arcu et finibus. Fusce eget tellus pretium, pellentesque neque facilisis, fringilla augue. Praesent bibendum, purus dictum posuere interdum, enim sapien elementum augue, consectetur porta tellus nulla at dui. Etiam nec elit a ligula iaculis ultrices. Phasellus vulputate varius turpis, quis interdum tortor posuere id. Proin eu lorem sagittis, aliquet nisi ut, blandit ligula. Vestibulum vel ultrices magna. In est sapien, ultricies in mauris et, egestas laoreet orci. Praesent ornare ante sollicitudin pretium consectetur. Sed nec nisi enim. Vestibulum sodales est eu vestibulum venenatis.</p>
        <p>Nulla sagittis augue vel purus posuere egestas. Donec lacinia metus sit amet nulla tincidunt, eu consequat mi facilisis. Suspendisse mollis magna ut mauris interdum tincidunt. Vivamus non justo nec elit hendrerit maximus. Maecenas sollicitudin tincidunt mauris. Praesent quis velit quis justo pharetra rhoncus a et metus. Donec nec luctus libero. Cras sapien ipsum, pharetra id massa sed, rhoncus sagittis erat. Nam eu urna eget massa commodo tempor tincidunt nec velit. Duis bibendum cursus magna, nec iaculis turpis dapibus fringilla. Pellentesque et suscipit dolor. Praesent ac lectus quis dolor vestibulum lobortis vitae vestibulum leo. In at risus ut urna convallis dignissim. Proin vel magna vulputate, posuere augue at, ornare sapien.</p>
        <p>Sed euismod, nunc vel mollis interdum, mi nulla vehicula urna, a gravida tellus ante nec velit. Nunc sed lectus vehicula, pulvinar ante a, hendrerit arcu. Nulla turpis urna, luctus at sagittis non, dignissim vitae ligula. Nam nec venenatis enim. Aenean ut nibh id erat faucibus tincidunt. Etiam eu magna ac purus consequat dignissim vel ac ipsum. Maecenas at luctus odio. Maecenas facilisis eleifend tempor. Quisque mi lorem, aliquam vitae vulputate faucibus, pharetra id mauris. Proin molestie lacus sit amet faucibus dapibus. Sed nibh dui, vehicula sed leo ut, blandit tempus ipsum. Nullam bibendum molestie dapibus. In hac habitasse platea dictumst.</p>
        <p>Aenean vulputate nulla dolor, vitae tempor felis egestas ut. Praesent faucibus sagittis dictum. Nam scelerisque lacinia accumsan. Nam ultricies urna sit amet vulputate faucibus. Proin iaculis magna et augue sagittis, a posuere lacus rutrum. Sed faucibus nulla a libero ultricies fermentum. Pellentesque malesuada sem pulvinar rutrum efficitur. Vivamus mattis condimentum nulla, id consequat arcu tincidunt at. Nunc pharetra molestie purus, ut blandit velit semper a. Integer scelerisque, ipsum et accumsan condimentum, nibh nulla viverra elit, at suscipit quam mauris et massa. Maecenas tempor urna efficitur diam molestie, vitae eleifend tellus aliquam. Phasellus eros ex, rutrum quis felis vel, egestas condimentum ligula. Donec a arcu eget lacus laoreet pharetra.</p>
    </body>
</html>
"""

@Suite("Temporary", .disabled())
struct TemporaryDirectory {
    
    @Test func single() async throws {
        
        let id = UUID()
        let output = URL.output(id: id).appendingPathComponent(id.uuidString).appendingPathExtension("pdf")
        
        
        try await htmlString.print(to: output)
        
        #expect(FileManager.default.fileExists(atPath: output.path))
        
        try FileManager.default.removeItems(at: output.deletingPathExtension().deletingLastPathComponent())
    }
    
    @Test func collection() async throws {
        
        let count = 100
        let output = URL.output()
        
        try output.createDirectories()
        
        try await [String].init(repeating: htmlString, count: count)
            .print(to: output)
        
        let contents_after = try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
        
        #expect(contents_after.count == count)
        
        try FileManager.default.removeItems(at: output)
    }
    
    @Test func collection_2() async throws {
        let count = 10
        
        let output = URL.output()
        
        try output.createDirectories()
        
        try await [String].init(repeating: htmlString, count: count)
            .print(
                to: output,
                configuration: .a4,
                filename: { _ in UUID().uuidString }
            )
        
        try await [String].init(repeating: htmlString, count: count)
            .print(
                to: output,
                filename: { _ in UUID().uuidString }
            )
        
        try await htmlString.print(
            title: UUID().uuidString,
            to: output,
            configuration: .a4
        )
        
        let contents_after = try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
        
        #expect(contents_after.count == (count * 2) + 1 )
        
        try FileManager.default.removeItems(at: output)
    }
    
    @Test func collection_3() async throws {
        
        let output = URL.output()
        
        try output.createDirectories()
        
        let documents = [
            Document(
                url: output.appendingPathComponent("file1").appendingPathExtension("pdf"),
                html: htmlString
            ),
            Document(
                url: output.appendingPathComponent("file2").appendingPathExtension("pdf"),
                html: htmlString
            ),
            Document(
                url: output.appendingPathComponent("file3").appendingPathExtension("pdf"),
                html: htmlString
            ),
            Document(
                url: output.appendingPathComponent("file4").appendingPathExtension("pdf"),
                html: htmlString
            ),
            Document(
                url: output.appendingPathComponent("file5").appendingPathExtension("pdf"),
                html: htmlString
            ),
            Document(
                url: output.appendingPathComponent("file6").appendingPathExtension("pdf"),
                html: htmlString
            ),
        ]
        
        try await documents.print(
                to: output,
                configuration: .a4
            )
        
//        await [String].init(repeating: "<html><body><h1>Hello, World 2!</h1></body></html>", count: count)
//            .print(
//                to: output,
//                filename: { _ in UUID().uuidString }
//            )
//        
//        try await "<html><body><h1>Hello, World!</h1></body></html>".print(
//            title: UUID().uuidString,
//            to: output,
//            configuration: .a4
//        )
        
        let contents_after = try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
        
        #expect(contents_after.count == documents.count)
        
        try FileManager.default.removeItems(at: output)
    }
}
#if os(macOS)

@Suite("Local")
struct Local {
    
    let cleanup: Bool = false
    
    @Test func local_individual() async throws {
        let output = URL.localHtmlToPdf
        
        try await htmlString.print(title: "individual", to: output)
        
        #expect(FileManager.default.fileExists(atPath: output.path))
        
        if cleanup {
            try FileManager.default.removeItems(at: output)
        }
    }
    
    @Test func local_collection() async throws {
        let output = URL.localHtmlToPdf
        
        try await [String].init(repeating: htmlString, count: 10)
            .print(to: output)
        
        #expect(FileManager.default.fileExists(atPath: output.path))
        
        if cleanup {
            try FileManager.default.removeItems(at: output)
        }
    }
}
#endif
