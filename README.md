# Grynz - The Universal Compiler

## 🌍 Overview
Grynz is a modular, universal compiler designed to compile multiple programming languages with a single command-line interface. The goal is to provide a seamless experience for developers by detecting the language of a given source file and compiling it using the appropriate compiler, handling project structures and dependencies where necessary.

## 📌 Current Status
Grynz is in its early development stage and currently supports the following languages:
- <img src="LanguageSvgs\c-original.svg" alt="C" width="20" height="15"/> **C** (via `gcc`)
- <img src="LanguageSvgs\cplusplus-original.svg" alt="CPP" width="20" height="15"/> **C++** (via `g++`)
- <img src="LanguageSvgs\cplusplus-original.svg" alt="CPP" width="20" height="15"/> **C++** (via `elixir` project support coming soon)
- <img src="LanguageSvgs\erlang-original.svg" alt="Erlang" width="20" height="15"/> **Erlang** (via `erl`, rebar3 support coming soon)
- <img src="LanguageSvgs\go-original.svg" alt="Go" width="20" height="15"/> **Go** (via `go build`)
- <img src="LanguageSvgs\java-original.svg" alt="Java" width="20" height="15"/> **Java** (via `javac` and `java` for execution)
- <img src="LanguageSvgs\javascript-original.svg" alt="JavaScript" width="20" height="15"/> **JavaScript** (via `node` for execution, and `pkg` for binary compilation)
- <img src="LanguageSvgs\kotlin-original.svg" alt="Go" width="20" height="15"/> **Kotlin** (via `kotlinc` for compilation, and `java` for execution)
- <img src="LanguageSvgs\python-original.svg" alt="Python" width="20" height="15"/> **Python** (via `python` for execution, and `Nuitka` for binary compilation, although not recommended)
- <img src="LanguageSvgs\rust-original.svg" alt="Rust" width="20" height="15"/> **Rust** (via `rustc`)
- <img src="LanguageSvgs\typescript-original.svg" alt="Typescript" width="20" height="15"/> **TypeScript** (via `tsc` for compilation to JavaScript, and `node` for execution)
- <img src="LanguageSvgs\zig-original.svg" alt="Zig" width="20" height="15"/>  **Zig** (via `zig build-exe` and `zig run` to compile and output instantly)

## 🔧 Features Implemented
### 🔨 Compilation System
- Detects file type based on extension and invokes the appropriate compiler.
- Supports specifying an output directory using the `--out` flag.
- Handles compilation errors and outputs relevant messages.

### <img src="LanguageSvgs\java-original.svg" alt="Java" width="30" height="30"/> Java Execution System
- Supports running Java programs with package handling.
- Supports `java -cp bin Main` format for running compiled Java files.
- Supports package-based execution: `java -cp bin javaFiles.Main`.

### <img src="LanguageSvgs\python-original.svg" alt="Python" width="30" height="30"/> Python Execution & Compilation  
- **Execution:** Python scripts can be run directly using `grynz run script.py`.  
- **Binary Compilation:**  
  - **Grynz** supports compiling Python scripts into standalone binaries using **Nuitka**.  
  - **⚠️ Warning:** Python does not natively compile to binaries. Nuitka compilation is **optional and may not be efficient** for all use cases.

### <img src="LanguageSvgs\javascript-original.svg" alt="JavaScript" width="30" height="30"/> JavaScript & <img src="LanguageSvgs\typescript-original.svg" alt="Typescript" width="30" height="30"/> TypeScript Execution & Compilation  
- **JavaScript Execution:** JavaScript files can be run directly using `grynz run script.js`.  
- **JavaScript Binary Compilation:**  
  - **Grynz** supports compiling JavaScript files into standalone `.exe` binaries using **pkg**.  
  - **⚠️ Warning:** Using `pkg` will install `node_18` on your system, regardless of the Node.js version you currently have installed.  
- **TypeScript Execution:** TypeScript files are first compiled to JavaScript using `tsc`, and the resulting JavaScript file can be executed using `node`.  
- **TypeScript Binary Compilation:**  
  - TypeScript does not natively compile to `.exe` files. If you want to create a binary, you must first compile the TypeScript file to JavaScript using `tsc`, and then use `pkg` to compile the JavaScript file into a binary.  
  - Both steps (TypeScript to JavaScript, and JavaScript to binary) can be handled by **Grynz**.

### 📂 File Handling
- Ensures uniformity by checking for file existence before attempting compilation or execution.
- Uses modular language-specific files (`c.zig`, `cpp.zig`, `java.zig`, etc.) for handling compilation logic per language.

## 🛠️ How to Use
### 🔨 Building a File
```sh
grynz build <file> [--out <output_dir>]
```
Example:
```sh
grynz build main.cpp --out ./bin
```

### ▶️ Running a Java Program
```sh
grynz run Main --out ./bin/javaFiles
```
For package-based execution:
```sh
grynz run javaFiles.Main --out ./bin
```

## 🔮 Future Plans
- **📂 Project Structure Detection:**
  - Detect `Cargo.toml` for Rust projects.
  - Detect Go modules for Go projects.
  - Extend support for Java Maven/Gradle structures.
- **🔧 Compiler Auto-Installation:**
  - If a required compiler is missing, prompt the user to install it.
- **🌍 More Language Support:**
  - Plan to add support for C#, Nim, Erlang, Elixir, Gleam etc.
- **⚙️ More Advanced Execution Handling:**
  - Support executing compiled C/C++/Rust binaries directly.
  - Support running scripts (JavaScript, TypeScript, etc) in future versions.

## 🤝 Contributing
This project is still in early development, and contributions are welcome. If you have suggestions, bug reports, or feature requests, feel free to open an issue or contribute via pull requests.

## 📜 License
Grynz is licensed under the **CC BY-NC-ND 4.0** license, meaning you **cannot** fork, modify, or use it commercially.  
However, contributions are welcome! See the [LICENSE](LICENSE) file for details.