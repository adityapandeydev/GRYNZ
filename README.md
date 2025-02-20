# Grynz - The Universal Compiler

## 🌍 Overview
Grynz is a modular, universal compiler designed to compile multiple programming languages with a single command-line interface. The goal is to provide a seamless experience for developers by detecting the language of a given source file and compiling it using the appropriate compiler, handling project structures and dependencies where necessary.

## 📌 Current Status
Grynz is in its early development stage and currently supports the following languages:
- 🏗️ **C** (via `gcc`)
- 🏗️ **C++** (via `g++`)
- ♨️ **Java** (via `javac` and `java` for execution)
- 🐹 **Go** (via `go build`)
- 🐍 **Python** (via `python` for execution, and `Nuitka` for binary compilation, although not recommended)
- 🦀 **Rust** (via `rustc`)
- ⚡ **Zig** (via `zig build-exe` and `zig run` to compile and output instantly)

## 🔧 Features Implemented
### 🔨 Compilation System
- Detects file type based on extension and invokes the appropriate compiler.
- Supports specifying an output directory using the `--out` flag (except for Zig, which does not store compiled output without project initialization).
- Handles compilation errors and outputs relevant messages.

### ☕ Java Execution System
- Supports running Java programs with package handling.
- Supports `java -cp bin Main` format for running compiled Java files.
- Supports package-based execution: `java -cp bin javaFiles.Main`.

### 🐍 Python Execution & Compilation  
- **Execution:** Python scripts can be run directly using `grynz run script.py`.  
- **Binary Compilation:**  
  - **Grynz** supports compiling Python scripts into standalone binaries using **Nuitka**.  
  - **⚠️ Warning:** Python does not natively compile to binaries. Nuitka compilation is **optional and may not be efficient** for all use cases.

### 📂 File Handling
- Ensures uniformity by checking for file existence before attempting compilation or execution.
- Uses modular language-specific files (`c.zig`, `cpp.zig`, `java.zig`, etc.) for handling compilation logic per language.

## 🛠️ How to Use
### 🔨 Building a File
```sh
zig-out/bin/grynz build <file> [--out <output_dir>]
```
Example:
```sh
zig-out/bin/grynz build main.cpp --out ./bin
```

### ▶️ Running a Java Program
```sh
zig-out/bin/grynz run Main --out ./bin/javaFiles
```
For package-based execution:
```sh
zig-out/bin/grynz run javaFiles.Main --out ./bin
```

## 🔮 Future Plans
- **📂 Project Structure Detection:**
  - Detect `Cargo.toml` for Rust projects.
  - Detect Go modules for Go projects.
  - Extend support for Java Maven/Gradle structures.
- **🔧 Compiler Auto-Installation:**
  - If a required compiler is missing, prompt the user to install it.
- **🌍 More Language Support:**
  - Plan to add support for C#, TypeScript, Gleam etc.
- **⚙️ More Advanced Execution Handling:**
  - Support executing compiled C/C++/Rust binaries directly.
  - Support running scripts (JavaScript, TypeScript, etc) in future versions.

## 🤝 Contributing
This project is still in early development, and contributions are welcome. If you have suggestions, bug reports, or feature requests, feel free to open an issue or contribute via pull requests.

## 📜 License
Grynz is licensed under the **CC BY-NC-ND 4.0** license, meaning you **cannot** fork, modify, or use it commercially.  
However, contributions are welcome! See the [LICENSE](LICENSE) file for details.