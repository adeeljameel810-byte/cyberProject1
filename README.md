When the client connects, it will prompt for a name. Type messages and press Enter to send. Use `/quit` to disconnect.

## Example
1. Start server:
   `java -cp target/java-chat-server-1.0-SNAPSHOT.jar com.adeeljameel810.chat.ChatServer 12345`
2. Start client A:
   `java -cp target/java-chat-server-1.0-SNAPSHOT.jar com.adeeljameel810.chat.ChatClient localhost 12345`
   - Enter name `Alice`
3. Start client B:
   `java -cp target/java-chat-server-1.0-SNAPSHOT.jar com.adeeljameel810.chat.ChatClient localhost 12345`
   - Enter name `Bob`
4. Chat: messages from Alice and Bob will be broadcast to all connected clients.

## Project structure
- src/main/java/com/adeeljameel810/chat/
  - ChatServer.java
  - ChatClient.java
- pom.xml
- .github/workflows/ci.yml

## Troubleshooting
- `Address already in use`: pick another port or kill the process using the port.
- Client cannot connect: ensure server is running and port is accessible (firewalls/localhost).
- Build failures: ensure JAVA_HOME points to JDK 17 and `mvn -v` shows Maven is installed.

## Next steps / suggested improvements
- Add JUnit tests for refactored, testable components.
- Add TLS (SSLServerSocket / SSLSocket) for encrypted transport.
- Add authentication and user list / private messaging.
- Add a GUI client (JavaFX) or a web client via a WebSocket bridge.
- Add graceful shutdown of server and client heartbeats.

## Contributing
Contributions welcome. Please open an issue for ideas or send a PR. Add tests and update README with usage notes for any new feature.

## License
MIT — see LICENSE file.
