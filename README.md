# C# Coding Style

This document describes the preferred C# coding style in my projects. It is based on the [.NET Runtime Coding Style](https://github.com/dotnet/runtime/blob/main/docs/coding-guidelines/coding-style.md) with some targeted modifications to improve readability and maintainability of the codebases.

The goal of this document is to provide a modern and consistent coding style across the codebase, reducing boilerplate where possible, while considering the readability and maintainability of the code, especially for code reviews where no intellisense or other tool-assisted context is available. The fundamental principle is that the code should be easy to read and understand at a glance, without having to search for the type of a variable or method return type. Similarly, it should be clear to distinguish between constants, fields, properties, statics, and other types of members.

---

The general rule we follow is "use Visual Studio defaults" and "readability over convenience", since code is read more often than it is written. Still, we aim to reduce boilerplate where possible and eliminate redundancy in the codebase.

1. We use [Allman style](http://en.wikipedia.org/wiki/Indent_style#Allman_style) braces, where each brace begins on a new line. The only exceptions to this rule are auto-implemented properties (i.e. `public int Foo { get; set; }`), simple object initializers (i.e. `Person p = new() { Name = "John" };`), and empty bodied block statements (i.e. `() => {}`, or `for (node = first; node != null; node = node.Next) {}`).
2. We use four spaces of indentation (no tabs) to maintain visual consistency across different editors and platforms where tab width may vary.
3. We use `_camelCase` for internal and private fields and use `readonly` where possible. Prefix internal and private instance fields with `_`, static fields with `s_`, thread static fields with `t_`, and non-public thread-local fields with `_th_`. When used on static fields, `readonly` should come after `static` (e.g. `static readonly` not `readonly static`). Public fields should only be used in `structs` and only where they are advantageous over properties. Public fields should use PascalCasing with no prefix when used. The difference in naming convention between fields and properties helps us easily distinguish between the two, which is especially relevant when working with ByRefs (`ref`).
    - An exception to the `_camelCase` rule for private members are primary constructors, where we use normal camelCase, e.g. `public class Foo(int bar) { }`. For larger classes, we discourage the use of primary constructors and instead use the traditional constructor syntax and member names. This is to avoid confusion between private fields and locals.
4. We avoid `this.` unless absolutely necessary. Usage of `this.` when accessing primary constructor parameters for a clear distinction between fields and locals is encouraged.
5. We always specify the visibility, even if it's the default (e.g. `private string _foo` not `string _foo`). Visibility should be the first modifier (e.g. `public abstract` not `abstract public`).
6. Namespace imports should be specified at the top of the file, *outside* of `namespace` declarations, and should be sorted alphabetically. We use file-scoped namespaces (`namespace Foo;` instead of `namespace Foo {...}`) to avoid excessive indentation (see rule 1).
7. Avoid more than one empty line at any time. For example, do not have two blank lines between members of a type.
8. Avoid trailing free spaces. For example avoid `if (someVar == 0)...`, where the dots mark the spurious free spaces. Consider enabling "View White Space (Ctrl+R, Ctrl+W)" or "Edit -> Advanced -> View White Space" if using Visual Studio to aid detection.
9. File names should be named after the type they contain, for example `class Foo` should be in `Foo.cs`. Every file should contain at most one top-level type, although it may contain nested types and additional file-local type (e.g. `class Foo { class Bar { } }` and `class Foo {} file class Bar {}`).
    - In cases of generic types that would conflict with non-generic types of the same name, append `.T` to the file name, e.g. `class Foo` in `Foo.cs` and `class Foo<T>` in `Foo.T.cs`. For more than one generic type, use `.T1`, `.T2`, etc, where the number corresponds to the number of generic types, e.g. `class Foo<T1, T2>` in `Foo.T2.cs`.
    - An exception to this rule is when working with very tightly coupled types, where it makes sense to have them in the same file for easier navigation and understanding. In such cases, it is acceptable to have multiple top-level types in the same file.
10. We DO NOT use `var`, even when the type can be inferred. This is to maintain a consitent style throughout the codebase and to aid code review where no intellisense is available and reviewers would have to search for the type. This helps to improve readability of the codebase and makes it easier to understand the codebase at a glance, since the first word in each line immediately tells us what we are working with. At the same time, code review is made easier as the type is immediately apparent.
    - To reduce boilerplate, we use target-typed `new()` where possible but only when the type is explicitly named on the left-hand side, in a variable definition statement or a field definition statement. e.g. `FileStream stream = new(...);`, but not `stream = new(...);` (where the variable was declared on a previous line).
11. We use language keywords instead of BCL types (e.g. `int, string, float` instead of `Int32, String, Single`, etc) for both type references as well as method calls (e.g. `int.Parse` instead of `Int32.Parse`).
12. We use `SCREAMING_SNAKE_CASE` for all our constant fields and constant local variables. This clearly distinguishes constants from other types and fields.
13. We use PascalCasing for all method names, including local functions, as well as al type names, and all property names (regardless of visibility).
14. We use `nameof(...)` instead of `"..."` whenever possible and relevant. Similarly, we use `string.Empty` instead of `""`.
15. Fields should be specified at the top within type declarations. The order of field groups should be `const`, `static`, `readonly`, then `instance` fields. This helps keep the fields organized and keeps fields that change more frequently closer to the implementation details.
16. When including non-ASCII characters in the source code use Unicode escape sequences (`\uXXXX`) instead of literal characters. Literal non-ASCII characters occasionally get garbled by a tool or editor.
17. When using labels (for goto), indent the label one less than the current indentation, and name labels with `SCREAMING_SNAKE_CASE`.
    - We strictly discourage the use of `goto` for control flow, except in the following cases:
        - Breaking out of deeply nested loops, where the alternative would be to introduce one or more boolean flags that would make the code less readable.
        - In `bool TryGet(out Foo foo)` methods or similar cases where a distinct failure path with additional cleanup is required (e.g. assigning default values to out parameters) it is acceptable to define a `FAILURE` label after the primary `return true` of the method and use `goto FAILURE` after each check that would result in a failure.
        - In very rare cases where `goto` is the most readable and maintainable solution. You should have a very good reason for using `goto` in such cases and should be prepared to explain your reasoning in code review.
18. Make all internal and private types static or sealed unless derivation from them is required. As with any implementation detail, they can be changed if/when derivation is required in the future.
19. When writing task-returning methods, we postfix method names with `Async` (e.g. `public async Task<int> FooAsync()` instead of `public async Task<int> Foo()`). This clearly communicates the asynchronous nature of the method to the caller and helps reduce cases of asynchronous methods not being awaited.
20. We avoid magic strings and numbers in our code, especially when they are used more than once. Instead, we use constants or readonly fields to define these values. This makes the code more readable and maintainable, as well as reducing the risk of typos and other errors. When passing fixed values to a method, we prefer to use named arguments to make the code more readable and self-explanatory, e.g., `Divide(dividend: 10, divisor: 2)` instead of `Divide(10, 2)` and `DeflateStream deflate = new(fileStream, CompressionMode.Compress, leaveOpen: true)` instead of `DeflateStream deflate = new(fileStream, CompressionMode.Compress, true)`.
21. The recommended order of modifiers is `public`, `private`, `internal`, `protected`, `static`, `const`, `async`, `extern`, `override`, `virtual`, `abstract`, `sealed`, `readonly`, `partial`, `unsafe` and `volatile`. This order keeps the code consistent and lists modifiers in order of importance when reading the code. For example, visibility is more important than knowing whether a method is `virtual` or contains `unsafe` code.
22. We use `#region` and `#endregion` directives sparingly and only in very large files where splitting the file into seperate files is not feasible.
23. We use nullable reference types in all new projects globally and for new code in existing projects. We use nullable annotations to indicate when a value can be null and when it cannot. This especially includes `out` parameters of `bool TryGet...(out Foo value)` where `[NotNullWhen(...)]` or `[MaybeNullWhen(...)]` attributes should be specified for the `out` parameter.
24. All types, members, and variables should be named in a way that clearly communicates their purpose and intent. This includes avoiding abbreviations, using full words instead of acronyms, and using descriptive names that make the code self-explanatory. This is especially important for public APIs and interfaces, where the names should be clear and concise to make the code easy to understand and use. Exceptions to this rule are common acronyms and abbreviations that are widely understood in the context of the codebase and single-letter variable names for loop counters and similar short-lived variables.
    - When using acronyms or abbreviations, we capitalize up to at most two-letter acronyms and use PascalCase or camelCase in all other cases, e.g., `IPAddress` and `DBConnection` are acceptable, but `HTTPRequest` and `XMLSerializer` are not. Starting at three-letter acronyms, we use PascalCase, e.g., `XmlDocument` and `HtmlDocument`. When in doubt, PascalCase can be used for all acronyms and abbreviations, e.g., `DbContext`.
    - Generic type parameters should always start with `T`. If the context of the type parameter is not inherently clear, a more descriptive name should be used, e.g., `TKey` and `TValue` for dictionary types, `TSource` and `TResult` for LINQ methods, etc. In more obvious cases, `T` can be used, e.g., `List<T>`. For multiple generic type parameters, explicit names should be used instead of numbers, e.g., `TKey` and `TValue` instead of `T1` and `T2`.
    - Interface names should be prefixed with `I`, e.g., `IEnumerable`, `IDisposable`, `IList`, etc. This helps to distinguish interfaces from classes and makes the code more readable and self-explanatory.
25. We DO NOT use [Hungarian notation](https://en.wikipedia.org/wiki/Hungarian_notation) or other type prefixes in our code. The context of the code should make the type clear, and the use of descriptive names should eliminate the need for type prefixes. The only exception to this rule is when working with handles or pointers, where handles should be prefixed with `h` and pointers with `p`, e.g., `IntPtr hInstance`, `void* pData`.

An [EditorConfig](https://editorconfig.org "EditorConfig homepage") file (`.editorconfig`) has been provided alongside this document, enabling C# auto-formatting conforming to the above guidelines.
