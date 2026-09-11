// Generated from MobAI normalized Apple SDK IR.
// Module: FoundationModels
// Extracted SDK modules: FoundationModels
// This project copy is editable; catalog expansion only appends missing declarations.

import Foundation




// mobai-ir-declaration: ConvertibleFromGeneratedContent
public protocol ConvertibleFromGeneratedContent {
    init(_ value0: GeneratedContent) throws
}

private final class _MobAIConvertibleFromGeneratedContent: ConvertibleFromGeneratedContent {
    init() {}

    public init(_ value0: GeneratedContent) throws {}
}

// mobai-ir-declaration: ConvertibleToGeneratedContent
public protocol ConvertibleToGeneratedContent {

}

private final class _MobAIConvertibleToGeneratedContent: ConvertibleToGeneratedContent {
    init() {}
}

// mobai-ir-declaration: Generable
public protocol Generable {
    associatedtype PartiallyGenerated = Never
}

private final class _MobAIGenerable: Generable {
    init() {}

    typealias PartiallyGenerated = Never
}

// mobai-ir-declaration: GeneratedContent
public struct GeneratedContent: Hashable, ConvertibleFromGeneratedContent, ConvertibleToGeneratedContent, Generable, InstructionsRepresentable, PromptRepresentable {
    public init(_ value0: GeneratedContent) throws {}

    public func value<Value>(_ value0: Value.Type = .init()) throws -> Value where Value : ConvertibleFromGeneratedContent { fatalError("preview SDK mock has no inert value for Value") }

    public func value<Value>(_ value0: Value.Type = .init(), forProperty value1: String) throws -> Value where Value : ConvertibleFromGeneratedContent { fatalError("preview SDK mock has no inert value for Value") }

    public typealias PartiallyGenerated = Never
}

// mobai-ir-declaration: GenerationOptions
public struct GenerationOptions: Hashable {
    public var temperature: Double? { get { nil } set {} }

    public init(sampling value0: GenerationOptions.SamplingMode? = nil, temperature value1: Double? = nil, maximumResponseTokens value2: Int? = nil) {}

    public struct SamplingMode: Hashable {
        public init() {}
    
        public static var greedy: GenerationOptions.SamplingMode { fatalError("preview SDK mock has no inert value for GenerationOptions.SamplingMode") }
    
        public static func random(top value0: Int, seed value1: UInt64? = nil) -> GenerationOptions.SamplingMode { fatalError("preview SDK mock has no inert value for GenerationOptions.SamplingMode") }
    
        public static func random(probabilityThreshold value0: Double, seed value1: UInt64? = nil) -> GenerationOptions.SamplingMode { fatalError("preview SDK mock has no inert value for GenerationOptions.SamplingMode") }
    
        public static func ==(_ value0: GenerationOptions.SamplingMode, _ value1: GenerationOptions.SamplingMode) -> Bool { false }
    }
}

// mobai-ir-declaration: GenerationSchema
public struct GenerationSchema: Hashable {
    public init(from value0: any Decoder) throws {}
}

// mobai-ir-declaration: InstructionsRepresentable
public protocol InstructionsRepresentable {

}

private final class _MobAIInstructionsRepresentable: InstructionsRepresentable {
    init() {}
}

// mobai-ir-declaration: LanguageModelSession
public class LanguageModelSession {
    public init(model value0: SystemLanguageModel = .init(), tools value1: [any Tool] = [], instructions value2: String? = nil) {}

    public func prewarm(promptPrefix value0: Prompt? = nil) {}

    @discardableResult
    public func respond(to value0: Prompt, options value1: GenerationOptions = .init()) throws -> LanguageModelSession.Response<String> { fatalError("preview SDK mock has no inert value for LanguageModelSession.Response<String>") }

    @discardableResult
    public func respond(options value0: GenerationOptions = .init(), prompt value1: () throws -> Prompt) throws -> LanguageModelSession.Response<String> { fatalError("preview SDK mock has no inert value for LanguageModelSession.Response<String>") }

