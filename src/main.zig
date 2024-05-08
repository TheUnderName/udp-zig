const std = @import("std");
const expect = std.testing.expect;
const net = std.net;
const os = std.os;
pub fn main() !void {
    _ = try Socket.init("127.0.0.1", 19132);
}

pub const Socket = struct {
    address: std.net.Address,
    socket: std.posix.socket_t,

    fn init(ip: []const u8, port: u16) !Socket {
        const parsed_address = try std.net.Address.parseIp4(ip, port);
        const sock: std.posix.socket_t = try std.posix.socket(std.posix.AF.INET, std.posix.SOCK.DGRAM, 0);
        _ = try std.posix.bind(sock, &parsed_address.any, parsed_address.getOsSockLen());

        try listen(sock);
        return Socket{ .address = parsed_address, .socket = sock };
    }

    fn listen(socket: std.posix.socket_t) !void {
        var buffer: [4096]u8 = undefined;

        while (true) {
            const received_bytes = try std.posix.recvfrom(socket, buffer[0..], 0, null, null);
            std.debug.print("Received {d} bytes: {s}\n", .{ received_bytes, buffer[0..received_bytes] });
        }

        _ = try std.posix.shutdown(socket, std.posix.ShutdownHow.recv); // close socket
    }
};
