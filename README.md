<img width="3040" height="722" alt="Trace Logo" src="https://github.com/user-attachments/assets/787b34b1-650a-4bca-9afe-55735f22555a" />

A Roblox Studio plugin that resolves selected Lua expressions into their fully qualified object paths within the DataModel hierarchy.

This tool is designed for developers who need accurate, canonical object paths without executing code or relying on `loadstring`.

---

## Overview

When working in Roblox Studio, developers often reference objects indirectly through local variables, chained indexing, or `require()` calls. Determining the full object path manually can be time-consuming and error-prone.

This plugin analyzes a selected Lua expression and resolves it into its complete path (for example, from `obj.PartA` to `game:GetService("ReplicatedStorage").ModuleA.PartA`) using safe static evaluation.

The plugin does not execute arbitrary Lua code.

---

## Key Features

* Static resolution of dot indexing (`a.b.c`)
* Local variable tracking within the script
* Canonical path reconstruction
* No use of `loadstring`
* No runtime execution

---

## Example

### Script

```lua
local storage = game:GetService("ReplicatedStorage")
local moduleA = require(storage.ModuleA)
local object = moduleA.ObjectA
```

### Selected Expression

```
object
```

### Resolved Output

```
game:GetService("ReplicatedStorage").ModuleA.ObjectA
```

---

### Another Example

```lua
local ws = workspace
local model = ws.ModelA
local part = model.PartA
```

Selecting:

```
part
```

Resolves to:

```
workspace.ModelA.PartA
```

---

## How It Works

The plugin performs controlled static analysis:

1. Parses the selected expression.
2. Tracks local variable assignments.
3. Resolves:

   * `game`
   * `workspace`
   * `script`
   * `GetService`
   * `require`
4. Walks the object hierarchy safely.
5. Reconstructs the canonical path string.

Only safe, statically analyzable expressions are supported.

No arbitrary function execution occurs at any point.

---

## Safety Model

This plugin:

* Does not use `loadstring`
* Does not execute dynamic code
* Does not evaluate user-defined functions
* Restricts evaluation to whitelisted operations
* Limits traversal depth to prevent runaway resolution

All resolution is deterministic and controlled.

---

## Supported Expressions

* Local variable references
* Property access (`object.Child`)
* Bracket indexing with constant strings
* `game:GetService("ServiceName")`
* Static `require()` calls
* Constant string concatenation

---

## Not Supported

The following patterns are intentionally unsupported:

* Loops
* Conditional branching
* Arbitrary function calls
* Metatable behavior
* Dynamic runtime mutations
* Non-constant indexing
* Computed expressions with side effects

If an expression cannot be resolved safely, the plugin will return a resolution error if debug prints are enabled.

---

## Intended Use Cases

* Generating canonical object paths
* Refactoring scripts
* Debugging indirect references
* Verifying module return structures
* Improving code clarity
* Tooling and static analysis workflows

---

## Installation

1. Download the plugin file.
2. Open Roblox Studio.
3. Navigate to Plugins → Manage Plugins → Install from File.
4. Select the plugin file.

---

## Future Improvements

* Enhanced AST parsing
* Cross-script reference analysis
* Improved module inference
* Smarter fallback resolution strategies
* Performance optimizations for large hierarchies

---

## License

MIT
