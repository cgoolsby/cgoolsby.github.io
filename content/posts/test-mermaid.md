---
title: "Test Mermaid Diagrams"
date: 2025-06-03T10:00:00-07:00
draft: true
tags: ["test"]
---

This is a test post to verify that Mermaid diagrams are working correctly.

## Using Code Blocks

Here's a simple flowchart using code blocks:

```mermaid
graph TD
    A[Start] --> B{Is it working?}
    B -->|Yes| C[Great!]
    B -->|No| D[Debug]
    D --> A
```

## Using Shortcode

Here's the same diagram using the mermaid shortcode:

{{< mermaid >}}
graph TD
    A[Start] --> B{Is it working?}
    B -->|Yes| C[Great!]
    B -->|No| D[Debug]
    D --> A
{{< /mermaid >}}

## Sequence Diagram

```mermaid
sequenceDiagram
    Alice->>John: Hello John, how are you?
    John-->>Alice: Great!
    Alice-)John: See you later!
```

## Pie Chart

```mermaid
pie title Pets adopted by volunteers
    "Dogs" : 386
    "Cats" : 85
    "Rats" : 15
```