    @discardableResult
    public func respond(to value0: Prompt, schema value1: GenerationSchema, includeSchemaInPrompt value2: Bool = false, options value3: GenerationOptions = .init()) throws -> LanguageModelSession.Response<GeneratedContent> { fatalError("preview SDK mock has no inert value for LanguageModelSession.Response<GeneratedContent>") }

    @discardableResult
    public func respond(schema value0: GenerationSchema, includeSchemaInPrompt value1: Bool = false, options value2: GenerationOptions = .init(), prompt value3: () throws -> Prompt) throws -> LanguageModelSession.Response<GeneratedContent> { fatalError("preview SDK mock has no inert value for LanguageModelSession.Response<GeneratedContent>") }

    @discardableResult
    public func respond<Content>(to value0: Prompt, generating value1: Content.Type = .init(), includeSchemaInPrompt value2: Bool = false, options value3: GenerationOptions = .init()) throws -> LanguageModelSession.Response<Content> where Content : Generable { fatalError("preview SDK mock has no inert value for LanguageModelSession.Response<Content>") }

    @discardableResult
    public func respond<Content>(generating value0: Content.Type = .init(), includeSchemaInPrompt value1: Bool = false, options value2: GenerationOptions = .init(), prompt value3: () throws -> Prompt) throws -> LanguageModelSession.Response<Content> where Content : Generable { fatalError("preview SDK mock has no inert value for LanguageModelSession.Response<Content>") }

    public func streamResponse(to value0: Prompt, schema value1: GenerationSchema, includeSchemaInPrompt value2: Bool = false, options value3: GenerationOptions = .init()) -> LanguageModelSession.ResponseStream<GeneratedContent> { fatalError("preview SDK mock has no inert value for LanguageModelSession.ResponseStream<GeneratedContent>") }

    public struct ResponseStream<Content>: Hashable {
        public struct Snapshot<Content>: Hashable {
            public var content: Content.PartiallyGenerated { get { fatalError("preview SDK mock has no inert value for Content.PartiallyGenerated") } set {} }
        
            public var rawContent: GeneratedContent { get { fatalError("preview SDK mock has no inert value for GeneratedContent") } set {} }
        }
    
        public typealias Element = LanguageModelSession.ResponseStream<Content>.Snapshot
    
        public struct AsyncIterator<Content>: Hashable {
            public func next(isolation value0: (any _Concurrency.Actor)? = nil) throws -> LanguageModelSession.ResponseStream<Content>.Snapshot? where Content : Generable { nil }
        
            public typealias Element = LanguageModelSession.ResponseStream<Content>.Snapshot
        }
    
        public func makeAsyncIterator() -> LanguageModelSession.ResponseStream<Content>.AsyncIterator where Content : Generable { fatalError("preview SDK mock has no inert value for LanguageModelSession.ResponseStream<Content>.AsyncIterator") }
    
        public func collect() throws -> LanguageModelSession.Response<Content> where Content : Generable { fatalError("preview SDK mock has no inert value for LanguageModelSession.Response<Content>") }
    }

    public func streamResponse(schema value0: GenerationSchema, includeSchemaInPrompt value1: Bool = false, options value2: GenerationOptions = .init(), prompt value3: () throws -> Prompt) throws -> LanguageModelSession.ResponseStream<GeneratedContent> { fatalError("preview SDK mock has no inert value for LanguageModelSession.ResponseStream<GeneratedContent>") }

    public func streamResponse<Content>(to value0: Prompt, generating value1: Content.Type = .init(), includeSchemaInPrompt value2: Bool = false, options value3: GenerationOptions = .init()) -> LanguageModelSession.ResponseStream<Content> where Content : Generable { fatalError("preview SDK mock has no inert value for LanguageModelSession.ResponseStream<Content>") }

