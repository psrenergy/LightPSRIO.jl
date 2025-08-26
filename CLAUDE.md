# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Testing
- Run all tests: `julia --project=. -e "import Pkg; Pkg.test()"`
- Or use convenience scripts:
  - Windows: `test\test.bat`
  - Unix/Linux: `test/test.sh`

### Code Formatting
- Format code: `julia --project=format format/format.jl`
- Or use convenience scripts:
  - Windows: `format\format.bat`
  - Unix/Linux: `format/format.sh`

### Development Session with Revise
- Start interactive session: `julia --project=revise revise/revise.jl`
- This loads the package with Revise.jl for automatic reloading during development

## Architecture Overview

LightPSRIO.jl is a Julia package that provides a Lua-scriptable interface for working with mathematical expressions and data operations, particularly focused on power system research input/output operations.

### Core Components

**Expression System**: The package implements an abstract expression tree system with:
- `Expression` (abstract base type) with concrete implementations:
  - `ExpressionDataNumber`: Constant numeric values
  - `ExpressionDataQuiver`: Data loaded from CSV files via the Quiver.jl package
  - `ExpressionUnary`/`ExpressionBinary`: Arithmetic operations between expressions
- All expressions support evaluation with keyword arguments for multi-dimensional data access

**Lua Integration**: Built on LuaNova.jl to provide:
- Lua scripting interface where users can write mathematical expressions in Lua syntax
- Automatic registration of Julia types and functions to Lua environment
- Bridge between Lua arithmetic operators and Julia expression trees

**Data Layer**:
- `Attributes`: Metadata container for expressions (labels, dimensions, sizes)
- `Quiver.Reader`/`Quiver.Writer`: CSV file I/O with support for multi-dimensional time series data
- `Generic` collection type for loading data files by name

### Key Design Patterns

- Expression trees are lazily evaluated - operations build the tree structure, evaluation happens on-demand
- Multi-dimensional data support through keyword arguments (stage, scenario, etc.)
- Resource management with `start!`/`finish!` lifecycle for file handles
- Lua metatable integration for operator overloading (`__add`, `__sub`, etc.)

### Data Flow

1. Initialize Lua state and register Julia types/functions
2. Execute Lua script that builds expression trees using `Generic:load()` and operators
3. Save results using `expression:save()` which evaluates across all dimensions and writes to CSV

The package is designed for interactive data analysis workflows where users can write mathematical expressions in Lua that operate on multi-dimensional datasets stored as CSV files.