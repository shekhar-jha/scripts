import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Set;
import java.util.List;
import java.util.ArrayList;
import java.net.*;


public class WebServer {

    private static byte[] data = new byte[255];

    public static void log(String message) {
        if (message != null) {
            System.out.println(message);
        } else {
            System.out.println();
        }
    }

	public static void usage(){
        log("Usage: java WebServer [-addr <listenAddress>] <port1> <port2> ...");
	}
    public static void main(String[] args) throws IOException {
        for (int i = 0; i < data.length; i++)
            data[i] = (byte) i;
        if (args.length == 0) {
			usage();
            return;
        }
		boolean listenAddressProvided = false;
		String listenAddress = "0.0.0.0";
		String connectAddress = null;
		if (args.length > 2 && args[0].startsWith("-add")) {
			listenAddress = args[1];
			connectAddress = args[1];
			listenAddressProvided = true;
		} else {
			log("Using listen address as " + listenAddress);
			connectAddress = java.net.InetAddress.getLocalHost().getHostName();
			log("Using connection validation address as " + connectAddress);
		}
		List<Integer> applicablePorts = new ArrayList<Integer>();
		for (int counter = listenAddressProvided?2:0; counter < args.length; counter++) {
			String portValue = args[counter];
			int port = -1;
			try {
				port = Integer.parseInt(portValue);
				Socket sock = new Socket();
				sock.connect(new InetSocketAddress(connectAddress, port), 2000);
                sock.getOutputStream().write("h".getBytes());
                sock.getInputStream().available();
                sock.close();
				log("Skipping port " + portValue + " since it is already being listened on.");
			}catch(NumberFormatException exception) { 
				log("Skipping port " + portValue + " since it is not a number.");
			}catch (ConnectException exception) {
				applicablePorts.add(port);
			}
		}
		if (applicablePorts.size() == 0) {
			log("Nothing to do since no ports are available to listen to");
			return;
		}
        Selector selector = Selector.open();
        for (int portValue : applicablePorts) {
			ServerSocketChannel server = ServerSocketChannel.open();
			server.configureBlocking(false);
			server.socket().bind(new InetSocketAddress(listenAddress, portValue));
			server.register(selector, SelectionKey.OP_ACCEPT);
        }

        while (true) {
            selector.select();
            Set readyKeys = selector.selectedKeys();
            Iterator iterator = readyKeys.iterator();
            while (iterator.hasNext()) {
                SelectionKey key = (SelectionKey) iterator.next();
                iterator.remove();
                if (key.isAcceptable()) {
                    SocketChannel client = ((ServerSocketChannel) key.channel()).accept();
                    log("Accepted connection from " + client);
                    client.configureBlocking(false);
                    ByteBuffer source = ByteBuffer.wrap("HELLO ".getBytes());
                    SelectionKey key2 = client.register(selector, SelectionKey.OP_WRITE);
                    key2.attach(source);
                } else if (key.isWritable()) {
                    SocketChannel client = (SocketChannel) key.channel();
                    ByteBuffer output = (ByteBuffer) key.attachment();
                    if (!output.hasRemaining()) {
                        output.rewind();
                    }
                    client.write(output);
                    client.close();
                }
            }
        }
    }
}