    public func streamResponse<Content>(generating value0: Content.Type = .init(), includeSchemaInPrompt value1: Bool = false, options value2: GenerationOptions = .init(), prompt value3: () throws -> Prompt) throws -> LanguageModelSession.ResponseStream<Content> where Content : Generable { fatalError("preview SDK mock has no inert value for LanguageModelSession.ResponseStream<Content>") }

    public func streamResponse(to value0: Prompt, options value1: GenerationOptions = .init()) -> LanguageModelSession.ResponseStream<String> { fatalError("preview SDK mock has no inert value for LanguageModelSession.ResponseStream<String>") }

    public func streamResponse(options value0: GenerationOptions = .init(), prompt value1: () throws -> Prompt) throws -> LanguageModelSession.ResponseStream<String> { fatalError("preview SDK mock has no inert value for LanguageModelSession.ResponseStream<String>") }

    public struct Response<Content>: Hashable {
        public var content: Content { fatalError("preview SDK mock has no inert value for Content") }
    
        public var rawContent: GeneratedContent { fatalError("preview SDK mock has no inert value for GeneratedContent") }
    
        public var transcriptEntries: ArraySlice<Transcript.Entry> { fatalError("preview SDK mock has no inert value for ArraySlice<Transcript.Entry>") }
    }
}

extension LanguageModelSession: Swift.Equatable, Swift.Hashable {
    public static func == (l: LanguageModelSession, r: LanguageModelSession) -> Bool { l === r }
    public func hash(into hasher: inout Swift.Hasher) {
        hasher.combine(Swift.ObjectIdentifier(self))
    }
}

// mobai-ir-declaration: Prompt
public struct Prompt: Hashable, PromptRepresentable {
    public init(_ value0: some PromptRepresentable) {}
}

// mobai-ir-declaration: PromptRepresentable
public protocol PromptRepresentable {

}

private final class _MobAIPromptRepresentable: PromptRepresentable {
    init() {}
}

// mobai-ir-declaration: SystemLanguageModel
public class SystemLanguageModel {
    public var isAvailable: Bool { false }

    public static var `default`: SystemLanguageModel { fatalError("preview SDK mock has no inert value for SystemLanguageModel") }

    public init(useCase value0: SystemLanguageModel.UseCase = .init(), guardrails value1: SystemLanguageModel.Guardrails = .init()) {}

    public struct UseCase: Hashable {
        public init() {}
    
        public static var general: SystemLanguageModel.UseCase { fatalError("preview SDK mock has no inert value for SystemLanguageModel.UseCase") }
    
        public static var contentTagging: SystemLanguageModel.UseCase { fatalError("preview SDK mock has no inert value for SystemLanguageModel.UseCase") }
    
        public static func ==(_ value0: SystemLanguageModel.UseCase, _ value1: SystemLanguageModel.UseCase) -> Bool { false }
    }

    public struct Guardrails: Hashable {
        public init() {}
    
        public static var `default`: SystemLanguageModel.Guardrails { fatalError("preview SDK mock has no inert value for SystemLanguageModel.Guardrails") }
    
        public static var permissiveContentTransformations: SystemLanguageModel.Guardrails { fatalError("preview SDK mock has no inert value for SystemLanguageModel.Guardrails") }
    }
}

extension SystemLanguageModel: Swift.Equatable, Swift.Hashable {
    public static func == (l: SystemLanguageModel, r: SystemLanguageModel) -> Bool { l === r }
    public func hash(into hasher: inout Swift.Hasher) {
        hasher.combine(Swift.ObjectIdentifier(self))
    }
}

// mobai-ir-declaration: Tool
public protocol Tool {
    associatedtype Arguments = Never

    associatedtype Output = Never

    var description: String { get }
}

private final class _MobAITool: Tool {
    init() {}

    typealias Arguments = Never

    typealias Output = Never

    public var description: String { "" }
}

extension Tool {
    public var description: String { "" }
}

// mobai-ir-declaration: Transcript
public struct Transcript: Hashable {
    public init(entries value0: some Sequence<Transcript.Entry> = .init()) {}

