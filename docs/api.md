Parser API
==========

The `gumbo` module provides 2 functions:

### parse

```lua
local document = gumbo.parse(html, options)
```

**Parameters:**

1. `html`: A *string* of UTF-8 encoded HTML.
2. `options`: A *table* of [parsing options](#parsing-options).

**Returns:**

Either a [`Document`] node on success, or `nil` and an error message on
failure.

### parseFile

```lua
local document = gumbo.parseFile(pathOrFile, options)
```

**Parameters:**

1. `pathOrFile`: Either a [file handle] or filename *string* that refers
   to a file containing UTF-8 encoded HTML.
2. `options`: A *table* of [parsing options](#parsing-options).

**Returns:**

As [above](#parse).

### Parsing Options

A table of options can be passed as the second argument to both parse
functions. The field names and their specified effects are as follows:

* `tabStop`: The *number* of columns to count for tab characters
  when computing source positions (defaults to `8`).
* `contextElement`: A *string* containing the name of an element to use
  as context for [HTML fragment parsing][]. This is for *fragment*
  parsing only -- leave as `nil` to parse HTML *documents*.
* `contextNamespace`: The namespace to use for the `contextElement`
  parameter; either `"html"`, `"svg"` or `"math"` (defaults
  to `"html"`).

DOM API
=======

The lua-gumbo DOM API mostly follows the [DOM] Level 4 Core
specification, with the following (intentional) exceptions:

* `DOMString` types are encoded as UTF-8 instead of UTF-16.
* Lists begin at index 1 instead of 0.
* `readonly` is not fully enforced.

The following sections list the supported properties and methods,
grouped by the DOM interface in which they are specified.

Nodes
-----

There are 6 types of `Node` that may appear directly in the HTML DOM
tree. These are [`Element`], [`Text`], [`Comment`], [`Document`],
[`DocumentType`] and [`DocumentFragment`]. The [`Node`] type itself is
just an [interface], which is *implemented* by all 6 of the aforementioned
types.

### `Element`

**Implements:**

* [`Node`]
* [`ParentNode`]
* [`ChildNode`]

**Properties:**

`localName`
:   The name of the element, as a case-normalized *string* (lower case
    for all HTML elements and most other elements; camelCase for some
    [SVG elements]).

`attributes`
:   An [`AttributeList`] containing an [`Attribute`] object for each
    attribute of the element.

`namespaceURI`
:   The canonical namespace URI of the the element.

    Possible values:

    | Namespace | `namespaceURI` value                   |
    |-----------|----------------------------------------|
    | HTML      | `"http://www.w3.org/1999/xhtml"`       |
    | MathML    | `"http://www.w3.org/1998/Math/MathML"` |
    | SVG       | `"http://www.w3.org/2000/svg"`         |

`tagName`
:   The name of the element, as an upper case *string*.

`id`
:   The value of the element's `id` attribute, if it has one, otherwise `nil`.

`className`
:   The value of the element's `class` attribute, if it has one, otherwise `nil`.

`innerHTML`
:   A *string* containing the HTML serialization of the element's descendants.

`outerHTML`
:   Like `innerHTML`, but operating on the element itself, in addition to its
    descendants.

**Methods:**

`getElementsByTagName(tagName)`
:   Returns an [`ElementList`] containing every child [`Element`] node
    whose `locaName` is equal to the given `tagName` argument.

`getElementsByClassName(classNames)`
:   Returns an [`ElementList`] containing every child [`Element`] node
    that has *all* of the given class names. Multiple class names can be
    specified by passing a string with several names separated by whitespace.

`hasAttributes()`
:   Returns `true` if the element has 1 or more attributes or `false` if
    it has none.

`hasAttribute(name)`
:   Returns `true` if the element has an attribute whose name matches the
    given `name` argument.

`getAttribute(name)`
:   Returns the value of the attribute whose name matches the `name`
    argument or `nil` if no such attribute exists.

`setAttribute(name, value)`
:   Sets the attribute specified with `name` to the given `value`. This
    method can be used either to create a new attribute or change an
    existing one.

`removeAttribute(name)`
:   Remove the attribute with the specified `name` from the element.

### `Text`

**Implements:**

* [`Node`]
* [`ChildNode`]

**Properties:**

`data`
:   A *string* representing the text contents of the node.

`length`
:   The length of the `data` property in bytes.

`escapedData`
:   TODO

### `Comment`

**Implements:**

* [`Node`]
* [`ChildNode`]

**Properties:**

`data`
:   A *string* representing the text contents of the comment node, *not*
    including the start delimiter (`<!--`) or end delimiter (`-->`) from
    the original markup.

`length`
:   The length of the `data` property in bytes.

### `Document`

The `Document` node represents the outermost container of a DOM tree and
is the result of parsing a single HTML document. It's direct child nodes
may include a single [`DocumentType`] node and any number of [`Element`]
or [`Comment`] nodes.

**Implements:**

* [`Node`]
* [`ParentNode`]

**Properties:**

`documentElement`
:   The root [`Element`] of the document (i.e. the `<html>` element).

`head`
:   The `<head>` [`Element`] of the document.

`body`
:   The `<body>` [`Element`] of the document.

`title`
:   A *string* containing the document's title (initially, the text contents
    of the `<title>` element in the document markup).

`forms`
:   An [`ElementList`] of all `<form>` elements in the document.

`images`
:   An [`ElementList`] of all `<img>` elements in the document.

`links`
:   An [`ElementList`] of all `<a>` and `<area>` elements in the
    document that have a value for the `href` attribute.

`scripts`
:   An [`ElementList`] of all `<script>` elements in the document.

`doctype`
:   A reference to the document's [`DocumentType`] node, if it has one,
    or `nil` if not.

**Methods:**

`getElementById(elementId)`
:   Returns the first [`Element`] node in the tree whose `id` property
    is equal to the `elementId` *string*.

`getElementsByTagName(tagName)`
:   Returns an [`ElementList`] containing every child [`Element`] node
    whose `locaName` is equal to the given `tagName` argument.

`getElementsByClassName(classNames)`
:   Returns an [`ElementList`] containing every child [`Element`] node
    that has *all* of the given class names. Multiple class names can be
    specified by passing a string with several names separated by whitespace.

`createElement(tagName)`
:   Creates and returns a new [`Element`] node with the given tag name.

`createTextNode(data)`
:   Creates and returns a new [`Text`] node with the given text contents.

`createComment(data)`
:   Creates and returns a new [`Comment`] node with the given text contents.

`adoptNode(externalNode)`
:   Removes a node and its subtree from another [`Document`][] (if any) and
    changes its `ownerDocument` to the current document. The node can then
    be inserted into the current document tree.

### `DocumentType`

**Implements:**

* [`Node`]
* [`ChildNode`]

**Properties:**

`name`
:   TODO

`publicId`
:   TODO

`systemId`
:   TODO

### `DocumentFragment`

**Implements:**

* [`Node`]
* [`ParentNode`]

**Properties:**

*TODO*

Node Interfaces
---------------

### `Node`

The `Node` interface is implemented by *all* DOM [nodes].

**Properties:**

`childNodes`
:   A [`NodeList`] containing all the children of the node.

`parentNode`
:   The parent [`Node`] of the node, if it has one, otherwise `nil`.

`parentElement`
:   The parent [`Element`] of the node, if it has one, otherwise `nil`.

`ownerDocument`
:   The [`Document`] to which the node belongs.

`nodeType`
:   An *integer* code representing the type of the node.

    | Node type            | `nodeType` value | Symbolic constant             |
    |----------------------|------------------|-------------------------------|
    | [`Element`]          |                1 | `Node.ELEMENT_NODE`           |
    | [`Text`]             |                3 | `Node.TEXT_NODE`              |
    | [`Comment`]          |                8 | `Node.COMMENT_NODE`           |
    | [`Document`]         |                9 | `Node.DOCUMENT_NODE`          |
    | [`DocumentType`]     |               10 | `Node.DOCUMENT_TYPE_NODE`     |
    | [`DocumentFragment`] |               11 | `Node.DOCUMENT_FRAGMENT_NODE` |

`nodeName`
:   A *string* representation of the type of the node:

    | Node type            | `nodeName` value                 |
    |----------------------|----------------------------------|
    | [`Element`]          | The value of `Element.tagName`   |
    | [`Text`]             | `"#text"`                        |
    | [`Comment`]          | `"#comment"`                     |
    | [`Document`]         | `"#document"`                    |
    | [`DocumentType`]     | The value of `DocumentType.name` |
    | [`DocumentFragment`] | `"#document-fragment"`           |

`type`
:   A *string* corresponding to the type of the node, as understood by
    the original Gumbo C API. This is subtly different from the node
    types in the DOM specification. The `whitespace` type is a [`Text`]
    node whose `data` property consists of only whitespace characters.

    | `type` value   | Node type            |
    |----------------|----------------------|
    | `"element"`    | [`Element`]          |
    | `"text"`       | [`Text`]             |
    | `"whitespace"` | [`Text`]             |
    | `"comment"`    | [`Comment`]          |
    | `"document"`   | [`Document`]         |
    | `"doctype"`    | [`DocumentType`]     |
    | `"fragment"`   | [`DocumentFragment`] |

    **Note:** in DOM-specified properties and methods, `whitespace` and
    `text` nodes are treated exactly the same. This disparity may be
    confusing, but the `type` property is retained for the sake of
    backwards compatibility with previous releases. It may also be
    useful for efficiently skipping whitespace-only [`Text`] nodes when
    traversing a document.

`firstChild`
:   The first child [`Node`] of the node, or `nil` if it has no children.

`lastChild`
:   The last child [`Node`] of the node, or `nil` if it has no children.

`previousSibling`
:   The previous adjacent [`Node`] in the tree, or `nil`.

`nextSibling`
:   The next adjacent [`Node`] in the tree, or `nil`.

`textContent`
:   If the node is a [`Text`] or [`Comment`] node, `textContent` returns
    node text (the `data` property).

    If the node is a [`Document`] or [`DocumentType`] node, `textContent`
    always returns `nil`.

    For other node types, `textContent` returns the concatenation of the
    `textContent` value of every child node, excluding comments, or an
    empty string.

`insertedByParser`
:   `true` if the node was inserted into the DOM tree automatically by
    the parser and `false` otherwise.

`implicitEndTag`
:   `true` if the node was implicitly closed by the parser (e.g. there
    was no explicit end tag in the markup) and `false` otherwise.

**Methods:**

`hasChildNodes()`
:   Returns `true` if the node has any child nodes and `false` otherwise.

`contains(other)`
:   Returns `true` if `other` is an inclusive [descendant][] [`Node`] and
    `false` otherwise.

`appendChild(node)`
:   Adds the [`Node`] passed as the `node` parameter to the end of the
    `childNodes` list.

`insertBefore(newNode, referenceNode)`
:   Inserts `newNode` immediately before `referenceNode` as a child of
    the current node.

    If `referenceNode` is `nil`, `newNode` is inserted at the end of
    the list of child nodes.

    The returned value is the inserted node.

`replaceChild(newChild, oldChild)`
:   Remove `oldChild` node from the `childNodes` list and insert `newChild`
    in its place. If `newChild` is part of an existing DOM tree, it is
    first removed from its parent.

    The returned value is the removed node.

`removeChild(childNode)`
:   Removes `childNode` from the DOM tree and returns the removed node.

    If the given `childNode` is not a child of the caller, the method
    throws an error.

`cloneNode(deep)`
:   Returns a duplicate copy of the node on which the method is called.
    If `deep` is `true` all [descendant] nodes are also copied.

`walk()`
:   Returns an iterator function that, each time it is called, returns the
    next [descendant] node in the subtree, in [document order]. This is
    typically used to iterate over every node in a document via a generic
    `for` loop. For example:

    ```lua
    local gumbo = require "gumbo"
    local document = assert(gumbo.parse("<p>1</p><p>2</p><p>3</p>"))

    for node in document.body:walk() do
        print(node)
    end
    ```

    *Note:* this method is an extension; not a part of any specification.
    It is similar in purpose to the [`Document.createTreeWalker()`]
    method, but has a different, much simpler API.

### `ParentNode`

The `ParentNode` interface is implemented by all [nodes] that can have
children.

**Properties:**

`children`
:   An [`ElementList`] of child [`Element`] nodes.

`childElementCount`
:   An *integer* representing the number of child [`Element`] nodes.

`firstElementChild`
:   The node's first child [`Element`] if there is one, otherwise `nil`.

`lastElementChild`
:   The node's last child [`Element`] if there is one, otherwise `nil`.

### `ChildNode`

The `ChildNode` interface is implemented by all [nodes] that can have a
parent.

**Methods:**

`remove()`
:   Removes the node from it's parent.

Attribute Objects
-----------------

### `AttributeList`

An `AttributeList` is a list containing zero or more [`Attribute`]
objects. Every [`Element`] node has an associated `AttributeList`, which
can be accessed via the `Element.attributes` property.

*Note:* `AttributeList` is equivalent to what the DOM specification
calls `NamedNodeMap`.

**Properties:**

*TODO*

### `Attribute`

The `Attribute` type represents a single attribute of an [`Element`].

*Note:* `Attribute` is equivalent to what the DOM specification calls
`Attr`.

**Properties:**

`name`
:   The name of the attribute.

`value`
:   The value of the attribute.

`escapedValue`
:   The value of the attribute, escaped according to the
    [rules][escapingString] in the [HTML fragment serialization] algorithm.

    Ampersand (`&`) characters in `value` become `&amp;`, double quote (`"`)
    characters become `&quot;` and non-breaking spaces (`U+00A0`) become
    `&nbsp;`.

    *This property is an extension; not a part of any specification.*

Node Containers
---------------

### `NodeList`

A list containing zero or more [nodes], as typically returned by the
`Node.childNodes` property.

**Properties:**

`length`
:   The *number* of nodes contained by the list.

### `ElementList`

A list containing zero or more [`Element`] nodes, as typically returned
by various [`Node`] and [`ParentNode`] methods.

*Note:* `ElementList` is equivalent to what the DOM specification calls
`HTMLCollection`.

**Properties:**

`length`
:   The *number* of `Element` nodes contained by the list.


[nodes]: #nodes
[`Element`]: #element
[`Text`]: #text
[`Comment`]: #comment
[`Document`]: #document
[`DocumentType`]: #documenttype
[`DocumentFragment`]: #documentfragment

[interface]: #node-interfaces
[`Node`]: #node
[`ParentNode`]: #parentnode
[`ChildNode`]: #childnode

[`AttributeList`]: #attributelist
[`Attribute`]: #attribute

[`NodeList`]: #nodelist
[`ElementList`]: #elementlist

[file handle]: https://www.lua.org/manual/5.2/manual.html#6.8
[DOM]: https://dom.spec.whatwg.org/
[SVG elements]: https://developer.mozilla.org/en-US/docs/Web/SVG/Element#SVG_elements
[`Document.createTreeWalker()`]: https://developer.mozilla.org/en-US/docs/Web/API/Document/createTreeWalker
[descendant]: https://dom.spec.whatwg.org/#concept-tree-descendant
[document order]: https://www.w3.org/TR/DOM-Level-2-Traversal-Range/glossary.html#dt-documentorder
[escapingString]: https://html.spec.whatwg.org/multipage/parsing.html#escapingString
[HTML fragment parsing]: https://html.spec.whatwg.org/multipage/parsing.html#parsing-html-fragments
[HTML fragment serialization]: https://html.spec.whatwg.org/multipage/parsing.html#html-fragment-serialisation-algorithm
