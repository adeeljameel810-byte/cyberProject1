#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="java-chat-server"
rm -rf "$ROOT_DIR"
mkdir -p "$ROOT_DIR"/src/main/java/com/adeeljameel810/chat
mkdir -p "$ROOT_DIR"/src/main/resources
mkdir -p "$ROOT_DIR"/src/test/java
mkdir -p "$ROOT_DIR"/.github/workflows

cat > "$ROOT_DIR/src/main/java/com/adeeljameel810/chat/ChatServer.java" <<'EOF'
package com.adeeljameel810.chat;

import java.io.*;
import java.net.*;
import java.util.*;

/**
 * Simple multi-client chat server.
 * Run: java -cp target/java-chat-server-1.0-SNAPSHOT.jar com.adeeljameel810.chat.ChatServer 12345
 */
public class ChatServer {
    private final int port;
    private final Set<PrintWriter> clients = Collections.synchronizedSet(new HashSet<>());

    public ChatServer(int port) {
        this.port = port;
    }

    public void start() throws IOException {
        try (ServerSocket serverSocket = new ServerSocket(port)) {
            System.out.println("Chat server started on port " + port);
            while (true) {
                Socket socket = serverSocket.accept();
                new Thread(new ClientHandler(socket)).start();
            }
        }
    }

    private void broadcast(String message) {
        synchronized (clients) {
            for (PrintWriter out : clients) {
                out.println(message);
                out.flush();
            }
        }
    }

    private class ClientHandler implements Runnable {
        private final Socket socket;

        ClientHandler(Socket socket) {
            this.socket = socket;
        }

        public void run() {
            PrintWriter out = null;
            String name = "Anonymous";
            try (
                Socket s = socket;
                BufferedReader in = new BufferedReader(new InputStreamReader(s.getInputStream()))
            ) {
                out = new PrintWriter(s.getOutputStream(), true);
                out.println("Welcome to the chat! Enter your name:");
                String inputName = in.readLine();
                if (inputName != null && !inputName.isBlank()) name = inputName.trim();

                clients.add(out);
                broadcast("*** " + name + " joined the chat ***");
                System.out.println("Client connected: " + socket.getRemoteSocketAddress() + " as " + name);

                String line;
                while ((line = in.readLine()) != null) {
                    if (line.equalsIgnoreCase("/quit")) break;
                    broadcast(name + ": " + line);
                }
            } catch (IOException e) {
                System.err.println("Client error: " + e.getMessage());
            } finally {
                if (out != null) {
                    clients.remove(out);
                }
                broadcast("*** " + name + " left the chat ***");
                System.out.println("Client disconnected: " + socket.getRemoteSocketAddress());
            }
        }
    }

    public static void main(String[] args) throws IOException {
        int port = 12345;
        if (args.length > 0) port = Integer.parseInt(args[0]);
        new ChatServer(port).start();
    }
}
EOF

cat > "$ROOT_DIR/src/main/java/com/adeeljameel810/chat/ChatClient.java" <<'EOF'
package com.adeeljameel810.chat;

import java.io.*;
import java.net.*;
import java.util.concurrent.*;

/**
 * Simple CLI chat client.
 * Run: java -cp target/java-chat-server-1.0-SNAPSHOT.jar com.adeeljameel810.chat.ChatClient localhost 12345
 */
public class ChatClient {
    public static void main(String[] args) throws Exception {
        String host = (args.length > 0) ? args[0] : "localhost";
        int port = (args.length > 1) ? Integer.parseInt(args[1]) : 12345;

        try (Socket socket = new Socket(host, port);
             BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
             PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
             BufferedReader stdin = new BufferedReader(new InputStreamReader(System.in))
        ) {
            // Thread to print server messages
            ExecutorService exec = Executors.newSingleThreadExecutor();
            exec.submit(() -> {
                try {
                    String fromServer;
                    while ((fromServer = in.readLine()) != null) {
                        System.out.println(fromServer);
                    }
                } catch (IOException e) {
                    // server closed
                }
            });

            // Read user input and send to server
            String line;
            while ((line = stdin.readLine()) != null) {
                out.println(line);
                if (line.equalsIgnoreCase("/quit")) break;
            }
            exec.shutdownNow();
        }
    }
}
EOF

cat > "$ROOT_DIR/pom.xml" <<'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.adeeljameel810</groupId>
  <artifactId>java-chat-server</artifactId>
  <version>1.0-SNAPSHOT</version>
  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
  </properties>
  <dependencies>
    <!-- Add JUnit 5 here if you add tests later -->
  </dependencies>
</project>
EOF

cat > "$ROOT_DIR/README.md" <<'EOF'
Java TCP Chat — Simple multi-client chat server and CLI client.

Prerequisites:
  - Java 17 JDK installed
  - Maven installed

Build:
  mvn package

Run server:
  java -cp target/java-chat-server-1.0-SNAPSHOT.jar com.adeeljameel810.chat.ChatServer 12345

Run client (in another terminal):
  java -cp target/java-chat-server-1.0-SNAPSHOT.jar com.adeeljameel810.chat.ChatClient localhost 12345

Usage:
  - When the client connects it will be prompted for a name.
  - Type messages and press Enter to send.
  - Use /quit to disconnect.

Notes:
  - This is a teaching example: no authentication and no encryption.
  - Useful follow-ups: add a user list, private messages, TLS, JUnit tests, or a GUI/web client.
EOF

cat > "$ROOT_DIR/.gitignore" <<'EOF'
# Maven
/target/
/.idea/
/.vscode/
*.class
*.log
*.iml
EOF

cat > "$ROOT_DIR/LICENSE" <<'EOF'
MIT License

Copyright (c) 2026 Adeel Jameel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

cat > "$ROOT_DIR/.github/workflows/ci.yml" <<'EOF'
name: Java CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
    - name: Cache Maven packages
      uses: actions/cache@v4
      with:
        path: ~/.m2/repository
        key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
        restore-keys: |
          ${{ runner.os }}-m2-
    - name: Build with Maven
      run: mvn -B package --file pom.xml
EOF

# create zip
ZIP_NAME="../java-chat-server.zip"
cd "$ROOT_DIR"
zip -r "$ZIP_NAME" . > /dev/null
cd -
echo "Created $ZIP_NAME"