    public init(from value0: any Decoder) throws {}

    public enum Entry {
        public var instructions: (Transcript.Entry.Type) -> (Transcript.Instructions) -> Transcript.Entry { fatalError("preview SDK mock has no inert value for (Transcript.Entry.Type) -> (Transcript.Instructions) -> Transcript.Entry") }
    
        public var prompt: (Transcript.Entry.Type) -> (Transcript.Prompt) -> Transcript.Entry { fatalError("preview SDK mock has no inert value for (Transcript.Entry.Type) -> (Transcript.Prompt) -> Transcript.Entry") }
    
        public var toolCalls: (Transcript.Entry.Type) -> (Transcript.ToolCalls) -> Transcript.Entry { fatalError("preview SDK mock has no inert value for (Transcript.Entry.Type) -> (Transcript.ToolCalls) -> Transcript.Entry") }
    
        public var toolOutput: (Transcript.Entry.Type) -> (Transcript.ToolOutput) -> Transcript.Entry { fatalError("preview SDK mock has no inert value for (Transcript.Entry.Type) -> (Transcript.ToolOutput) -> Transcript.Entry") }
    
        public var response: (Transcript.Entry.Type) -> (Transcript.Response) -> Transcript.Entry { fatalError("preview SDK mock has no inert value for (Transcript.Entry.Type) -> (Transcript.Response) -> Transcript.Entry") }
    
        public var id: String { "" }
    
        public static func ==(_ value0: Transcript.Entry, _ value1: Transcript.Entry) -> Bool { false }
    
        public typealias ID = String
    
        public var description: String { "" }
    }

    public struct Instructions: Hashable {
        public var id: String { get { "" } set {} }
    
        public var segments: [Transcript.Segment] { get { [] } set {} }
    
        public var toolDefinitions: [Transcript.ToolDefinition] { get { [] } set {} }
    
        public init(id value0: String = "", segments value1: [Transcript.Segment], toolDefinitions value2: [Transcript.ToolDefinition]) {}
    
        public static func ==(_ value0: Transcript.Instructions, _ value1: Transcript.Instructions) -> Bool { false }
    
        public typealias ID = String
    
        public var description: String { "" }
    }

    public struct ToolDefinition: Hashable {
        public var name: String { get { "" } set {} }
    
        public var description: String { get { "" } set {} }
    
        public init(name value0: String, description value1: String, parameters value2: GenerationSchema) {}
    
        public init(tool value0: some Tool) {}
    
        public static func ==(_ value0: Transcript.ToolDefinition, _ value1: Transcript.ToolDefinition) -> Bool { false }
    }

    public struct Prompt: Hashable {
        public var id: String { get { "" } set {} }
    
        public var segments: [Transcript.Segment] { get { [] } set {} }
    
        public var options: GenerationOptions { get { fatalError("preview SDK mock has no inert value for GenerationOptions") } set {} }
    
        public var responseFormat: Transcript.ResponseFormat? { get { nil } set {} }
    
        public init(id value0: String = "", segments value1: [Transcript.Segment], options value2: GenerationOptions = .init(), responseFormat value3: Transcript.ResponseFormat? = nil) {}
    
        public static func ==(_ value0: Transcript.Prompt, _ value1: Transcript.Prompt) -> Bool { false }
    
        public typealias ID = String
    
        public var description: String { "" }
    }

    public struct ResponseFormat: Hashable {
        public var name: String { "" }
    
        public init<Content>(type value0: Content.Type) where Content : Generable {}
    
        public init(schema value0: GenerationSchema) {}
    
        public static func ==(_ value0: Transcript.ResponseFormat, _ value1: Transcript.ResponseFormat) -> Bool { false }
    
        public var description: String { "" }
    }

    public struct ToolCalls: Hashable {
        public var id: String { get { "" } set {} }
    
