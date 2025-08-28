![banner](image/img.png)

# Moon 🌙

A demonstration project showcasing Redis operations with Lua scripts for high-precision decimal arithmetic, implemented in both Go and Python.

## Overview

Moon is a project that demonstrates how to use Redis with Lua scripts to perform high-precision decimal arithmetic operations. It includes implementations in both Go and Python, showing how to:

- Execute Lua scripts in Redis
- Perform precise decimal arithmetic operations
- Handle decimal numbers with arbitrary precision
- Integrate with Redis from different programming languages

## Features

- **High-Precision Arithmetic**: Implements decimal arithmetic with configurable precision
- **Multi-language Support**: Sample implementations in both Go and Python
- **Redis Integration**: Uses Redis as the backend for script execution and data storage
- **Lua Scripting**: Demonstrates complex operations using Redis Lua scripting
- **Environment Configuration**: Easy configuration via environment variables

## Prerequisites

- Docker and Docker Compose
- Go 1.16+ (for the Go implementation)
- Python 3.8+ (for the Python implementation)
- Redis server (can be run via Docker)

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd moon
```

### 2. Set Up Environment Variables

Copy the example environment file and update it with your Redis configuration:

```bash
cp .env.example .env
```

### 3. Start Redis with Docker Compose

```bash
docker-compose up -d
```

### 4. Run the Examples

#### Python Implementation

```bash
cd Python
pip install -r requirements.txt
python main.py
```

#### Go Implementation

```bash
cd GO
go mod tidy
go run main.go
```

## Project Structure

```
moon/
├── GO/                   # Go implementation
│   ├── go.mod            # Go module definition
│   ├── go.sum            # Go dependencies checksum
│   └── main.go           # Main Go application
├── Python/               # Python implementation
│   ├── main.py           # Main Python application
│   └── requirements.txt  # Python dependencies
├── script/               # Lua scripts
│   └── operations.lua    # Decimal arithmetic operations
├── .env                  # Environment configuration
└── docker-compose.yml    # Docker Compose configuration
```

## Lua Script Features

The `operations.lua` script provides the following operations:

- **Addition**: Add two decimal numbers with arbitrary precision
- **Subtraction**: Subtract one decimal number from another
- **Multiplication**: Multiply two decimal numbers
- **Division**: Divide one decimal number by another with configurable precision
- **Comparison**: Compare two decimal numbers

## Configuration

Configure the application using the following environment variables in the `.env` file:

```
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_password
REDIS_DB=0
```

## Examples

### Basic Usage

Both implementations demonstrate how to:

1. Connect to Redis
2. Load and execute the Lua script
3. Perform decimal arithmetic operations
4. Store and retrieve results from Redis

## License

This project is licensed under the terms of the [MIT License](LICENSE).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Hugo Martinez