        public init<S>(id value0: String = "", _ value1: S) where S : Sequence, S.Element == Transcript.ToolCall {}
    
        public var startIndex: Int { 0 }
    
        public var endIndex: Int { 0 }
    
        public static func ==(_ value0: Transcript.ToolCalls, _ value1: Transcript.ToolCalls) -> Bool { false }
    
        public typealias Element = Transcript.ToolCall
    
        public typealias ID = String
    
        public typealias Index = Int
    
        public typealias Indices = Range<Int>
    
        public typealias Iterator = IndexingIterator<Transcript.ToolCalls>
    
        public typealias SubSequence = Slice<Transcript.ToolCalls>
    
        public var description: String { "" }
    }

    public struct ToolCall: Hashable {
        public var id: String { get { "" } set {} }
    
        public var toolName: String { get { "" } set {} }
    
        public var arguments: GeneratedContent { get { fatalError("preview SDK mock has no inert value for GeneratedContent") } set {} }
    
        public init(id value0: String, toolName value1: String, arguments value2: GeneratedContent) {}
    
        public static func ==(_ value0: Transcript.ToolCall, _ value1: Transcript.ToolCall) -> Bool { false }
    
        public typealias ID = String
    
        public var description: String { "" }
    }

    public struct ToolOutput: Hashable {
        public var id: String { get { "" } set {} }
    
        public var toolName: String { get { "" } set {} }
    
        public var segments: [Transcript.Segment] { get { [] } set {} }
    
        public init(id value0: String, toolName value1: String, segments value2: [Transcript.Segment]) {}
    
        public static func ==(_ value0: Transcript.ToolOutput, _ value1: Transcript.ToolOutput) -> Bool { false }
    
        public typealias ID = String
    
        public var description: String { "" }
    }

    public struct Response: Hashable {
        public var id: String { get { "" } set {} }
    
        public var assetIDs: [String] { get { [] } set {} }
    
        public var segments: [Transcript.Segment] { get { [] } set {} }
    
        public init(id value0: String = "", assetIDs value1: [String], segments value2: [Transcript.Segment]) {}
    
        public static func ==(_ value0: Transcript.Response, _ value1: Transcript.Response) -> Bool { false }
    
        public typealias ID = String
    
        public var description: String { "" }
    }

    public enum Segment {
        public var text: (Transcript.Segment.Type) -> (Transcript.TextSegment) -> Transcript.Segment { fatalError("preview SDK mock has no inert value for (Transcript.Segment.Type) -> (Transcript.TextSegment) -> Transcript.Segment") }
    
        public var structure: (Transcript.Segment.Type) -> (Transcript.StructuredSegment) -> Transcript.Segment { fatalError("preview SDK mock has no inert value for (Transcript.Segment.Type) -> (Transcript.StructuredSegment) -> Transcript.Segment") }
    
        public var id: String { "" }
    
        public static func ==(_ value0: Transcript.Segment, _ value1: Transcript.Segment) -> Bool { false }
    
        public typealias ID = String
    
        public var description: String { "" }
    }

    public struct TextSegment: Hashable {
        public var id: String { get { "" } set {} }
    
        public var content: String { get { "" } set {} }
    
        public init(id value0: String = "", content value1: String) {}
    
        public static func ==(_ value0: Transcript.TextSegment, _ value1: Transcript.TextSegment) -> Bool { false }
    
        public typealias ID = String
    
        public var description: String { "" }
    }

    public struct StructuredSegment: Hashable {
        public var id: String { get { "" } set {} }
    
        public var source: String { get { "" } set {} }
    
        public var content: GeneratedContent { get { fatalError("preview SDK mock has no inert value for GeneratedContent") } set {} }
    
        public init(id value0: String = "", source value1: String, content value2: GeneratedContent) {}
    
        public static func ==(_ value0: Transcript.StructuredSegment, _ value1: Transcript.StructuredSegment) -> Bool { false }
    
        public typealias ID = String
    
        public var description: String { "" }
    }
}
